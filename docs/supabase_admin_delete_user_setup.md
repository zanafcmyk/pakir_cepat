# Super Admin Delete User Setup

Kode aplikasi dan Edge Function sudah siap untuk menghapus akun Auth user dari halaman Super Admin.

Function:

```text
supabase/functions/admin-delete-user
```

Secret yang wajib ada di Supabase:

```text
SERVICE_ROLE_KEY
```

Deploy function:

```bash
supabase functions deploy admin-delete-user
```

Catatan keamanan:

- Function hanya mengizinkan profile dengan role `super_admin`.
- Super admin yang sedang login tidak bisa menghapus akun dirinya sendiri.
- Akun role `super_admin` lain tidak bisa dihapus dari function ini.
- User yang dihapus akan hilang dari Supabase Auth, lalu profile dan data terkait mengikuti aturan foreign key database.
