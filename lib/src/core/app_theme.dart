part of 'package:parkir_cepat/app.dart';

class AppTheme {
  static const white = Color(0xFFFFFFFF);
  static const blue = Color(0xFF1F6BFF);
  static const blueSoft = Color(0xFFEAF2FF);
  static const emerald = Color(0xFF0F9D7A);
  static const emeraldSoft = Color(0xFFE8F8F2);
  static const slate = Color(0xFF94A3B8);
  static const slateSoft = Color(0xFFF4F7FB);
  static const ink = Color(0xFF0F172A);

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: white,
      colorScheme: const ColorScheme.light(
        primary: blue,
        secondary: emerald,
        surface: white,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: ink,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: slateSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: blue, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    );
  }
}

String formatCurrency(int amount) => 'Rp ${amount.toString()}';

String formatDateTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year} $hour:$minute';
}

String formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final safe = minutes < 0 ? 0 : minutes;
  final hours = safe ~/ 60;
  final remainMinutes = safe % 60;
  if (hours > 0) {
    return '${hours}j ${remainMinutes.toString().padLeft(2, '0')}m';
  }
  return '${remainMinutes}m';
}
