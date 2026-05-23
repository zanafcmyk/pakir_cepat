part of 'package:parkir_cepat/app.dart';

class CustomerShell extends StatelessWidget {
  const CustomerShell({
    super.key,
    required this.currentIndex,
    required this.child,
    this.floatingActionButton,
  });

  final int currentIndex;
  final Widget child;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: currentIndex,
      floatingActionButton: floatingActionButton,
      destinations: const [
        ShellDestination(label: 'Home', icon: Icons.home_rounded, route: '/customer/home'),
        ShellDestination(label: 'Map', icon: Icons.map_rounded, route: '/customer/map'),
        ShellDestination(label: 'Tiket', icon: Icons.confirmation_num_rounded, route: '/customer/tickets'),
        ShellDestination(label: 'Notifikasi', icon: Icons.notifications_rounded, route: '/customer/notifications'),
        ShellDestination(label: 'Profil', icon: Icons.person_rounded, route: '/customer/profile'),
      ],
      child: child,
    );
  }
}

class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.currentIndex,
    required this.child,
    this.floatingActionButton,
  });

  final int currentIndex;
  final Widget child;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: currentIndex,
      floatingActionButton: floatingActionButton,
      destinations: const [
        ShellDestination(label: 'Home', icon: Icons.space_dashboard_rounded, route: '/admin/dashboard'),
        ShellDestination(label: 'Map', icon: Icons.map_rounded, route: '/admin/map'),
        ShellDestination(label: 'Monitor', icon: Icons.radar_rounded, route: '/admin/monitoring'),
        ShellDestination(label: 'Notif', icon: Icons.notifications_rounded, route: '/admin/notifications'),
        ShellDestination(label: 'Profil', icon: Icons.person_rounded, route: '/admin/profile'),
      ],
      child: child,
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.currentIndex,
    required this.child,
    required this.destinations,
    this.floatingActionButton,
  });

  final int currentIndex;
  final Widget child;
  final List<ShellDestination> destinations;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [softShadow(AppTheme.slate.withValues(alpha: 0.16))],
          ),
          child: Row(
            children: List.generate(destinations.length, (index) {
              final item = destinations[index];
              final selected = index == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => context.go(item.route),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.blueSoft : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color: selected ? AppTheme.blue : AppTheme.slate,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.label,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: selected ? AppTheme.blue : AppTheme.slate,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class ShellDestination {
  const ShellDestination({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SmartCityIllustration(height: 180),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.slate,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 26),
            PremiumCard(child: child),
          ],
        ),
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.accent,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final Color? accent;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: accent ?? Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [softShadow(AppTheme.slate.withValues(alpha: 0.12))],
      ),
      child: child,
    );
  }
}

class HeaderSection extends StatelessWidget {
  const HeaderSection({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.slate,
                      height: 1.45,
                    ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}

class HeroBanner extends StatelessWidget {
  const HeroBanner({
    super.key,
    required this.title,
    required this.body,
    required this.accent,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String body;
  final Color accent;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, accent.withValues(alpha: 0.78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [softShadow(accent.withValues(alpha: 0.25))],
      ),
      child: Row(
        children: [
          const Expanded(
            child: SmartCityIllustration(height: 130, foreground: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: accent,
                  ),
                  onPressed: onPressed,
                  child: Text(actionLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: const Icon(Icons.tune_rounded),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.action,
    this.onTap,
  });

  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        if (action != null)
          TextButton(onPressed: onTap, child: Text(action!)),
      ],
    );
  }
}

class RoleSelectionCards extends StatelessWidget {
  const RoleSelectionCards({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final AccountMode value;
  final ValueChanged<AccountMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RoleSelectionCard(
            title: 'Pengguna Parkir',
            subtitle: 'Cari parkir, booking slot, tiket QR, dan favorit.',
            icon: Icons.map_rounded,
            selected: value == AccountMode.customer,
            accent: AppTheme.blue,
            onTap: () => onChanged(AccountMode.customer),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RoleSelectionCard(
            title: 'Penyedia Parkir',
            subtitle: 'Kelola lahan, dashboard, slot, dan transaksi.',
            icon: Icons.apartment_rounded,
            selected: value == AccountMode.provider,
            accent: AppTheme.emerald,
            onTap: () => onChanged(AccountMode.provider),
          ),
        ),
      ],
    );
  }
}

class RoleSelectionCard extends StatelessWidget {
  const RoleSelectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? accent : AppTheme.slate.withValues(alpha: 0.18),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.slate,
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class InlineNotice extends StatelessWidget {
  const InlineNotice({
    super.key,
    required this.icon,
    required this.accent,
    required this.message,
  });

  final IconData icon;
  final Color accent;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.ink,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class AiRecommendationCard extends StatelessWidget {
  const AiRecommendationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.accent,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String detail;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width - 52) / 2;
    return Container(
      width: math.max(150, width),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.ink),
          const SizedBox(height: 18),
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.slate,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.slate,
                ),
          ),
        ],
      ),
    );
  }
}

