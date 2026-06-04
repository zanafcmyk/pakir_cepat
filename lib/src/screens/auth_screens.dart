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
  String? errorMessage;

  Future<void> submit() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      await ref.read(authRepositoryProvider).signIn(email.text.trim(), password.text);
    } catch (error) {
      setState(() => errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Parkir Cepat', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 12),
                  TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: loading ? null : submit,
                    child: Text(loading ? 'Loading...' : 'Login'),
                  ),
                  TextButton(onPressed: () => context.go('/register'), child: const Text('Register')),
                ],
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
        appBar: AppBar(title: const Text('Register')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton(
                  onPressed: () => context.go('/register/customer'),
                  child: const Text('Register Customer'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.go('/register/provider'),
                  child: const Text('Register Provider'),
                ),
              ],
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
  String? errorMessage;

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
      setState(() => errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Register Customer')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextField(controller: fullName, decoration: const InputDecoration(labelText: 'Nama lengkap')),
            const SizedBox(height: 12),
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: phone, decoration: const InputDecoration(labelText: 'Nomor HP')),
            const SizedBox(height: 12),
            TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: loading ? null : submit,
              child: Text(loading ? 'Loading...' : 'Daftar'),
            ),
          ],
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
  String? errorMessage;

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
      final user = ref.read(authRepositoryProvider);
      final auth = await user.signUpProvider(
        fullName: fullName.text.trim(),
        email: email.text.trim(),
        phone: phone.text.trim(),
        password: password.text,
        parkingName: parkingName.text.trim(),
        address: address.text.trim(),
        capacity: int.tryParse(capacity.text) ?? 0,
        latitude: double.tryParse(latitude.text) ?? 0,
        longitude: double.tryParse(longitude.text) ?? 0,
        parkingPhotoUrl: parkingPhoto == null ? '' : await repo.uploadFile(bucket: 'parking-images', path: 'parking/${DateTime.now().millisecondsSinceEpoch}.jpg', file: parkingPhoto!),
        ktpPhotoUrl: ktpPhoto == null ? '' : await repo.uploadFile(bucket: 'provider-documents', path: 'ktp/${DateTime.now().millisecondsSinceEpoch}.jpg', file: ktpPhoto!),
      );
      if (auth.user != null && mounted) context.go('/provider/pending');
    } catch (error) {
      setState(() => errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Register Provider')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextField(controller: fullName, decoration: const InputDecoration(labelText: 'Nama lengkap')),
            const SizedBox(height: 12),
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: phone, decoration: const InputDecoration(labelText: 'Nomor HP')),
            const SizedBox(height: 12),
            TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 12),
            TextField(controller: parkingName, decoration: const InputDecoration(labelText: 'Nama tempat parkir')),
            const SizedBox(height: 12),
            TextField(controller: address, decoration: const InputDecoration(labelText: 'Alamat')),
            const SizedBox(height: 12),
            TextField(controller: capacity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Kapasitas kendaraan')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: latitude, decoration: const InputDecoration(labelText: 'Latitude'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: longitude, decoration: const InputDecoration(labelText: 'Longitude'))),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => pickPhoto(false), child: Text(parkingPhoto == null ? 'Upload foto lahan' : 'Foto lahan dipilih')),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: () => pickPhoto(true), child: Text(ktpPhoto == null ? 'Upload KTP' : 'KTP dipilih')),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: loading ? null : submit,
              child: Text(loading ? 'Loading...' : 'Daftar Provider'),
            ),
          ],
        ),
      );
}
