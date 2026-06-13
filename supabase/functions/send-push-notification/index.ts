import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-push-secret",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey =
      Deno.env.get("SERVICE_ROLE_KEY") ??
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const firebaseProjectId = Deno.env.get("FIREBASE_PROJECT_ID");
    const serviceAccountJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON");
    const pushSecret = Deno.env.get("PUSH_FUNCTION_SECRET");

    if (!supabaseUrl || !serviceRoleKey || !firebaseProjectId || !serviceAccountJson) {
      return json({ error: "Missing push notification configuration." }, 401);
    }

    if (pushSecret && req.headers.get("x-push-secret") !== pushSecret) {
      return json({ error: "Invalid push secret." }, 403);
    }

    const payload = await req.json();
    const profileIds = Array.isArray(payload.profileIds)
      ? payload.profileIds.map((id: unknown) => String(id))
      : [];
    const title = text(payload.title);
    const body = text(payload.message);
    const data = map(payload.data);

    if (profileIds.length === 0 || !title || !body) {
      return json({ error: "profileIds, title, and message are required." }, 400);
    }

    const adminClient = createClient(supabaseUrl, serviceRoleKey);
    const { data: tokenRows, error: tokenError } = await adminClient
      .from("device_push_tokens")
      .select("token")
      .in("profile_id", profileIds);

    if (tokenError) {
      return json({ error: tokenError.message }, 400);
    }

    const tokens = [...new Set((tokenRows ?? []).map((row) => row.token))];
    if (tokens.length === 0) {
      return json({ sent: 0 });
    }

    const accessToken = await firebaseAccessToken(serviceAccountJson);
    let sent = 0;
    const failedTokens: string[] = [];

    for (const token of tokens) {
      const response = await fetch(
        `https://fcm.googleapis.com/v1/projects/${firebaseProjectId}/messages:send`,
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            message: {
              token,
              notification: { title, body },
              data: stringifyData(data),
            },
          }),
        },
      );

      if (response.ok) {
        sent += 1;
      } else {
        failedTokens.push(token);
      }
    }

    return json({ sent, failed: failedTokens.length });
  } catch (error) {
    return json({ error: error instanceof Error ? error.message : "Error" }, 500);
  }
});

async function firebaseAccessToken(serviceAccountJson: string) {
  const serviceAccount = JSON.parse(serviceAccountJson);
  const now = Math.floor(Date.now() / 1000);
  const jwt = await signJwt(
    {
      alg: "RS256",
      typ: "JWT",
    },
    {
      iss: serviceAccount.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
    },
    serviceAccount.private_key,
  );

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  const body = await response.json();
  if (!response.ok) {
    throw new Error(body.error_description ?? "FCM auth failed.");
  }
  return body.access_token as string;
}

async function signJwt(
  header: Record<string, unknown>,
  payload: Record<string, unknown>,
  privateKeyPem: string,
) {
  const unsigned = `${base64UrlJson(header)}.${base64UrlJson(payload)}`;
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(privateKeyPem),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsigned),
  );
  return `${unsigned}.${base64Url(new Uint8Array(signature))}`;
}

function pemToArrayBuffer(pem: string) {
  const base64 = pem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replaceAll(/\s/g, "");
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}

function base64UrlJson(value: Record<string, unknown>) {
  return base64Url(new TextEncoder().encode(JSON.stringify(value)));
}

function base64Url(bytes: Uint8Array) {
  let binary = "";
  for (const byte of bytes) {
    binary += String.fromCharCode(byte);
  }
  return btoa(binary).replaceAll("+", "-").replaceAll("/", "_").replaceAll("=", "");
}

function stringifyData(data: Record<string, unknown>) {
  const result: Record<string, string> = {};
  for (const [key, value] of Object.entries(data)) {
    result[key] = typeof value === "string" ? value : JSON.stringify(value);
  }
  return result;
}

function text(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
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
