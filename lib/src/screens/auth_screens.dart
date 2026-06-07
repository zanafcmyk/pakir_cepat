import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../core/providers.dart';

class _BrandColors {
  static const primary = Color(0xFF2563EB);
  static const bg = Color(0xFFF8FAFC);
  static const text = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
}

class _AuthShell extends StatelessWidget {
  const _AuthShell({required this.child, required this.title, required this.subtitle});

  final Widget child;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF6FF), _BrandColors.bg],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 900;
                    return wide
                        ? Row(
                            children: [
                              Expanded(flex: 11, child: _HeroPanel(title: title, subtitle: subtitle)),
                              const SizedBox(width: 24),
                              Expanded(flex: 9, child: child),
                            ],
                          )
                        : child;
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF60A5FA)]),
        boxShadow: [BoxShadow(color: _BrandColors.primary.withValues(alpha: .18), blurRadius: 40, offset: const Offset(0, 18))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _BrandMark(light: true),
          const SizedBox(height: 36),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, height: 1.1)),
          const SizedBox(height: 12),
          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6)),
          const SizedBox(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _StatChip(label: 'Realtime', value: 'Maps'),
              _StatChip(label: 'Booking', value: 'Cepat'),
              _StatChip(label: 'RBAC', value: 'Aman'),
            ],
          ),
          const SizedBox(height: 28),
          const _FeatureCard(icon: Icons.map_rounded, title: 'Lokasi terdekat', subtitle: 'Card, filter, dan status slot dibuat lebih clean.'),
          const SizedBox(height: 12),
          const _FeatureCard(icon: Icons.verified_rounded, title: 'Role-based', subtitle: 'Flow pengguna, penyedia, dan admin dipisah jelas.'),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.light});
  final bool light;

  @override
  Widget build(BuildContext context) {
    final textColor = light ? Colors.white : _BrandColors.text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(color: light ? Colors.white : _BrandColors.primary, borderRadius: BorderRadius.circular(16)),
          child: Icon(Icons.local_parking_rounded, color: light ? _BrandColors.primary : Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Parkir Cepat', style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w800)),
            Text('Fast parking, clean UI', style: TextStyle(color: light ? Colors.white70 : _BrandColors.muted)),
          ],
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)), Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12))]),
      );
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withValues(alpha: .14))),
        child: Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .16), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: Colors.white)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Colors.white70, height: 1.4))]))]),
      );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC)]),
          ),
          child: const SafeArea(
            child: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                _SplashBadge(),
                SizedBox(height: 18),
                Text('Parkir Cepat', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: _BrandColors.text)),
                SizedBox(height: 8),
                Text('Modern parking experience', style: TextStyle(color: _BrandColors.muted)),
                SizedBox(height: 24),
                SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.8)),
              ]),
            ),
          ),
        ),
      );
}

class _SplashBadge extends StatelessWidget {
  const _SplashBadge();
  @override
  Widget build(BuildContext context) => Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: _BrandColors.primary.withValues(alpha: .12), blurRadius: 30, offset: const Offset(0, 14))]),
        child: const Icon(Icons.local_parking_rounded, color: _BrandColors.primary, size: 44),
      );
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  bool hidePassword = true;
  String? errorMessage;

  String _friendlyError(Object error) => error.toString().contains('rate limit') ? 'Terlalu banyak percobaan. Coba lagi nanti.' : error.toString();

  Future<void> submit() async {
    setState(() { loading = true; errorMessage = null; });
    try {
      await ref.read(authRepositoryProvider).signIn(email.text.trim(), password.text);
    } catch (error) {
      setState(() => errorMessage = _friendlyError(error));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthShell(
      title: 'Masuk cepat, langsung parkir.',
      subtitle: 'UI baru: clean, modern, dan fokus ke booking yang simpel di mobile maupun web.',
      child: _FormCard(
        title: 'Login',
        subtitle: 'Gunakan akun yang sudah terdaftar.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _BrandMark(light: false),
            const SizedBox(height: 24),
            TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email / Username', prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 14),
            TextField(controller: password, obscureText: hidePassword, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => hidePassword = !hidePassword)))),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              _NoticeBox(message: errorMessage!, error: true),
            ],
            const SizedBox(height: 18),
            FilledButton(
              onPressed: loading ? null : submit,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
              child: loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Login'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => context.go('/register'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), child: const Text('Daftar')),
          ],
        ),
      ),
    );
  }
}

