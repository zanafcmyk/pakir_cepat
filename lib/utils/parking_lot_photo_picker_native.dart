import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class PickedParkingLotPhoto {
  const PickedParkingLotPhoto({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

Future<PickedParkingLotPhoto?> pickParkingLotPhoto() async {
  final image = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 1600,
    imageQuality: 85,
  );
  if (image == null) return null;

  return PickedParkingLotPhoto(
    name: image.name,
    bytes: await image.readAsBytes(),
  );
}
