import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  // Check if user is logged in
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign Up with Email and Password
  Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      // Create user account
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update display name
      await userCredential.user?.updateDisplayName(fullName);
      await userCredential.user?.reload();

      // Create user profile in Firestore
      await _firebaseFirestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': fullName,
        'fullName': fullName, // Keep for backward compatibility
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'isEmailVerified': false,
        'accountStatus': 'active',
        'permissionsGranted': [],
        'safeMode': false,
        'emergencyLocation': false,
        'impactDetection': false,
        'safetyAlerts': false,
        'rescueMesh': false,
        'emergencyContacts': [],
      });

      return {
        'success': true,
        'message': 'Sign up successful',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _handleAuthException(e),
        'error': e.code,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
        'error': e.toString(),
      };
    }
  }

  // Login with Email and Password
  Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // Update last login time
      await _firebaseFirestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Login successful',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _handleAuthException(e),
        'error': e.code,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
        'error': e.toString(),
      };
    }
  }

  // Send Email Verification
  Future<Map<String, dynamic>> verifyEmail() async {
    try {
      User? user = _firebaseAuth.currentUser;

      if (user == null) {
        return {
          'success': false,
          'message': 'No user logged in',
        };
      }

      await user.sendEmailVerification();

      return {
        'success': true,
        'message': 'Verification email sent successfully',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _handleAuthException(e),
        'error': e.code,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
        'error': e.toString(),
      };
    }
  }

  // Send Password Reset Email
  Future<Map<String, dynamic>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);

      return {
        'success': true,
        'message': 'Password reset email sent successfully',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _handleAuthException(e),
        'error': e.code,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
        'error': e.toString(),
      };
    }
  }

  // Reset password (alias for compatibility)
  Future<Map<String, dynamic>> resetPassword({
    required String newPassword,
  }) async {
    try {
      User? user = _firebaseAuth.currentUser;

      if (user == null) {
        return {
          'success': false,
          'message': 'No user logged in',
        };
      }

      await user.updatePassword(newPassword);

      return {
        'success': true,
        'message': 'Password reset successfully',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _handleAuthException(e),
        'error': e.code,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
        'error': e.toString(),
      };
    }
  }
  // Update User Permissions
  Future<Map<String, dynamic>> updateUserPermissions({
    required bool emergencyLocation,
    required bool impactDetection,
    required bool safetyAlerts,
    required bool rescueMesh,
  }) async {
    try {
      User? user = _firebaseAuth.currentUser;

      if (user == null) {
        return {
          'success': false,
          'message': 'No user logged in',
        };
      }

      await _firebaseFirestore.collection('users').doc(user.uid).update({
        'emergencyLocation': emergencyLocation,
        'impactDetection': impactDetection,
        'safetyAlerts': safetyAlerts,
        'rescueMesh': rescueMesh,
        'permissionsUpdatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Permissions updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update permissions',
        'error': e.toString(),
      };
    }
  }

  // Get User Profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      User? user = _firebaseAuth.currentUser;

      if (user == null) {
        return null;
      }

      DocumentSnapshot doc =
          await _firebaseFirestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // Get User Permissions
  Future<Map<String, bool>> getUserPermissions() async {
    try {
      User? user = _firebaseAuth.currentUser;

      if (user == null) {
        return {
          'emergencyLocation': false,
          'impactDetection': false,
          'safetyAlerts': false,
          'rescueMesh': false,
        };
      }

      DocumentSnapshot doc =
          await _firebaseFirestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'emergencyLocation': data['emergencyLocation'] ?? false,
          'impactDetection': data['impactDetection'] ?? false,
          'safetyAlerts': data['safetyAlerts'] ?? false,
          'rescueMesh': data['rescueMesh'] ?? false,
        };
      }

      return {
        'emergencyLocation': false,
        'impactDetection': false,
        'safetyAlerts': false,
        'rescueMesh': false,
      };
    } catch (e) {
      print('Error fetching permissions: $e');
      return {
        'emergencyLocation': false,
        'impactDetection': false,
        'safetyAlerts': false,
        'rescueMesh': false,
      };
    }
  }

  // Update User Profile
  Future<Map<String, dynamic>> updateUserProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      User? user = _firebaseAuth.currentUser;

      if (user == null) {
        return {
          'success': false,
          'message': 'No user logged in',
        };
      }

      // Update display name in Auth
      await user.updateDisplayName(fullName);
      await user.reload();

      // Update in Firestore
      await _firebaseFirestore.collection('users').doc(user.uid).update({
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Profile updated successfully',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _handleAuthException(e),
        'error': e.code,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
        'error': e.toString(),
      };
    }
  }

  // Update Safe Mode Status
  Future<Map<String, dynamic>> updateSafeModeStatus({
    required bool safeMode,
  }) async {
    try {
      User? user = _firebaseAuth.currentUser;

      if (user == null) {
        return {
          'success': false,
          'message': 'No user logged in',
        };
      }

      await _firebaseFirestore.collection('users').doc(user.uid).update({
        'safeMode': safeMode,
        'safeModeUpdatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Safe mode status updated',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update safe mode',
        'error': e.toString(),
      };
    }
  }

  // Log Emergency Report
  Future<Map<String, dynamic>> logEmergencyReport({
    required String emergencyType,
    required double latitude,
    required double longitude,
    required String description,
  }) async {
    try {
      User? user = _firebaseAuth.currentUser;

      if (user == null) {
        return {
          'success': false,
          'message': 'No user logged in',
        };
      }

      // Add to main emergency reports collection
      DocumentReference reportRef = await _firebaseFirestore
          .collection('emergencyReports')
          .add({
        'userId': user.uid,
        'emergencyType': emergencyType,
        'latitude': latitude,
        'longitude': longitude,
        'location': GeoPoint(latitude, longitude),
        'description': description,
        'reportedAt': FieldValue.serverTimestamp(),
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'reported',
        'resolved': false,
        'notificationsSent': false,
      });

      // Also add to user's subcollection for easy access
      await _firebaseFirestore
          .collection('users')
          .doc(user.uid)
          .collection('emergencyReports')
          .doc(reportRef.id)
          .set({
        'emergencyType': emergencyType,
        'latitude': latitude,
        'longitude': longitude,
        'description': description,
        'reportedAt': FieldValue.serverTimestamp(),
        'status': 'reported',
      });

      return {
        'success': true,
        'message': 'Emergency report logged successfully',
        'reportId': reportRef.id,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to log emergency report',
        'error': e.toString(),
      };
    }
  }

  // Add Emergency Contact
  Future<Map<String, dynamic>> addEmergencyContact({
    required String name,
    required String phoneNumber,
    required String relationship,
  }) async {
    try {
      User? user = _firebaseAuth.currentUser;

      if (user == null) {
        return {
          'success': false,
          'message': 'No user logged in',
        };
      }

      await _firebaseFirestore.collection('users').doc(user.uid).update({
        'emergencyContacts': FieldValue.arrayUnion([
          {
            'name': name,
            'phoneNumber': phoneNumber,
            'relationship': relationship,
            'addedAt': DateTime.now().toIso8601String(),
          }
        ]),
      });

      return {
        'success': true,
        'message': 'Emergency contact added successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to add emergency contact',
        'error': e.toString(),
      };
    }
  }

  // Get Emergency Contacts
  Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    try {
      User? user = _firebaseAuth.currentUser;

      if (user == null) {
        return [];
      }

      DocumentSnapshot doc =
          await _firebaseFirestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['emergencyContacts'] != null) {
          return List<Map<String, dynamic>>.from(data['emergencyContacts']);
        }
      }

      return [];
    } catch (e) {
      print('Error fetching emergency contacts: $e');
      return [];
    }
  }

  // Remove Emergency Contact
  Future<Map<String, dynamic>> removeEmergencyContact({
    required String phoneNumber,
  }) async {
    try {
      User? user = _firebaseAuth.currentUser;

      if (user == null) {
        return {
          'success': false,
          'message': 'No user logged in',
        };
      }

      // Get current contacts
      List<Map<String, dynamic>> contacts = await getEmergencyContacts();
      
      // Remove the contact with matching phone number
      contacts.removeWhere((contact) => contact['phoneNumber'] == phoneNumber);

      // Update Firestore
      await _firebaseFirestore.collection('users').doc(user.uid).update({
        'emergencyContacts': contacts,
      });

      return {
        'success': true,
        'message': 'Emergency contact removed successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to remove emergency contact',
        'error': e.toString(),
      };
    }
  }

  // Sign Out
  Future<Map<String, dynamic>> signOut() async {
    try {
      await _firebaseAuth.signOut();

      return {
        'success': true,
        'message': 'Signed out successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to sign out',
        'error': e.toString(),
      };
    }
  }

  // Delete Account
  Future<Map<String, dynamic>> deleteAccount({
    required String password,
  }) async {
    try {
      User? user = _firebaseAuth.currentUser;

      if (user == null) {
        return {
          'success': false,
          'message': 'No user logged in',
        };
      }

      // Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Delete user document from Firestore
      await _firebaseFirestore.collection('users').doc(user.uid).delete();

      // Delete user account
      await user.delete();

      return {
        'success': true,
        'message': 'Account deleted successfully',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _handleAuthException(e),
        'error': e.code,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
        'error': e.toString(),
      };
    }
  }

  // Handle Auth Exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'user-not-found':
        return 'No user found with that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'user-disabled':
        return 'The user account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'requires-recent-login':
        return 'Please log in again to perform this action.';
      default:
        return 'An authentication error occurred: ${e.message}';
    }
  }
}