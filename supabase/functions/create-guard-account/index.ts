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
    const authorization = req.headers.get("Authorization");

    if (!supabaseUrl || !anonKey || !serviceRoleKey || !authorization) {
      return json({ error: "Missing configuration or authorization." }, 401);
    }

    const payload = await req.json();
    const name = text(payload.name);
    const email = text(payload.email).toLowerCase();
    const phoneNumber = text(payload.phoneNumber);
    const password = text(payload.password);
    const assignedLotIds = Array.isArray(payload.assignedLotIds)
      ? payload.assignedLotIds.map((id: unknown) => String(id))
      : [];
    const canScanQr = payload.canScanQr !== false;
    const canConfirmCash = payload.canConfirmCash !== false;
    const canManageSlots = payload.canManageSlots === true;

    if (!name || !email || !password || password.length < 6) {
      return json({ error: "Name, email, and password are required." }, 400);
    }
    if (assignedLotIds.length === 0) {
      return json({ error: "At least one assigned lot is required." }, 400);
    }

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authorization } },
    });
    const {
      data: { user: caller },
      error: callerError,
    } = await userClient.auth.getUser();

    if (callerError || !caller) {
      return json({ error: "Provider session is invalid." }, 401);
    }

    const adminClient = createClient(supabaseUrl, serviceRoleKey);
    const { data: callerProfile, error: profileError } = await adminClient
      .from("profiles")
      .select("role, account_status, access_status")
      .eq("id", caller.id)
      .single();

    if (
      profileError ||
      callerProfile?.role !== "provider" ||
      callerProfile?.account_status !== "verified" ||
      callerProfile?.access_status !== "active"
    ) {
      return json({ error: "Only active verified providers can create guards." }, 403);
    }

    const { data: created, error: createError } =
      await adminClient.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
        user_metadata: { full_name: name, role: "parking_guard" },
      });

    if (createError && !createError.message.toLowerCase().includes("already")) {
      return json({ error: createError.message }, 400);
    }

    const guardUser = created.user ?? (await findUserByEmail(adminClient, email));
    if (!guardUser) {
      return json({ error: "Guard Auth user could not be created." }, 400);
    }

    const { error: updateAuthError } = await adminClient.auth.admin
      .updateUserById(guardUser.id, {
        password,
        email_confirm: true,
        user_metadata: { full_name: name, role: "parking_guard" },
      });

    if (updateAuthError) {
      return json({ error: updateAuthError.message }, 400);
    }

    const { error: profileUpsertError } = await adminClient
      .from("profiles")
      .upsert({
        id: guardUser.id,
        full_name: name,
        email,
        phone_number: phoneNumber || null,
        role: "parking_guard",
        account_status: "verified",
        access_status: "active",
        verified_at: new Date().toISOString(),
      });

    if (profileUpsertError) {
      return json({ error: profileUpsertError.message }, 400);
    }

    const { data: guardRows, error: linkError } = await userClient.rpc(
      "link_parking_guard_by_email",
      {
        p_guard_name: name,
        p_guard_email: email,
        p_guard_phone: phoneNumber,
        p_parking_lot_ids: assignedLotIds,
        p_can_scan_qr: canScanQr,
        p_can_confirm_cash: canConfirmCash,
        p_can_manage_slots: canManageSlots,
      },
    );

    if (linkError) {
      return json({ error: linkError.message }, 400);
    }

    return json({ guard: guardRows?.[0] ?? null });
  } catch (error) {
    return json({ error: error instanceof Error ? error.message : "Error" }, 500);
  }
});

function text(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

async function findUserByEmail(adminClient: ReturnType<typeof createClient>, email: string) {
  const { data, error } = await adminClient.auth.admin.listUsers();
  if (error) return null;
  return data.users.find((user) => user.email?.toLowerCase() === email) ?? null;
}

function json(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
