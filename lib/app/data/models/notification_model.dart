import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final Map<String, dynamic>?
      data; // For navigation context (e.g., {'type': 'appointment', 'id': '...'})
  final bool read;
  final Timestamp createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.data,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final mapData = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: mapData['userId'] ?? '',
      title: mapData['title'] ?? 'No Title',
      body: mapData['body'] ?? 'No Content',
      data: mapData['data'] != null
          ? Map<String, dynamic>.from(mapData['data'])
          : null,
      read: mapData['read'] ?? false,
      createdAt: mapData['createdAt'] ?? Timestamp.now(),
    );
  }

  // Method to create a copy with updated read status
  NotificationModel copyWith({bool? read}) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      body: body,
      data: data,
      read: read ?? this.read,
      createdAt: createdAt,
    );
  }
}
