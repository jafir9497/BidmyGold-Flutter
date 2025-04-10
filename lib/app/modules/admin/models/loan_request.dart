import 'package:cloud_firestore/cloud_firestore.dart';

class LoanRequest {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String jewelType;
  final double jewelWeight;
  final String jewelPurity;
  final double requestedAmount;
  final double? approvedAmount;
  final String status; // pending, approved, rejected, completed
  final List<String> photos;
  final String? videoUrl;
  final String? adminNote;
  final DateTime createdAt;
  final DateTime? lastUpdated;
  final String? lastUpdatedBy;
  final String? assignedPawnbrokerId;
  final String? assignedPawnbrokerName;
  final String? bidId;

  LoanRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.jewelType,
    required this.jewelWeight,
    required this.jewelPurity,
    required this.requestedAmount,
    this.approvedAmount,
    required this.status,
    required this.photos,
    this.videoUrl,
    this.adminNote,
    required this.createdAt,
    this.lastUpdated,
    this.lastUpdatedBy,
    this.assignedPawnbrokerId,
    this.assignedPawnbrokerName,
    this.bidId,
  });

  factory LoanRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Handle photos array
    List<String> photosList = [];
    if (data['photos'] != null) {
      photosList = List<String>.from(data['photos']);
    }

    return LoanRequest(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown User',
      userPhone: data['userPhone'] ?? '',
      jewelType: data['jewelType'] ?? '',
      jewelWeight: (data['jewelWeight'] ?? 0).toDouble(),
      jewelPurity: data['jewelPurity'] ?? '22K',
      requestedAmount: (data['requestedAmount'] ?? 0).toDouble(),
      approvedAmount: data['approvedAmount'] != null
          ? (data['approvedAmount'] as num).toDouble()
          : null,
      status: data['status'] ?? 'pending',
      photos: photosList,
      videoUrl: data['videoUrl'],
      adminNote: data['adminNote'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
      lastUpdatedBy: data['lastUpdatedBy'],
      assignedPawnbrokerId: data['assignedPawnbrokerId'],
      assignedPawnbrokerName: data['assignedPawnbrokerName'],
      bidId: data['bidId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'jewelType': jewelType,
      'jewelWeight': jewelWeight,
      'jewelPurity': jewelPurity,
      'requestedAmount': requestedAmount,
      'approvedAmount': approvedAmount,
      'status': status,
      'photos': photos,
      'videoUrl': videoUrl,
      'adminNote': adminNote,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated':
          lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
      'lastUpdatedBy': lastUpdatedBy,
      'assignedPawnbrokerId': assignedPawnbrokerId,
      'assignedPawnbrokerName': assignedPawnbrokerName,
      'bidId': bidId,
    };
  }
}
