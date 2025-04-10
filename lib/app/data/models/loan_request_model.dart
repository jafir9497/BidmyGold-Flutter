import 'package:cloud_firestore/cloud_firestore.dart';

class LoanRequestModel {
  final String id;
  final String userId;
  final String jewelType;
  final double jewelWeight;
  final String jewelPurity;
  final double loanAmount;
  final String loanPurpose;
  final int loanTenure;
  final double estimatedMonthlyPayment;
  final List<String> jewelPhotoUrls;
  final String? jewelVideoUrl;
  final String status;
  final Timestamp createdAt;
  final GeoPoint? location;
  final String? description;

  LoanRequestModel({
    required this.id,
    required this.userId,
    required this.jewelType,
    required this.jewelWeight,
    required this.jewelPurity,
    required this.loanAmount,
    required this.loanPurpose,
    required this.loanTenure,
    required this.estimatedMonthlyPayment,
    required this.jewelPhotoUrls,
    this.jewelVideoUrl,
    required this.status,
    required this.createdAt,
    this.location,
    this.description,
  });

  factory LoanRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LoanRequestModel(
      id: doc.id,
      userId: data['userId'] as String,
      jewelType: data['jewelType'] as String,
      jewelWeight: (data['jewelWeight'] as num).toDouble(),
      jewelPurity: data['jewelPurity'] as String,
      loanAmount: (data['loanAmount'] as num).toDouble(),
      loanPurpose: data['loanPurpose'] as String,
      loanTenure: data['loanTenure'] as int,
      estimatedMonthlyPayment:
          (data['estimatedMonthlyPayment'] as num).toDouble(),
      jewelPhotoUrls: List<String>.from(data['jewelPhotoUrls'] ?? []),
      jewelVideoUrl: data['jewelVideoUrl'] as String?,
      status: data['status'] as String,
      createdAt: data['createdAt'] as Timestamp,
      location: data['location'] as GeoPoint?,
      description: data['description'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'jewelType': jewelType,
      'jewelWeight': jewelWeight,
      'jewelPurity': jewelPurity,
      'loanAmount': loanAmount,
      'loanPurpose': loanPurpose,
      'loanTenure': loanTenure,
      'estimatedMonthlyPayment': estimatedMonthlyPayment,
      'jewelPhotoUrls': jewelPhotoUrls,
      'jewelVideoUrl': jewelVideoUrl,
      'status': status,
      'createdAt': createdAt,
      'location': location,
      'description': description,
    };
  }

  LoanRequestModel copyWith({
    String? id,
    String? userId,
    String? jewelType,
    double? jewelWeight,
    String? jewelPurity,
    double? loanAmount,
    String? loanPurpose,
    int? loanTenure,
    double? estimatedMonthlyPayment,
    List<String>? jewelPhotoUrls,
    String? jewelVideoUrl,
    String? status,
    Timestamp? createdAt,
    GeoPoint? location,
    String? description,
  }) {
    return LoanRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      jewelType: jewelType ?? this.jewelType,
      jewelWeight: jewelWeight ?? this.jewelWeight,
      jewelPurity: jewelPurity ?? this.jewelPurity,
      loanAmount: loanAmount ?? this.loanAmount,
      loanPurpose: loanPurpose ?? this.loanPurpose,
      loanTenure: loanTenure ?? this.loanTenure,
      estimatedMonthlyPayment:
          estimatedMonthlyPayment ?? this.estimatedMonthlyPayment,
      jewelPhotoUrls: jewelPhotoUrls ?? this.jewelPhotoUrls,
      jewelVideoUrl: jewelVideoUrl ?? this.jewelVideoUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      description: description ?? this.description,
    );
  }
}
