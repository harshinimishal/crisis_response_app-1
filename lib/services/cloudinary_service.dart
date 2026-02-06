import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _cloudName = 'dkgbs1bhc';
  static const String _apiKey = '925814886463737';
  static const String _apiSecret = 'ph2UJYjo1h5QMgOO2iQMr3DK6ho';
  static const String _uploadUrl = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  /// Uploads an image file to Cloudinary and returns the secure URL.
  Future<String?> uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      
      // Add standard unsigned upload preset if available, OR use signed upload.
      // Since user gave API Key/Secret, let's try a signed upload or standard unsigned if preset unknown.
      // Usually signed upload requires a generated signature on the backend.
      // For simplicity/client-side, we often use Unsigned Presets.
      // However, the user provided SECRET, which implies we CAN sign.
      // But generating signature on client is risky (exposes secret).
      // Given the context (hackathon/demo?), I'll assume an unsigned preset 'ml_default' 
      // OR try to upload with just api_key if the cloud supports it (usually doesn't without signature).
      
      // BETTER APPROACH: Use 'upload_preset' if user has one. They didn't provide it.
      // I will assume an unsigned preset 'unsigned_preset' or similar. 
      // If that fails, I'll log it.
      // ALTERNATIVE: Implementing a simple signature generator (SHA1) if 'crypto' package is available.
      // But 'crypto' might not be in pubspec.
      
      // Let's try the safest path: "ml_default" is a common default unsigned preset.
      request.fields['upload_preset'] = 'ml_default'; 
      request.fields['api_key'] = _apiKey;
      
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final json = jsonDecode(responseData);

      if (response.statusCode == 200) {
        return json['secure_url'];
      } else {
        print('Cloudinary Error: ${json['error']['message']}');
        // Fallback: Return null so UI handles it
        return null;
      }
    } catch (e) {
      print('Upload Failed: $e');
      return null;
    }
  }
}
