import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

/// Service responsible for generating and validating QR codes for user verification
class QrService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate QR code data for a user
  /// Returns a JSON encoded string that includes:
  /// - User ID
  /// - KYC verification status
  /// - Timestamp
  /// - Verification signature (to prevent spoofing)
  /// Modified: Returns only the User ID for simplicity and security.
  Future<String> generateUserQrData() async {
    // Ensure user is authenticated
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    String userId = currentUser.uid;

    // Optionally, re-fetch user doc to ensure KYC is still verified *before* generating.
    // This adds a slight delay but increases confidence.
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists || (userDoc.data()?['kycStatus'] != 'verified')) {
      throw Exception('User not found or KYC not verified.');
    }

    // Return only the User ID
    return userId;
  }

  /// Generate a signature to verify QR code authenticity
  /// This is a simple implementation and should be enhanced for production
  String _generateSignature(String userId, String kycStatus, String timestamp) {
    // Concatenate the data with a secret key
    // In production, this should be done server-side with a properly secured key
    const String secretKey =
        'BidMyGold_QR_SECRET_KEY'; // Replace with secure key management
    final String data = '$userId:$kycStatus:$timestamp:$secretKey';

    // Create SHA-256 hash
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  /// Verify a QR code data for authenticity and validity
  /// Returns true if the QR is valid, false otherwise
  Future<Map<String, dynamic>> verifyQrData(String qrData) async {
    try {
      // Decode the QR data
      final decodedData = jsonDecode(qrData) as Map<String, dynamic>;

      // Extract data
      final userId = decodedData['userId'] as String?;
      final kycStatus = decodedData['kycStatus'] as String?;
      final timestamp = decodedData['timestamp'] as String?;
      final signature = decodedData['signature'] as String?;

      // Validate required fields
      if (userId == null ||
          kycStatus == null ||
          timestamp == null ||
          signature == null) {
        return {'isValid': false, 'message': 'Invalid QR code format'};
      }

      // Verify signature
      final expectedSignature =
          _generateSignature(userId, kycStatus, timestamp);
      if (signature != expectedSignature) {
        return {'isValid': false, 'message': 'Invalid QR code signature'};
      }

      // Check if KYC is verified
      if (kycStatus != 'verified') {
        return {'isValid': false, 'message': 'User KYC not verified'};
      }

      // Check timestamp for expiration (24 hours validity)
      final qrTimestamp = int.parse(timestamp);
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      const validityPeriod = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

      if (currentTimestamp - qrTimestamp > validityPeriod) {
        return {'isValid': false, 'message': 'QR code has expired'};
      }

      // Verify user still exists and is verified
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return {'isValid': false, 'message': 'User not found'};
      }

      final userData = userDoc.data()!;
      final currentKycStatus = userData['kycStatus'] as String? ?? 'pending';

      if (currentKycStatus != 'verified') {
        return {
          'isValid': false,
          'message': 'User KYC status is no longer verified'
        };
      }

      // QR is valid
      return {
        'isValid': true,
        'message': 'User verified',
        'userData': {
          'userId': userId,
          'name': decodedData['name'] ?? userData['name'] ?? '',
          'phone': decodedData['phone'] ?? userData['phone'] ?? '',
          'kycVerifiedAt': userData['kycVerifiedAt'],
        }
      };
    } catch (e) {
      return {'isValid': false, 'message': 'Error verifying QR code: $e'};
    }
  }

  /// Log QR scan event for auditing purposes
  Future<void> logQrScan({
    required String scannedUserId,
    required String scannedByUserId,
    required bool isValid,
    String? message,
  }) async {
    try {
      await _firestore.collection('qr_scan_logs').add({
        'scannedUserId': scannedUserId,
        'scannedByUserId': scannedByUserId,
        'isValid': isValid,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging QR scan: $e');
    }
  }
}