class RegisterChoiceScreen extends StatelessWidget {
  const RegisterChoiceScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const _BrandMark(light: false),
                  const SizedBox(height: 24),
                  const Text('Pilih tipe akun', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _BrandColors.text)),
                  const SizedBox(height: 8),
                  Text('Pilih role utama. Akun penjaga dibuat dari dashboard penyedia parkir.', style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 20),
                  Wrap(spacing: 16, runSpacing: 16, children: [
                    _ChoiceCard(title: 'User Parkir', subtitle: 'Cari, pesan, dan pantau parkir.', icon: Icons.person_search_rounded, onTap: () => context.go('/register/customer')),
                    _ChoiceCard(title: 'Penyedia Parkir', subtitle: 'Kelola lokasi dan slot.', icon: Icons.store_mall_directory_rounded, onTap: () => context.go('/register/provider')),
                    _ChoiceCard(title: 'Super Admin', subtitle: 'Pantau pengguna, verifikasi, laporan, dan komplain.', icon: Icons.admin_panel_settings_rounded, onTap: () => context.go('/register/super-admin')),
                    _ChoiceCard(title: 'Penjaga Parkir', subtitle: 'Login memakai akun yang dibuat penyedia.', icon: Icons.security_rounded, onTap: () => context.go('/login')),
                  ]),
                ]),
              ),
            ),
          ),
        ),
      );
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({required this.title, required this.subtitle, required this.icon, required this.onTap});
  final String title; final String subtitle; final IconData icon; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 360,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(18)), child: Icon(icon, color: _BrandColors.primary, size: 30)),
                const SizedBox(height: 18),
                Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _BrandColors.text)),
                const SizedBox(height: 8),
                Text(subtitle, style: const TextStyle(color: _BrandColors.muted, height: 1.5)),
                const SizedBox(height: 18),
                const Text('Lanjut ?', style: TextStyle(color: _BrandColors.primary, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ),
      );
}

class CustomerRegisterScreen extends ConsumerStatefulWidget {
  const CustomerRegisterScreen({super.key});
  @override
  ConsumerState<CustomerRegisterScreen> createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends ConsumerState<CustomerRegisterScreen> {
  final fullName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  bool hidePassword = true;
  String? errorMessage;

  Future<void> submit() async {
    setState(() { loading = true; errorMessage = null; });
    try {
      await ref.read(authRepositoryProvider).signUpCustomer(fullName: fullName.text.trim(), email: email.text.trim(), phone: phone.text.trim(), password: password.text);
      if (mounted) context.go('/login');
    } catch (error) {
      setState(() => errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => _AuthShell(
        title: 'Daftar user parkir.',
        subtitle: 'Form sederhana, fokus ke registrasi cepat tanpa ganggu flow utama.',
        child: _FormCard(
          title: 'Register User',
          subtitle: 'Isi data dasar untuk mulai cari parkir.',
          child: Column(children: [
            TextField(controller: fullName, decoration: const InputDecoration(labelText: 'Nama lengkap', prefixIcon: Icon(Icons.badge_outlined))),
            const SizedBox(height: 14),
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
            const SizedBox(height: 14),
            TextField(controller: phone, decoration: const InputDecoration(labelText: 'No. HP', prefixIcon: Icon(Icons.phone_outlined))),
            const SizedBox(height: 14),
            TextField(controller: password, obscureText: hidePassword, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => hidePassword = !hidePassword)))),
            if (errorMessage != null) ...[const SizedBox(height: 12), _NoticeBox(message: errorMessage!, error: true)],
            const SizedBox(height: 16),
            FilledButton(onPressed: loading ? null : submit, style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), child: loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Buat akun')),
          ]),
        ),
      );
}

class SuperAdminRegisterScreen extends ConsumerStatefulWidget {
  const SuperAdminRegisterScreen({super.key});

  @override
  ConsumerState<SuperAdminRegisterScreen> createState() =>
      _SuperAdminRegisterScreenState();
}

class _SuperAdminRegisterScreenState
    extends ConsumerState<SuperAdminRegisterScreen> {
  final fullName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  bool hidePassword = true;
  String? errorMessage;

  @override
  void dispose() {
    fullName.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      await ref.read(authRepositoryProvider).signUpSuperAdmin(
            fullName: fullName.text.trim(),
            email: email.text.trim(),
            phone: phone.text.trim(),
            password: password.text,
          );
      if (mounted) context.go('/login');
    } catch (error) {
      setState(() => errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => _AuthShell(
        title: 'Daftar Super Admin.',
        subtitle: 'Akun untuk monitoring pengguna, verifikasi, laporan, dan komplain.',
        child: _FormCard(
          title: 'Register Super Admin',
          subtitle: 'Gunakan hanya untuk pengelola aplikasi.',
          child: Column(children: [
            TextField(controller: fullName, decoration: const InputDecoration(labelText: 'Nama lengkap', prefixIcon: Icon(Icons.badge_outlined))),
            const SizedBox(height: 14),
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
            const SizedBox(height: 14),
            TextField(controller: phone, decoration: const InputDecoration(labelText: 'No. HP', prefixIcon: Icon(Icons.phone_outlined))),
            const SizedBox(height: 14),
            TextField(controller: password, obscureText: hidePassword, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => hidePassword = !hidePassword)))),
            if (errorMessage != null) ...[const SizedBox(height: 12), _NoticeBox(message: errorMessage!, error: true)],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: loading ? null : submit,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
              child: loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Buat akun super admin'),
            ),
          ]),
        ),
      );
}

class ProviderRegisterScreen extends ConsumerStatefulWidget {
  const ProviderRegisterScreen({super.key});
  @override
  ConsumerState<ProviderRegisterScreen> createState() => _ProviderRegisterScreenState();
}

