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
    const profileId = text(payload.profileId);
    if (!profileId) {
      return json({ error: "Profile id is required." }, 400);
    }

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authorization } },
    });
    const {
      data: { user: caller },
      error: callerError,
    } = await userClient.auth.getUser();

    if (callerError || !caller) {
      return json({ error: "User session is invalid." }, 401);
    }

    if (caller.id === profileId) {
      return json({ error: "Super admin cannot delete the current account." }, 400);
    }

    const adminClient = createClient(supabaseUrl, serviceRoleKey);
    const { data: callerProfile, error: callerProfileError } = await adminClient
      .from("profiles")
      .select("role, access_status")
      .eq("id", caller.id)
      .single();

    if (
      callerProfileError ||
      callerProfile?.role !== "super_admin" ||
      callerProfile?.access_status !== "active"
    ) {
      return json({ error: "Only active super admins can delete users." }, 403);
    }

    const { data: targetProfile, error: targetError } = await adminClient
      .from("profiles")
      .select("role")
      .eq("id", profileId)
      .single();

    if (targetError || !targetProfile) {
      return json({ error: "Target profile was not found." }, 404);
    }

    if (targetProfile.role === "super_admin") {
      return json({ error: "Super admin accounts cannot be deleted here." }, 403);
    }

    const { error: deleteError } = await adminClient.auth.admin.deleteUser(
      profileId,
    );

    if (deleteError) {
      return json({ error: deleteError.message }, 400);
    }

    return json({ ok: true });
  } catch (error) {
    return json({ error: error instanceof Error ? error.message : "Error" }, 500);
  }
});

function text(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function json(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
