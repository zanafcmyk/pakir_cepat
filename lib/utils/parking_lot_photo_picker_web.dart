import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

class PickedParkingLotPhoto {
  const PickedParkingLotPhoto({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

Future<PickedParkingLotPhoto?> pickParkingLotPhoto() async {
  final completer = Completer<web.File?>();
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = 'image/*'
    ..style.position = 'fixed'
    ..style.left = '-9999px'
    ..style.top = '-9999px';

  input.onchange = (web.Event _) {
    final files = input.files;
    final file = files == null || files.length == 0 ? null : files.item(0);
    if (!completer.isCompleted) {
      completer.complete(file);
    }
  }.toJS;

  input.oncancel = (web.Event _) {
    if (!completer.isCompleted) {
      completer.complete(null);
    }
  }.toJS;

  input.onerror = (web.Event event) {
    if (!completer.isCompleted) {
      completer.completeError(event);
    }
  }.toJS;

  web.document.body?.append(input);
  input.click();

  try {
    final file = await completer.future;
    if (file == null) return null;
    if (!file.type.startsWith('image/')) {
      throw const FormatException('File yang dipilih harus berupa gambar.');
    }

    final buffer = await file.arrayBuffer().toDart;
    return PickedParkingLotPhoto(
      name: file.name,
      bytes: buffer.toDart.asUint8List(),
    );
  } finally {
    input.remove();
  }
}
