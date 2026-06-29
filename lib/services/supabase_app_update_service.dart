import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppUpdateInfo {
  const AppUpdateInfo({
    required this.currentVersion,
    required this.currentBuild,
    required this.latestVersion,
    required this.latestBuild,
    required this.minimumBuild,
    required this.downloadUrl,
    required this.releaseNotes,
  });

  final String currentVersion;
  final int currentBuild;
  final String latestVersion;
  final int latestBuild;
  final int minimumBuild;
  final String downloadUrl;
  final String releaseNotes;

  bool get isAvailable => latestBuild > currentBuild;
  bool get isRequired => minimumBuild > currentBuild;
}

class SupabaseAppUpdateService {
  SupabaseAppUpdateService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<AppUpdateInfo?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;
      final platform = _platformKey;

      final rows = await _client
          .from('app_versions')
          .select(
            'latest_version, latest_build, minimum_build, download_url, release_notes, is_active',
          )
          .eq('platform', platform)
          .eq('is_active', true)
          .order('latest_build', ascending: false)
          .limit(1);

      if (rows.isEmpty) {
        return null;
      }

      final row = rows.first;
      final latestBuild = _asInt(row['latest_build']);
      final minimumBuild = _asInt(row['minimum_build']);
      final downloadUrl = (row['download_url'] as String?)?.trim() ?? '';
      if (latestBuild <= currentBuild || downloadUrl.isEmpty) {
        return null;
      }

      return AppUpdateInfo(
        currentVersion: packageInfo.version,
        currentBuild: currentBuild,
        latestVersion:
            (row['latest_version'] as String?) ?? packageInfo.version,
        latestBuild: latestBuild,
        minimumBuild: minimumBuild,
        downloadUrl: downloadUrl,
        releaseNotes: (row['release_notes'] as String?) ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  String get _platformKey {
    if (kIsWeb) {
      return 'web';
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.windows => 'windows',
      TargetPlatform.linux => 'linux',
      TargetPlatform.fuchsia => 'android',
    };
  }

  int _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
