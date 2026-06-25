import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (req) => {
  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey =
      Deno.env.get("SERVICE_ROLE_KEY") ??
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const midtransServerKey = Deno.env.get("MIDTRANS_SERVER_KEY");

    if (!supabaseUrl || !serviceRoleKey || !midtransServerKey) {
      return json({ error: "Missing configuration." }, 401);
    }

    const payload = await req.json();
    const orderId = text(payload.order_id);
    const statusCode = text(payload.status_code);
    const grossAmount = text(payload.gross_amount);
    const signatureKey = text(payload.signature_key);
    const transactionStatus = text(payload.transaction_status);
    const fraudStatus = text(payload.fraud_status);

    if (!orderId || !signatureKey) {
      return json({ error: "Invalid webhook payload." }, 400);
    }

    const expectedSignature = await sha512(
      `${orderId}${statusCode}${grossAmount}${midtransServerKey}`,
    );
    if (signatureKey !== expectedSignature) {
      return json({ error: "Invalid signature." }, 403);
    }

    const adminClient = createClient(supabaseUrl, serviceRoleKey);
    const { data: payment, error: paymentError } = await adminClient
      .from("payments")
      .select("id, booking_id, amount, status")
      .eq("provider_reference", orderId)
      .single();

    if (paymentError || !payment) {
      return json({ error: "Payment was not found." }, 404);
    }

    const status = paymentStatus(transactionStatus, fraudStatus);
    const { data: booking, error: bookingError } = await adminClient
      .from("bookings")
      .select("status, ticket_number, customer_id, customers(profile_id)")
      .eq("id", payment.booking_id)
      .single();

    if (bookingError || !booking) {
      return json({ error: "Booking was not found." }, 404);
    }

    if (booking.status === "cancelled") {
      if (status === "paid") {
        const paidAt = new Date().toISOString();
        const { data: latePayment, error: latePaymentError } = await adminClient
          .from("payments")
          .update({ status: "paid", paid_at: paidAt })
          .eq("id", payment.id)
          .eq("status", "cancelled")
          .select("id")
          .maybeSingle();

        if (latePaymentError) {
          return json({ error: latePaymentError.message }, 400);
        }

        const profileId = map(booking.customers).profile_id;
        if (latePayment && typeof profileId === "string" && profileId) {
          await adminClient.from("notifications").insert({
            profile_id: profileId,
            title: "Pembayaran diterima setelah reservasi berakhir",
            message: `Pembayaran ${text(booking.ticket_number)} diterima setelah reservasi dibatalkan. Hubungi dukungan untuk proses pengembalian dana.`,
            type: "late_payment",
            data: {
              booking_id: payment.booking_id,
              ticket_number: text(booking.ticket_number),
              requires_refund: true,
            },
          });
        }
      }

      return json({
        ok: true,
        status: status === "paid" ? "paid" : payment.status,
        bookingStatus: "cancelled",
        requiresRefund: status === "paid",
      });
    }

    const paidAt = status === "paid" ? new Date().toISOString() : null;
    const { error: updatePaymentError } = await adminClient
      .from("payments")
      .update({ status, paid_at: paidAt })
      .eq("id", payment.id);

    if (updatePaymentError) {
      return json({ error: updatePaymentError.message }, 400);
    }

    if (status === "paid") {
      const paidTotal = await totalPaidForBooking(
        adminClient,
        payment.booking_id,
      );
      const { data: paidBooking, error: paidBookingError } = await adminClient
        .from("bookings")
        .update({ status: "paid", final_cost: paidTotal })
        .eq("id", payment.booking_id)
        .eq("status", "pending_payment")
        .select("id")
        .maybeSingle();

      if (paidBookingError) {
        return json({ error: paidBookingError.message }, 400);
      }

      if (!paidBooking) {
        const { data: currentBooking } = await adminClient
          .from("bookings")
          .select("status, ticket_number, customers(profile_id)")
          .eq("id", payment.booking_id)
          .single();
        const currentBookingStatus = text(currentBooking?.status);

        if (currentBookingStatus === "cancelled") {
          const profileId = map(currentBooking.customers).profile_id;
          if (typeof profileId === "string" && profileId) {
            await adminClient.from("notifications").insert({
              profile_id: profileId,
              title: "Pembayaran diterima setelah reservasi berakhir",
              message: `Pembayaran ${text(currentBooking.ticket_number)} diterima setelah reservasi dibatalkan. Hubungi dukungan untuk proses pengembalian dana.`,
              type: "late_payment",
              data: {
                booking_id: payment.booking_id,
                ticket_number: text(currentBooking.ticket_number),
                requires_refund: true,
              },
            });
          }

          return json({
            ok: true,
            status,
            bookingStatus: "cancelled",
            requiresRefund: true,
          });
        }

        if (!["paid", "active", "completed"].includes(currentBookingStatus)) {
          return json({
            ok: true,
            status,
            bookingStatus: currentBookingStatus || booking.status,
            bookingUpdated: false,
          });
        }

        await adminClient
          .from("bookings")
          .update({ final_cost: paidTotal })
          .eq("id", payment.booking_id);
        // A repeated callback or extension callback still repairs a receipt missing from an earlier run.
      }

      const ticketNumber = text(booking?.ticket_number);
      await adminClient.from("receipts").upsert(
        {
          booking_id: payment.booking_id,
          payment_id: payment.id,
          receipt_number: `RCT-${ticketNumber || orderId}`,
          issued_by: map(booking?.customers).profile_id ?? null,
        },
        { onConflict: "booking_id" },
      );
    }

    return json({ ok: true, status });
  } catch (error) {
    return json(
      { error: error instanceof Error ? error.message : "Error" },
      500,
    );
  }
});

function paymentStatus(transactionStatus: string, fraudStatus: string) {
  if (
    transactionStatus === "settlement" ||
    (transactionStatus === "capture" && fraudStatus === "accept")
  ) {
    return "paid";
  }
  if (["deny", "cancel", "expire", "failure"].includes(transactionStatus)) {
    return "failed";
  }
  if (
    transactionStatus === "refund" ||
    transactionStatus === "partial_refund"
  ) {
    return "refunded";
  }
  return "pending";
}

function text(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function map(value: unknown) {
  return value && typeof value === "object"
    ? (value as Record<string, unknown>)
    : {};
}

async function sha512(value: string) {
  const data = new TextEncoder().encode(value);
  const hash = await crypto.subtle.digest("SHA-512", data);
  return Array.from(new Uint8Array(hash))
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

async function totalPaidForBooking(
  adminClient: ReturnType<typeof createClient>,
  bookingId: string,
) {
  const { data } = await adminClient
    .from("payments")
    .select("amount")
    .eq("booking_id", bookingId)
    .eq("status", "paid");

  if (!Array.isArray(data)) {
    return 0;
  }

  return data.reduce((total, item) => {
    const amount = Number(item.amount ?? 0);
    return Number.isFinite(amount) ? total + amount : total;
  }, 0);
}

function json(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
