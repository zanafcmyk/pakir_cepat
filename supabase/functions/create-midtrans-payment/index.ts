import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
    const serviceRoleKey =
      Deno.env.get("SERVICE_ROLE_KEY") ??
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const midtransServerKey = Deno.env.get("MIDTRANS_SERVER_KEY");
    const isProduction = Deno.env.get("MIDTRANS_IS_PRODUCTION") === "true";
    const finishUrl = Deno.env.get("APP_PAYMENT_FINISH_URL") ?? "";
    const authorization = req.headers.get("Authorization");

    if (
      !supabaseUrl ||
      !anonKey ||
      !serviceRoleKey ||
      !midtransServerKey ||
      !authorization
    ) {
      return json({ error: "Missing configuration or authorization." }, 401);
    }

    const payload = await req.json();
    const ticketNumber = text(payload.ticketNumber);
    const method = paymentMethod(text(payload.method));

    if (!ticketNumber) {
      return json({ error: "Ticket number is required." }, 400);
    }

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authorization } },
    });
    const {
      data: { user },
      error: userError,
    } = await userClient.auth.getUser();

    if (userError || !user) {
      return json({ error: "User session is invalid." }, 401);
    }

    const adminClient = createClient(supabaseUrl, serviceRoleKey);
    const { data: customer, error: customerError } = await adminClient
      .from("customers")
      .select("id, profiles(full_name, email, phone_number)")
      .eq("profile_id", user.id)
      .single();

    if (customerError || !customer) {
      return json({ error: "Customer profile was not found." }, 403);
    }

    const { data: booking, error: bookingError } = await adminClient
      .from("bookings")
      .select("id, ticket_number, customer_id, estimated_cost, status")
      .eq("ticket_number", ticketNumber)
      .eq("customer_id", customer.id)
      .single();

    if (bookingError || !booking) {
      return json({ error: "Booking was not found." }, 404);
    }

    if (booking.status !== "pending_payment") {
      return json({ error: "Booking is not waiting for payment." }, 400);
    }

    const amount = Number(booking.estimated_cost ?? 0);
    if (!Number.isFinite(amount) || amount <= 0) {
      return json({ error: "Invalid payment amount." }, 400);
    }

    const orderId = `PC-${booking.ticket_number}-${Date.now()}`;
    const { data: payment, error: paymentError } = await adminClient
      .from("payments")
      .insert({
        booking_id: booking.id,
        customer_id: customer.id,
        method,
        status: "pending",
        amount,
        provider_reference: orderId,
      })
      .select("id")
      .single();

    if (paymentError || !payment) {
      return json({ error: paymentError?.message ?? "Payment failed." }, 400);
    }

    const profile = map(customer.profiles);
    const snapUrl = isProduction
      ? "https://app.midtrans.com/snap/v1/transactions"
      : "https://app.sandbox.midtrans.com/snap/v1/transactions";
    const snapResponse = await fetch(snapUrl, {
      method: "POST",
      headers: {
        Authorization: `Basic ${btoa(`${midtransServerKey}:`)}`,
        "Content-Type": "application/json",
        Accept: "application/json",
      },
      body: JSON.stringify({
        transaction_details: {
          order_id: orderId,
          gross_amount: amount,
        },
        item_details: [
          {
            id: booking.ticket_number,
            price: amount,
            quantity: 1,
            name: `Parkir Cepat ${booking.ticket_number}`,
          },
        ],
        customer_details: {
          first_name: profile.full_name ?? "Customer Parkir Cepat",
          email: profile.email ?? user.email,
          phone: profile.phone_number ?? undefined,
        },
        callbacks: finishUrl ? { finish: finishUrl } : undefined,
      }),
    });

    const snapBody = await snapResponse.json().catch(() => ({}));
    if (!snapResponse.ok) {
      await adminClient
        .from("payments")
        .update({ status: "failed" })
        .eq("id", payment.id);
      return json(
        { error: snapBody.error_messages?.[0] ?? "Midtrans request failed." },
        400,
      );
    }

    return json({
      paymentId: payment.id,
      orderId,
      token: snapBody.token,
      redirectUrl: snapBody.redirect_url,
    });
  } catch (error) {
    return json({ error: error instanceof Error ? error.message : "Error" }, 500);
  }
});

function text(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function paymentMethod(value: string) {
  if (["qris", "ewallet", "cash"].includes(value)) {
    return value;
  }
  return "qris";
}

function map(value: unknown) {
  return value && typeof value === "object"
    ? value as Record<string, unknown>
    : {};
}

function json(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
