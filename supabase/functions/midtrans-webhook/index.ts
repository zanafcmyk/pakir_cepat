import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (req) => {
  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
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
      .select("id, booking_id, amount")
      .eq("provider_reference", orderId)
      .single();

    if (paymentError || !payment) {
      return json({ error: "Payment was not found." }, 404);
    }

    const status = paymentStatus(transactionStatus, fraudStatus);
    const paidAt = status === "paid" ? new Date().toISOString() : null;
    const { error: updatePaymentError } = await adminClient
      .from("payments")
      .update({ status, paid_at: paidAt })
      .eq("id", payment.id);

    if (updatePaymentError) {
      return json({ error: updatePaymentError.message }, 400);
    }

    if (status === "paid") {
      await adminClient
        .from("bookings")
        .update({ status: "paid", final_cost: payment.amount })
        .eq("id", payment.booking_id);

      const { data: booking } = await adminClient
        .from("bookings")
        .select("ticket_number, customer_id, customers(profile_id)")
        .eq("id", payment.booking_id)
        .single();

      const ticketNumber = text(booking?.ticket_number);
      await adminClient.from("receipts").upsert({
        booking_id: payment.booking_id,
        payment_id: payment.id,
        receipt_number: `RCT-${ticketNumber || orderId}`,
        issued_by: map(booking?.customers).profile_id ?? null,
      }, { onConflict: "booking_id" });
    }

    return json({ ok: true, status });
  } catch (error) {
    return json({ error: error instanceof Error ? error.message : "Error" }, 500);
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
  if (transactionStatus === "refund" || transactionStatus === "partial_refund") {
    return "refunded";
  }
  return "pending";
}

function text(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function map(value: unknown) {
  return value && typeof value === "object"
    ? value as Record<string, unknown>
    : {};
}

async function sha512(value: string) {
  const data = new TextEncoder().encode(value);
  const hash = await crypto.subtle.digest("SHA-512", data);
  return Array.from(new Uint8Array(hash))
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

function json(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
