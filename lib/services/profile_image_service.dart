import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileImageService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source, imageQuality: 70);
    if (image == null) return null;
    return File(image.path);
  }

  // TODO: Replace with your Cloudinary cloud name and unsigned upload preset,
  // or switch to signed uploads with apiSecret.
  static const String _cloudName = 'YOUR_CLOUD_NAME';
  static const String _uploadPreset = 'YOUR_UNSIGNED_UPLOAD_PRESET';
  static const String _apiKey = '925814886463737';

  Future<String> uploadImage(File file, String userId) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['public_id'] = 'profile_photos/$userId'
      ..fields['api_key'] = _apiKey
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Cloudinary upload failed: $body');
    }

    final data = jsonDecode(body) as Map<String, dynamic>;
    return data['secure_url'] as String;
  }

  Future<String> saveImageOffline(File file, String userId) async {
    final dir = await getApplicationDocumentsDirectory();
    final target = File('${dir.path}/profile_$userId.jpg');
    await file.copy(target.path);
    return target.path;
  }
}
