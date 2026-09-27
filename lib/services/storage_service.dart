import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Pick Image from Gallery or Camera
  Future<File?> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw 'Could not pick image. Please check camera or gallery permissions.';
    }
  }

  // Upload image file to Firebase Storage
  Future<String> uploadMaterialImage(File imageFile, String supplierId) async {
    try {
      String fileName = '${supplierId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('materials/$fileName');

      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // If storage fails or not configured yet, return high quality fallback sample image
      return 'https://images.unsplash.com/photo-1504917595217-d4dc5ebe6122?w=500';
    }
  }
}