class _ProviderRegisterScreenState extends ConsumerState<ProviderRegisterScreen> {
  final fullName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  final parkingName = TextEditingController();
  final address = TextEditingController();
  final capacity = TextEditingController();
  final latitude = TextEditingController();
  final longitude = TextEditingController();
  File? parkingPhoto;
  File? profilePhoto;
  bool loading = false;
  bool hidePassword = true;
  String? errorMessage;

  Future<void> pickPhoto(bool isKtp) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() { isKtp ? profilePhoto = File(picked.path) : parkingPhoto = File(picked.path); });
  }

  Future<void> submit() async {
    setState(() { loading = true; errorMessage = null; });
    try {
      final repo = ref.read(appRepositoryProvider);
      final auth = ref.read(authRepositoryProvider);
      final parkingPhotoUrl = parkingPhoto == null ? '' : await repo.uploadFile(bucket: 'parking-images', path: 'parking/${DateTime.now().millisecondsSinceEpoch}.jpg', file: parkingPhoto!);
      final profilePhotoUrl = profilePhoto == null ? '' : await repo.uploadFile(bucket: 'profile-images', path: 'profile/.jpg', file: profilePhoto!);
      await auth.signUpProvider(
        fullName: fullName.text.trim(),
        email: email.text.trim(),
        phone: phone.text.trim(),
        password: password.text,
        parkingName: parkingName.text.trim(),
        address: address.text.trim(),
        capacity: int.tryParse(capacity.text) ?? 0,
        latitude: double.tryParse(latitude.text) ?? 0,
        longitude: double.tryParse(longitude.text) ?? 0,
        parkingPhotoUrl: parkingPhotoUrl,
        ktpPhotoUrl: profilePhotoUrl,
      );
      if (mounted) context.go('/provider/pending');
    } catch (error) {
      setState(() => errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => _AuthShell(
        title: 'Register penyedia parkir.',
        subtitle: 'UI lebih tegas: data akun, lokasi, dan upload foto dipisah jelas.',
        child: _FormCard(
          title: 'Register Penyedia',
          subtitle: 'Lengkapi profil bisnis parkir.',
          child: Column(children: [
            TextField(controller: fullName, decoration: const InputDecoration(labelText: 'Nama lengkap', prefixIcon: Icon(Icons.badge_outlined))),
            const SizedBox(height: 14),
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
            const SizedBox(height: 14),
            TextField(controller: phone, decoration: const InputDecoration(labelText: 'No. HP', prefixIcon: Icon(Icons.phone_outlined))),
            const SizedBox(height: 14),
            TextField(controller: password, obscureText: hidePassword, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => hidePassword = !hidePassword)))),
            const SizedBox(height: 14),
            TextField(controller: parkingName, decoration: const InputDecoration(labelText: 'Nama lokasi', prefixIcon: Icon(Icons.local_parking_outlined))),
            const SizedBox(height: 14),
            TextField(controller: address, decoration: const InputDecoration(labelText: 'Alamat', prefixIcon: Icon(Icons.location_on_outlined))),
            const SizedBox(height: 14),
            Row(children: [Expanded(child: TextField(controller: capacity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Kapasitas', prefixIcon: Icon(Icons.confirmation_number_outlined)))), const SizedBox(width: 12), Expanded(child: TextField(controller: latitude, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Latitude', prefixIcon: Icon(Icons.north_outlined))))]),
            const SizedBox(height: 14),
            TextField(controller: longitude, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Longitude', prefixIcon: Icon(Icons.east_outlined))),
            const SizedBox(height: 14),
            Row(children: [Expanded(child: _UploadTile(label: 'Foto parkir', file: parkingPhoto, onTap: () => pickPhoto(false))), const SizedBox(width: 12), Expanded(child: _UploadTile(label: 'Foto profil', file: profilePhoto, onTap: () => pickPhoto(true)))]),
            if (errorMessage != null) ...[const SizedBox(height: 12), _NoticeBox(message: errorMessage!, error: true)],
            const SizedBox(height: 16),
            FilledButton(onPressed: loading ? null : submit, style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), child: loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Buat akun penyedia')),
          ]),
        ),
      );
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({required this.label, required this.file, required this.onTap});
  final String label;
  final File? file;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Icon(Icons.cloud_upload_outlined, color: _BrandColors.primary),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(file == null ? 'Tap untuk pilih file' : 'File dipilih', style: const TextStyle(color: _BrandColors.muted, fontSize: 12)),
          ]),
        ),
      );
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.title, required this.subtitle, required this.child});
  final String title; final String subtitle; final Widget child;
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _BrandColors.text)),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: _BrandColors.muted)),
            const SizedBox(height: 20),
            child,
          ]),
        ),
      );
}

class _NoticeBox extends StatelessWidget {
  const _NoticeBox({required this.message, required this.error});
  final String message; final bool error;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: error ? const Color(0xFFFEE2E2) : const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(16)),
        child: Text(message, style: TextStyle(color: error ? const Color(0xFFB91C1C) : _BrandColors.primary)),
      );
}
