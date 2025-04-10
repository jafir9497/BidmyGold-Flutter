import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLogEntry {
  final String id;
  final String adminId;
  final String adminName;
  final String action;
  final Timestamp timestamp;
  // Add other fields if logged, e.g., ipAddress, targetId

  AdminLogEntry({
    required this.id,
    required this.adminId,
    required this.adminName,
    required this.action,
    required this.timestamp,
  });

  factory AdminLogEntry.fromFirestore(DocumentSnapshot doc) {
    final data =
        doc.data() as Map<String, dynamic>? ?? {}; // Handle potential null data
    return AdminLogEntry(
      id: doc.id,
      adminId: data['adminId'] as String? ?? 'unknown',
      adminName: data['adminName'] as String? ?? 'Unknown Admin',
      action: data['action'] as String? ?? 'No action recorded',
      timestamp:
          data['timestamp'] as Timestamp? ?? Timestamp.now(), // Provide default
    );
  }
}
