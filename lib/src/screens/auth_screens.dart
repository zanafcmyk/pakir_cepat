import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../core/providers.dart';

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

  String _friendlyError(Object error) {
    final text = error.toString();
    if (text.contains('over_email_send_rate_limit') || text.contains('rate limit')) {
      return 'Terlalu banyak percobaan daftar email. Coba lagi beberapa menit lagi atau matikan email confirmation di Supabase Auth.';
    }
    return text;
  }

  Future<void> submit() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      await ref.read(authRepositoryProvider).signIn(email.text.trim(), password.text);
    } catch (error) {
      setState(() => errorMessage = _friendlyError(error));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEFF6FF), Color(0xFFFFFFFF)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundColor: Color(0xFF2563EB),
                            child: Icon(Icons.local_parking_rounded, color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Parkir Cepat',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Masuk untuk lanjut ke dashboard kamu.',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 28),
                          TextField(
                            controller: email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: password,
                            obscureText: hidePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                onPressed: () => setState(() => hidePassword = !hidePassword),
                              ),
                            ),
                          ),
                          if (errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(errorMessage!, style: const TextStyle(color: Color(0xFFB91C1C))),
                            ),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              ),
                              onPressed: loading ? null : submit,
                              child: Text(loading ? 'Loading...' : 'Login'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton(
                              onPressed: () => context.go('/register'),
                              child: const Text('Daftar akun baru'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class RegisterChoiceScreen extends StatelessWidget {
  const RegisterChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Pilih Registrasi')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _OptionCard(
                    title: 'Register Customer',
                    subtitle: 'Username + password',
                    icon: Icons.person_outline,
                    onTap: () => context.go('/register/customer'),
                  ),
                  const SizedBox(height: 12),
                  _OptionCard(
                    title: 'Register Provider',
                    subtitle: 'Username + password + foto profil',
                    icon: Icons.storefront_outlined,
                    onTap: () => context.go('/register/provider'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.title, required this.subtitle, required this.icon, required this.onTap});
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(backgroundColor: const Color(0xFFDBEAFE), child: Icon(icon, color: const Color(0xFF2563EB))),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
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

  String _friendlyError(Object error) {
    final text = error.toString();
    if (text.contains('over_email_send_rate_limit') || text.contains('rate limit')) {
      return 'Terlalu banyak percobaan daftar email. Coba lagi beberapa menit lagi atau matikan email confirmation di Supabase Auth.';
    }
    return text;
  }

  Future<void> submit() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      await ref.read(authRepositoryProvider).signUpCustomer(
            fullName: fullName.text.trim(),
            email: email.text.trim(),
            phone: phone.text.trim(),
            password: password.text,
          );
      if (mounted) context.go('/customer/dashboard');
    } catch (error) {
      setState(() => errorMessage = _friendlyError(error));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Register Customer')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _FormHeader(
                title: 'Register Customer',
                subtitle: 'Lengkapi data untuk masuk ke Parkir Cepat.',
              ),
              const SizedBox(height: 24),
              TextField(controller: fullName, decoration: const InputDecoration(labelText: 'Nama lengkap')),
              const SizedBox(height: 14),
              TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 14),
              TextField(controller: phone, decoration: const InputDecoration(labelText: 'Nomor HP')),
              const SizedBox(height: 14),
              TextField(
                controller: password,
                obscureText: hidePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => hidePassword = !hidePassword),
                  ),
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(errorMessage!, style: const TextStyle(color: Color(0xFFB91C1C))),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: loading ? null : submit,
                  child: Text(loading ? 'Loading...' : 'Daftar'),
                ),
              ),
            ],
          ),
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
  File? ktpPhoto;
  bool loading = false;
  bool hidePassword = true;
  String? errorMessage;

  String _friendlyError(Object error) {
    final text = error.toString();
    if (text.contains('over_email_send_rate_limit') || text.contains('rate limit')) {
      return 'Terlalu banyak percobaan daftar email. Coba lagi beberapa menit lagi atau matikan email confirmation di Supabase Auth.';
    }
    return text;
  }

  Future<void> pickPhoto(bool isKtp) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      if (isKtp) {
        ktpPhoto = File(picked.path);
      } else {
        parkingPhoto = File(picked.path);
      }
    });
  }

  Future<void> submit() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final repo = ref.read(appRepositoryProvider);
      final auth = ref.read(authRepositoryProvider);
      final parkingPhotoUrl = parkingPhoto == null
          ? ''
          : await repo.uploadFile(
              bucket: 'parking-images',
              path: 'parking/${DateTime.now().millisecondsSinceEpoch}.jpg',
              file: parkingPhoto!,
            );
      final ktpPhotoUrl = ktpPhoto == null
          ? ''
          : await repo.uploadFile(
              bucket: 'provider-documents',
              path: 'ktp/${DateTime.now().millisecondsSinceEpoch}.jpg',
              file: ktpPhoto!,
            );
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
        ktpPhotoUrl: ktpPhotoUrl,
      );
      if (mounted) context.go('/provider/pending');
    } catch (error) {
      setState(() => errorMessage = _friendlyError(error));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Register Provider')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _FormHeader(
                title: 'Register Provider',
                subtitle: 'Daftar penyedia parkir dengan foto dan lokasi.',
              ),
              const SizedBox(height: 24),
              TextField(controller: fullName, decoration: const InputDecoration(labelText: 'Nama lengkap')),
              const SizedBox(height: 14),
              TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 14),
              TextField(controller: phone, decoration: const InputDecoration(labelText: 'Nomor HP')),
              const SizedBox(height: 14),
              TextField(
                controller: password,
                obscureText: hidePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => hidePassword = !hidePassword),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(controller: parkingName, decoration: const InputDecoration(labelText: 'Nama tempat parkir')),
              const SizedBox(height: 14),
              TextField(controller: address, decoration: const InputDecoration(labelText: 'Alamat')),
              const SizedBox(height: 14),
              TextField(controller: capacity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Kapasitas kendaraan')),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: TextField(controller: latitude, decoration: const InputDecoration(labelText: 'Latitude'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: longitude, decoration: const InputDecoration(labelText: 'Longitude'))),
                ],
              ),
              const SizedBox(height: 14),
              OutlinedButton(onPressed: () => pickPhoto(false), child: Text(parkingPhoto == null ? 'Upload foto lahan' : 'Foto lahan dipilih')),
              const SizedBox(height: 8),
              OutlinedButton(onPressed: () => pickPhoto(true), child: Text(ktpPhoto == null ? 'Upload KTP' : 'KTP dipilih')),
              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(errorMessage!, style: const TextStyle(color: Color(0xFFB91C1C))),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: loading ? null : submit,
                  child: Text(loading ? 'Loading...' : 'Daftar Provider'),
                ),
              ),
            ],
          ),
        ),
      );
}

class _FormHeader extends StatelessWidget {
  const _FormHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFDBEAFE),
            child: Icon(Icons.local_parking_rounded, color: Color(0xFF2563EB)),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
        ],
      );
}
