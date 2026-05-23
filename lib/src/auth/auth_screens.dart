part of 'package:parkir_cepat/app.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) {
        return;
      }
      final state = ref.read(appControllerProvider);
      final controller = ref.read(appControllerProvider.notifier);
      if (!state.onboardingDone) {
        context.go('/onboarding');
      } else if (!state.isAuthenticated) {
        context.go('/login');
      } else {
        context.go(controller.landingRouteFor(state));
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.white, AppTheme.blueSoft, AppTheme.emeraldSoft],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: const LinearGradient(
                      colors: [AppTheme.blue, AppTheme.emerald],
                    ),
                    boxShadow: [softShadow(AppTheme.blue.withValues(alpha: 0.2))],
                  ),
                  child: const Icon(
                    Icons.local_parking_rounded,
                    color: Colors.white,
                    size: 54,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Parkir Cepat',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Smart parking futuristik untuk kota modern.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.slate,
                      ),
                ),
                const SizedBox(height: 30),
                const SmartCityIllustration(height: 170),
                const SizedBox(height: 30),
                const SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.2,
                    color: AppTheme.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _controller;

  final _items = const [
    (
      title: 'Cari tempat parkir terdekat',
      body:
          'Lihat area parkir real-time dengan radius, estimasi waktu, dan status slot.',
      accent: AppTheme.blue,
      icon: Icons.map_rounded,
    ),
    (
      title: 'Booking parkir online',
      body:
          'Kunci slot terbaik dalam beberapa detik sebelum Anda tiba di lokasi.',
      accent: AppTheme.emerald,
      icon: Icons.book_online_rounded,
    ),
    (
      title: 'Pembayaran digital dan QR',
      body:
          'Masuk dan keluar lebih cepat dengan tiket QR premium dan pembayaran cashless.',
      accent: AppTheme.blue,
      icon: Icons.qr_code_2_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ref.read(appControllerProvider.notifier).finishOnboarding();
                    context.go('/login');
                  },
                  child: const Text('Lewati'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _items.length,
                  onPageChanged:
                      ref.read(appControllerProvider.notifier).setOnboardingPage,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SmartCityIllustration(
                          height: 240,
                          accent: item.accent,
                          icon: item.icon,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          item.body,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.slate,
                                    height: 1.5,
                                  ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _items.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: state.onboardingIndex == index ? 28 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: state.onboardingIndex == index
                          ? AppTheme.blue
                          : AppTheme.slate.withValues(alpha: 0.24),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: state.onboardingIndex == _items.length - 1
                    ? 'Mulai Sekarang'
                    : 'Lanjut',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  if (state.onboardingIndex == _items.length - 1) {
                    ref.read(appControllerProvider.notifier).finishOnboarding();
                    context.go('/login');
                    return;
                  }
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _rememberMe = true;
  AccountMode _mode = AccountMode.customer;

  void _submitLogin() {
    final controller = ref.read(appControllerProvider.notifier);
    controller.login(
      mode: _mode,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      rememberMe: _rememberMe,
    );
    context.go(controller.landingRouteFor(ref.read(appControllerProvider)));
  }

  @override
  void initState() {
    super.initState();
    final state = ref.read(appControllerProvider);
    _emailController = TextEditingController(text: state.email);
    _phoneController = TextEditingController(text: state.phoneNumber);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Masuk ke Parkir Cepat',
      subtitle: 'Akses parkir pintar dengan alur cepat, aman, dan premium.',
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Masuk sebagai',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 14),
          RoleSelectionCards(
            value: _mode,
            onChanged: (value) => setState(() => _mode = value),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Nomor HP',
              prefixIcon: Icon(Icons.phone_iphone_rounded),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Switch(
                value: _rememberMe,
                activeThumbColor: AppTheme.blue,
                onChanged: (value) => setState(() => _rememberMe = value),
              ),
              const Text('Remember me'),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/forgot-password'),
                child: const Text('Lupa password'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Masuk',
            icon: Icons.login_rounded,
            onPressed: _submitLogin,
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Masuk dengan Google',
            icon: Icons.g_mobiledata_rounded,
            onPressed: _submitLogin,
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: 'Login nomor HP',
            icon: Icons.sms_rounded,
            onPressed: _submitLogin,
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Belum punya akun?'),
              TextButton(
                onPressed: () => context.push('/register'),
                child: const Text('Daftar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _parkingNameController;
  late final TextEditingController _parkingAddressController;
  late final TextEditingController _parkingPhotoController;
  late final TextEditingController _locationPointController;
  late final TextEditingController _identityController;
  AccountMode _mode = AccountMode.customer;
  double _providerCapacity = 80;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Dio Pratama');
    _emailController = TextEditingController(text: 'dio@parkircepat.app');
    _phoneController = TextEditingController(text: '+62 812 7788 9911');
    _parkingNameController = TextEditingController(text: 'Parkir Cepat Sudirman Hub');
    _parkingAddressController =
        TextEditingController(text: 'Jl. Sudirman Smart Gate Kav. 18');
    _parkingPhotoController = TextEditingController(text: 'lahan_parkir_sudirman.jpg');
    _locationPointController =
        TextEditingController(text: 'Lat -6.2088, Lng 106.8456');
    _identityController = TextEditingController(text: 'ktp_provider_dio.png');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _parkingNameController.dispose();
    _parkingAddressController.dispose();
    _parkingPhotoController.dispose();
    _locationPointController.dispose();
    _identityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Buat akun baru',
      subtitle: 'Pilih mode akun sesuai peran Anda di ekosistem smart parking.',
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nama lengkap',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Nomor HP',
              prefixIcon: Icon(Icons.phone_iphone_rounded),
            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline_rounded),
            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Konfirmasi password',
              prefixIcon: Icon(Icons.lock_reset_rounded),
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Daftar sebagai',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 14),
          RoleSelectionCards(
            value: _mode,
            onChanged: (value) => setState(() => _mode = value),
          ),
          if (_mode == AccountMode.provider) ...[
            const SizedBox(height: 22),
            PremiumCard(
              accent: AppTheme.emeraldSoft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data verifikasi penyedia',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Akun penyedia akan masuk status pending verification sampai admin meninjau data lahan dan identitas.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.slate,
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _parkingNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama tempat parkir',
                      prefixIcon: Icon(Icons.local_parking_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _parkingAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Alamat lahan',
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _parkingPhotoController,
                    decoration: const InputDecoration(
                      labelText: 'Upload foto lahan',
                      prefixIcon: Icon(Icons.add_photo_alternate_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const ParkingMapPlaceholder(title: 'Pilih titik lokasi pada map'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _locationPointController,
                    decoration: const InputDecoration(
                      labelText: 'Titik lokasi',
                      prefixIcon: Icon(Icons.pin_drop_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  LabeledSlider(
                    label: 'Kapasitas kendaraan',
                    value: _providerCapacity,
                    min: 20,
                    max: 300,
                    divisions: 28,
                    display: '${_providerCapacity.toInt()} slot',
                    onChanged: (value) => setState(() => _providerCapacity = value),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _identityController,
                    decoration: const InputDecoration(
                      labelText: 'Upload KTP / verifikasi identitas',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const InlineNotice(
                    icon: Icons.hourglass_top_rounded,
                    accent: Color(0xFFD97706),
                    message: 'Akun penyedia sedang menunggu verifikasi admin.',
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Daftar',
            icon: Icons.person_add_alt_1_rounded,
            onPressed: () {
              final providerApplication = _mode == AccountMode.provider
                  ? ProviderApplication(
                      parkingName: _parkingNameController.text,
                      address: _parkingAddressController.text,
                      photoLabel: _parkingPhotoController.text,
                      locationLabel: _locationPointController.text,
                      capacity: _providerCapacity.toInt(),
                      identityLabel: _identityController.text,
                    )
                  : null;
              ref.read(appControllerProvider.notifier).register(
                    fullName: _nameController.text,
                    email: _emailController.text,
                    phoneNumber: _phoneController.text,
                    mode: _mode,
                    providerApplication: providerApplication,
                  );
              if (_mode == AccountMode.provider) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Akun penyedia sedang menunggu verifikasi admin.',
                    ),
                  ),
                );
              }
              final controller = ref.read(appControllerProvider.notifier);
              context.go(controller.landingRouteFor(ref.read(appControllerProvider)));
            },
          ),
        ],
      ),
    );
  }
}

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  bool _otpSent = false;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Reset password',
      subtitle: 'Verifikasi akun dengan email atau nomor HP lalu atur ulang password.',
      child: Column(
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: 'Email / nomor HP',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 16),
          if (_otpSent) ...[
            const TextField(
              decoration: InputDecoration(
                labelText: 'Kode OTP',
                prefixIcon: Icon(Icons.password_rounded),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password baru',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
            ),
            const SizedBox(height: 16),
          ],
          PrimaryButton(
            label: _otpSent ? 'Simpan password baru' : 'Kirim OTP',
            icon: _otpSent ? Icons.check_rounded : Icons.sms_rounded,
            onPressed: () {
              if (_otpSent) {
                ref.read(appControllerProvider.notifier).requestPasswordReset();
                context.pop();
              } else {
                setState(() => _otpSent = true);
              }
            },
          ),
        ],
      ),
    );
  }
}

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  bool _agree = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hapus akun')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_rounded,
                  color: Color(0xFFEA580C),
                  size: 34,
                ),
                const SizedBox(height: 18),
                Text(
                  'Konfirmasi hapus akun permanen',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tindakan ini akan menghapus data profil, kendaraan, tiket aktif, dan riwayat transaksi yang terhubung dengan akun Anda.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.slate,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 18),
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password verifikasi',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: _agree,
                  onChanged: (value) => setState(() => _agree = value ?? false),
                  title: const Text('Saya memahami semua data akan hilang.'),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  label: 'Hapus akun permanen',
                  icon: Icons.delete_forever_rounded,
                  color: const Color(0xFFDC2626),
                  onPressed: _agree
                      ? () {
                          ref.read(appControllerProvider.notifier).deleteAccount();
                          context.go('/login');
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProviderVerificationScreen extends ConsumerWidget {
  const ProviderVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final application = state.providerApplication;
    final status = state.accountStatus;
    final statusColor = switch (status) {
      AccountStatus.pending => const Color(0xFFD97706),
      AccountStatus.verified => AppTheme.emerald,
      AccountStatus.rejected => const Color(0xFFDC2626),
    };
    final statusLabel = switch (status) {
      AccountStatus.pending => 'Pending Verification',
      AccountStatus.verified => 'Verified',
      AccountStatus.rejected => 'Rejected',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Status verifikasi provider')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusBadge(label: statusLabel, color: statusColor),
                const SizedBox(height: 16),
                Text(
                  'Akun penyedia ${state.userName}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  status == AccountStatus.pending
                      ? 'Akun penyedia sedang menunggu verifikasi admin.'
                      : status == AccountStatus.verified
                          ? 'Akun sudah diverifikasi dan siap mengelola dashboard admin.'
                          : 'Pengajuan provider perlu diperbarui sebelum diverifikasi.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.slate,
                        height: 1.5,
                      ),
                ),
                if (application != null) ...[
                  const SizedBox(height: 18),
                  SummaryRow(label: 'Tempat parkir', value: application.parkingName),
                  SummaryRow(label: 'Alamat lahan', value: application.address),
                  SummaryRow(label: 'Titik lokasi', value: application.locationLabel),
                  SummaryRow(
                    label: 'Kapasitas kendaraan',
                    value: '${application.capacity} slot',
                  ),
                  SummaryRow(label: 'Foto lahan', value: application.photoLabel),
                  SummaryRow(label: 'Verifikasi identitas', value: application.identityLabel),
                ],
                const SizedBox(height: 22),
                if (status == AccountStatus.pending)
                  SecondaryButton(
                    label: 'Masih menunggu verifikasi',
                    icon: Icons.hourglass_top_rounded,
                    onPressed: null,
                  ),
                if (status == AccountStatus.verified)
                  PrimaryButton(
                    label: 'Masuk ke dashboard admin',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => context.go('/admin/dashboard'),
                  ),
                if (status == AccountStatus.rejected)
                  PrimaryButton(
                    label: 'Perbarui data pengajuan',
                    icon: Icons.edit_rounded,
                    onPressed: () => context.go('/register'),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Simulasi verified',
                        icon: Icons.verified_rounded,
                        onPressed: () {
                          ref
                              .read(appControllerProvider.notifier)
                              .setProviderStatus(AccountStatus.verified);
                          context.go('/admin/dashboard');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SecondaryButton(
                        label: 'Simulasi rejected',
                        icon: Icons.close_rounded,
                        onPressed: () {
                          ref
                              .read(appControllerProvider.notifier)
                              .setProviderStatus(AccountStatus.rejected);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
