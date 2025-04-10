import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLog {
  final String id;
  final String adminId;
  final String adminName;
  final String action;
  final DateTime timestamp;
  final String? ipAddress;

  ActivityLog({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.action,
    required this.timestamp,
    this.ipAddress,
  });

  factory ActivityLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ActivityLog(
      id: doc.id,
      adminId: data['adminId'] ?? 'unknown',
      adminName: data['adminName'] ?? 'Unknown Admin',
      action: data['action'] ?? 'Unknown action',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ipAddress: data['ipAddress'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'adminId': adminId,
      'adminName': adminName,
      'action': action,
      'timestamp': Timestamp.fromDate(timestamp),
      'ipAddress': ipAddress,
    };
  }
}
