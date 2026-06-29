import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProviderDocumentService {
  SupabaseProviderDocumentService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<String?> uploadIdentityDocument({
    required String profileId,
    required Uint8List bytes,
    String? fileName,
  }) async {
    final extension = _fileExtension(fileName);
    final path =
        '$profileId/identity-${DateTime.now().millisecondsSinceEpoch}.$extension';

    await _client.storage
        .from('provider-identity-documents')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: _contentType(extension),
            upsert: true,
          ),
        );

    return _client.storage
        .from('provider-identity-documents')
        .getPublicUrl(path);
  }

  String _fileExtension(String? fileName) {
    final value = fileName?.split('.').last.toLowerCase();
    if (value == 'png' || value == 'webp') {
      return value!;
    }
    return 'jpg';
  }

  String _contentType(String extension) => switch (extension) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    _ => 'image/jpeg',
  };
}
