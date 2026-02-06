import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _cloudName = 'dkgbs1bhc';
  static const String _apiKey = '925814886463737';
  static const String _apiSecret = 'ph2UJYjo1h5QMgOO2iQMr3DK6ho';
  static const String _uploadPreset = 'ml_default';
  
  // Use 'auto' to let Cloudinary determine file type
  static String get _uploadUrl => 
      'https://api.cloudinary.com/v1_1/$_cloudName/auto/upload';

  /// Uploads a file (image, pdf, doc, etc) to Cloudinary
  /// Returns the secure URL on success, null on failure
  Future<String?> uploadFile(File file, {
  String? folder,
  String? publicId,
  Function(double)? onProgress,
}) async {
  try {
    final uri = Uri.parse(_uploadUrl);
    final request = http.MultipartRequest('POST', uri);

    // Add authentication
    request.fields['upload_preset'] = _uploadPreset;
    request.fields['api_key'] = _apiKey;

    // Optional parameters
    if (folder != null) request.fields['folder'] = folder;
    if (publicId != null) request.fields['public_id'] = publicId;

    // Add the file
    final fileLength = await file.length();
    final fileStream = http.ByteStream(file.openRead());
    final multipartFile = http.MultipartFile(
      'file',
      fileStream,
      fileLength,
      filename: file.path.split('/').last,
    );
    request.files.add(multipartFile);

    // Send the request
    final streamedResponse = await request.send();

    // Track progress if callback provided
    int bytesReceived = 0;
    final transformedStream = streamedResponse.stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          bytesReceived += data.length;
          if (onProgress != null && fileLength > 0) {
            onProgress(bytesReceived / fileLength);
          }
          sink.add(data);
        },
      ),
    );

    // Convert the transformed stream to a normal Response
    final chunks = <List<int>>[];
    await transformedStream.forEach((chunk) {
      chunks.add(chunk as List<int>);
    });
    final responseBytes = chunks.expand((chunk) => chunk).toList();
    final response = http.Response.bytes(
      responseBytes,
      streamedResponse.statusCode,
      request: streamedResponse.request,
      headers: streamedResponse.headers,
      isRedirect: streamedResponse.isRedirect,
      persistentConnection: streamedResponse.persistentConnection,
    );

    // Parse JSON response
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['secure_url'] as String;
    } else {
      final jsonData = jsonDecode(response.body);
      final errorMessage = jsonData['error']?['message'] ?? 'Unknown error';
      print('Cloudinary Error: $errorMessage');
      return null;
    }
  } catch (e) {
    print('Upload Failed: $e');
    return null;
  }
}


  /// Delete a file from Cloudinary using its public ID
  Future<bool> deleteFile(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final signature = _generateSignature(publicId, timestamp);
      
      final response = await http.post(
        Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/destroy'),
        body: {
          'public_id': publicId,
          'timestamp': timestamp.toString(),
          'api_key': _apiKey,
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['result'] == 'ok';
      }
      return false;
    } catch (e) {
      print('Delete Failed: $e');
      return false;
    }
  }

  /// Generate signature for authenticated requests
  String _generateSignature(String publicId, int timestamp) {
    // This is a simplified version - in production, generate signature server-side
    // For now, we'll use the upload preset which doesn't require signature
    return '';
  }

  /// Get optimized image URL with transformations
  String getOptimizedUrl(
    String originalUrl, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
  }) {
    final parts = originalUrl.split('/upload/');
    if (parts.length != 2) return originalUrl;

    final transformations = <String>[];
    
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    transformations.add('q_$quality');
    transformations.add('f_$format');

    final transformation = transformations.join(',');
    return '${parts[0]}/upload/$transformation/${parts[1]}';
  }
}