class ParkingLotCard extends StatelessWidget {
  const ParkingLotCard({
    super.key,
    required this.lot,
    required this.onDetail,
    required this.onBooking,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final ParkingLot lot;
  final VoidCallback onDetail;
  final VoidCallback onBooking;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: lot.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(Icons.local_parking_rounded, color: lot.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lot.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lot.address,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.slate,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggleFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFavorite ? const Color(0xFFDC2626) : AppTheme.slate,
                ),
              ),
              StatusBadge(
                label: lot.isFull ? 'Penuh' : 'Tersedia',
                color: lot.isFull ? AppTheme.slate : AppTheme.emerald,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: MetricColumn(
                  label: 'Harga',
                  value: '${formatCurrency(lot.pricePerHour)}/jam',
                ),
              ),
              Expanded(
                child: MetricColumn(
                  label: 'Slot',
                  value: '${lot.availableSlots}/${lot.totalSlots}',
                ),
              ),
              Expanded(
                child: MetricColumn(
                  label: 'Jarak',
                  value: '${lot.distanceKm} km',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Detail',
                  icon: Icons.chevron_right_rounded,
                  onPressed: onDetail,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: 'Booking',
                  icon: Icons.flash_on_rounded,
                  onPressed: lot.isFull ? null : onBooking,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ParkingMapCard extends StatelessWidget {
  const ParkingMapCard({
    super.key,
    required this.lots,
    required this.selected,
    required this.onSelect,
  });

  final List<ParkingLot> lots;
  final ParkingLot? selected;
  final ValueChanged<ParkingLot> onSelect;

  @override
  Widget build(BuildContext context) {
    final positions = <Offset>[
      const Offset(0.22, 0.28),
      const Offset(0.68, 0.42),
      const Offset(0.42, 0.74),
      const Offset(0.8, 0.2),
    ];
    return PremiumCard(
      accent: AppTheme.slateSoft,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 320,
        child: Stack(
          children: [
            const Positioned.fill(child: ParkingMapBackground()),
            for (var index = 0; index < lots.length; index++)
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final lot = lots[index];
                    final point = positions[index % positions.length];
                    final isSelected = selected?.id == lot.id;
                    return Stack(
                      children: [
                        Positioned(
                          left: constraints.maxWidth * point.dx - 30,
                          top: constraints.maxHeight * point.dy - 30,
                          child: GestureDetector(
                            onTap: () => onSelect(lot),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: isSelected ? 78 : 64,
                              height: isSelected ? 78 : 64,
                              decoration: BoxDecoration(
                                color: isSelected ? lot.accent : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  softShadow(lot.accent.withValues(alpha: 0.24)),
                                ],
                              ),
                              child: Icon(
                                Icons.local_parking_rounded,
                                color: isSelected ? Colors.white : lot.accent,
                                size: isSelected ? 34 : 28,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  selected == null
                      ? 'Pilih marker'
                      : '${selected!.name} • ${selected!.etaMinutes} menit',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ParkingMapBackground extends StatelessWidget {
  const ParkingMapBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MapPainter());
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = AppTheme.white
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    final guide = Paint()
      ..color = AppTheme.blue.withValues(alpha: 0.15)
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;
    final green = Paint()
      ..color = AppTheme.emeraldSoft
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(26),
      ),
      Paint()..color = AppTheme.blueSoft,
    );

    canvas.drawCircle(Offset(size.width * 0.16, size.height * 0.2), 44, green);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.16), 34, green);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.8), 52, green);

    final path1 = Path()
      ..moveTo(size.width * 0.1, size.height * 0.15)
      ..quadraticBezierTo(
        size.width * 0.34,
        size.height * 0.35,
        size.width * 0.54,
        size.height * 0.3,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.22,
        size.width * 0.88,
        size.height * 0.52,
      );
    final path2 = Path()
      ..moveTo(size.width * 0.18, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.6,
        size.width * 0.48,
        size.height * 0.65,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.72,
        size.width * 0.84,
        size.height * 0.58,
      );
    canvas.drawPath(path1, guide);
    canvas.drawPath(path1, road);
    canvas.drawPath(path2, guide);
    canvas.drawPath(path2, road);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SmartCityIllustration extends StatelessWidget {
  const SmartCityIllustration({
    super.key,
    required this.height,
    this.accent = AppTheme.blue,
    this.icon = Icons.local_parking_rounded,
    this.foreground,
  });

  final double height;
  final Color accent;
  final IconData icon;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final iconColor = foreground ?? accent;
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 10,
            child: Container(
              width: height * 0.9,
              height: height * 0.18,
              decoration: BoxDecoration(
                color: (foreground ?? AppTheme.emeraldSoft).withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            top: height * 0.08,
            left: height * 0.12,
            child: _BuildingBlock(
              width: height * 0.17,
              height: height * 0.46,
              color: foreground?.withValues(alpha: 0.22) ?? AppTheme.blueSoft,
            ),
          ),
          Positioned(
            top: height * 0.02,
            right: height * 0.14,
            child: _BuildingBlock(
              width: height * 0.2,
              height: height * 0.58,
              color: foreground?.withValues(alpha: 0.22) ?? AppTheme.emeraldSoft,
            ),
          ),
          Positioned(
            bottom: height * 0.12,
            child: Container(
              width: height * 0.46,
              height: height * 0.34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: foreground == null ? 1 : 0.18),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: foreground?.withValues(alpha: 0.5) ?? accent.withValues(alpha: 0.16),
                ),
                boxShadow: foreground == null
                    ? [softShadow(accent.withValues(alpha: 0.16))]
                    : null,
              ),
              child: Icon(icon, color: iconColor, size: height * 0.2),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildingBlock extends StatelessWidget {
  const _BuildingBlock({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(10),
        itemCount: 12,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class MiniInfoTile extends StatelessWidget {
  const MiniInfoTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: PremiumCard(
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.slate,
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right_rounded, color: AppTheme.slate),
          ],
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color = AppTheme.blue,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.ink,
          side: BorderSide(color: AppTheme.blue.withValues(alpha: 0.16)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class ChoiceItem<T> {
  const ChoiceItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  final T value;
  final String label;
  final IconData icon;
}

class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  final List<ChoiceItem<T>> items;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppTheme.slateSoft,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: items.map((item) {
          final selected = item.value == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(item.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: selected
                      ? [softShadow(AppTheme.slate.withValues(alpha: 0.08))]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, color: selected ? AppTheme.blue : AppTheme.slate),
                    const SizedBox(height: 8),
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: selected ? AppTheme.blue : AppTheme.slate,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  const InfoChip({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.slateSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.blue),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class MetricColumn extends StatelessWidget {
  const MetricColumn({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.slate,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.slate,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? AppTheme.ink,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        children: [
          const SmartCityIllustration(height: 140, accent: AppTheme.emerald),
          const SizedBox(height: 18),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.slate,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: actionLabel,
            icon: Icons.arrow_forward_rounded,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class NotificationsList extends StatelessWidget {
  const NotificationsList({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final String title;
  final String subtitle;
  final List<NoticeItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        HeaderSection(title: title, subtitle: subtitle),
        const SizedBox(height: 18),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PremiumCard(
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: item.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(item.icon, color: item.accent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.message,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.slate,
                                height: 1.45,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.timeLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.slate,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
  });

  final String label;
  final String value;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width - 54) / 2;
    return Container(
      width: math.max(150, width),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [softShadow(AppTheme.slate.withValues(alpha: 0.12))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.slate,
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.sizeOf(context).width - 54) / 2;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: math.max(150, width),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.ink),
            const SizedBox(height: 24),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class RevenueChart extends StatelessWidget {
  const RevenueChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 12,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: 3,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.slate.withValues(alpha: 0.14),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 3,
              reservedSize: 28,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.slate,
                    ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                final text = value.toInt() >= 0 && value.toInt() < labels.length
                    ? labels[value.toInt()]
                    : '';
                return Text(
                  text,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.slate,
                      ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 3.5),
              FlSpot(1, 5.2),
              FlSpot(2, 4.6),
              FlSpot(3, 8.4),
              FlSpot(4, 7.8),
              FlSpot(5, 9.6),
              FlSpot(6, 11),
            ],
            isCurved: true,
            color: AppTheme.blue,
            barWidth: 4,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, point, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: AppTheme.emerald,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.blue.withValues(alpha: 0.24),
                  AppTheme.blue.withValues(alpha: 0.02),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ParkingMapPlaceholder extends StatelessWidget {
  const ParkingMapPlaceholder({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: AppTheme.slateSoft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_rounded, size: 40, color: AppTheme.blue),
            const SizedBox(height: 10),
            Text(title),
          ],
        ),
      ),
    );
  }
}

class LabeledSlider extends StatelessWidget {
  const LabeledSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String display;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Spacer(),
            Text(
              display,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.blue,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppTheme.blue,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

BoxShadow softShadow(Color color) => BoxShadow(
      color: color,
      blurRadius: 24,
      offset: const Offset(0, 12),
    );
