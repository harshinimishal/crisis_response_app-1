import 'package:url_launcher/url_launcher.dart';
import 'package:telephony/telephony.dart';

class SMSService {
  final Telephony telephony = Telephony.instance;
  
  // Send SMS to a single number
  Future<Map<String, dynamic>> sendSMS({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Clean phone number
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      await telephony.sendSms(
        to: cleanNumber,
        message: message,
      );
      
      return {
        'success': true,
        'message': 'SMS sent successfully',
      };
    } catch (e) {
      print('Error sending SMS: $e');
      return {
        'success': false,
        'message': 'Failed to send SMS: ${e.toString()}',
      };
    }
  }
  
  // Send SMS to multiple contacts
  Future<Map<String, dynamic>> sendBulkSMS({
    required List<String> phoneNumbers,
    required String message,
  }) async {
    try {
      int successCount = 0;
      int failCount = 0;
      
      for (String number in phoneNumbers) {
        try {
          String cleanNumber = number.replaceAll(RegExp(r'[^\d+]'), '');
          await telephony.sendSms(
            to: cleanNumber,
            message: message,
          );
          successCount++;
        } catch (e) {
          print('Failed to send SMS to $number: $e');
          failCount++;
        }
      }
      
      return {
        'success': true,
        'message': 'Sent $successCount SMS, $failCount failed',
        'successCount': successCount,
        'failCount': failCount,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send bulk SMS: ${e.toString()}',
      };
    }
  }
  
  // Send emergency SOS SMS
  Future<Map<String, dynamic>> sendEmergencySOS({
    required List<Map<String, dynamic>> contacts,
    required double latitude,
    required double longitude,
    String? customMessage,
  }) async {
    try {
      String locationUrl = 'https://maps.google.com/?q=$latitude,$longitude';
      
      String message = customMessage ?? 
        '🚨 EMERGENCY ALERT 🚨\n\n'
        'This is an automated emergency message.\n\n'
        'I need immediate assistance at:\n'
        '$locationUrl\n\n'
        'Please call me or emergency services immediately.\n\n'
        'Sent from Emergency Safety App';
      
      List<String> phoneNumbers = contacts
          .map((contact) => contact['phoneNumber'] as String)
          .toList();
      
      return await sendBulkSMS(
        phoneNumbers: phoneNumbers,
        message: message,
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send emergency SOS: ${e.toString()}',
      };
    }
  }
  
  // Open SMS app with pre-filled message
  Future<bool> openSMSApp({
    required String phoneNumber,
    String? message,
  }) async {
    try {
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      String smsUri = 'sms:$cleanNumber';
      
      if (message != null && message.isNotEmpty) {
        String encodedMessage = Uri.encodeComponent(message);
        smsUri += '?body=$encodedMessage';
      }
      
      Uri uri = Uri.parse(smsUri);
      
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      
      return false;
    } catch (e) {
      print('Error opening SMS app: $e');
      return false;
    }
  }
  
  // Request SMS permissions
  Future<bool> requestSMSPermissions() async {
    try {
      bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
      return permissionsGranted ?? false;
    } catch (e) {
      print('Error requesting SMS permissions: $e');
      return false;
    }
  }
  
  // Check if SMS permissions are granted
  Future<bool> checkSMSPermissions() async {
    try {
      // This is a simplified check
      // In production, you'd want more robust permission checking
      return true;
    } catch (e) {
      print('Error checking SMS permissions: $e');
      return false;
    }
  }
}