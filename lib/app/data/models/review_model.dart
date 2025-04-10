import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id; // Document ID
  final String pawnbrokerId;
  final String userId;
  final String? userName; // Denormalized for easier display
  final String? userProfilePicUrl; // Optional denormalized user photo
  final int rating; // e.g., 1 to 5
  final String? reviewText;
  final Timestamp createdAt;
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectionReason; // If status is 'rejected'
  final String? reviewedByAdminId; // If reviewed
  final Timestamp? reviewedAt; // If reviewed

  ReviewModel({
    required this.id,
    required this.pawnbrokerId,
    required this.userId,
    this.userName,
    this.userProfilePicUrl,
    required this.rating,
    this.reviewText,
    required this.createdAt,
    this.status = 'pending', // Default to pending for moderation
    this.rejectionReason,
    this.reviewedByAdminId,
    this.reviewedAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      pawnbrokerId: data['pawnbrokerId'] as String,
      userId: data['userId'] as String,
      userName: data['userName'] as String?,
      userProfilePicUrl: data['userProfilePicUrl'] as String?,
      rating: data['rating'] as int? ?? 0,
      reviewText: data['reviewText'] as String?,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      status: data['status'] as String? ?? 'pending',
      rejectionReason: data['rejectionReason'] as String?,
      reviewedByAdminId: data['reviewedByAdminId'] as String?,
      reviewedAt: data['reviewedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'pawnbrokerId': pawnbrokerId,
      'userId': userId,
      'userName': userName,
      'userProfilePicUrl': userProfilePicUrl,
      'rating': rating,
      'reviewText': reviewText,
      'createdAt': createdAt,
      'status': status,
      'rejectionReason': rejectionReason,
      'reviewedByAdminId': reviewedByAdminId,
      'reviewedAt': reviewedAt,
    };
  }
}
