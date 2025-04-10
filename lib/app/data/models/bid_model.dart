import 'package:cloud_firestore/cloud_firestore.dart';

class BidModel {
  final String id;
  final String loanRequestId;
  final String pawnbrokerUid;
  final double offeredAmount;
  final double interestRate;
  final int loanTenure;
  final String? note;
  final String status; // pending, accepted, rejected
  final Timestamp createdAt;
  final Timestamp? updatedAt;

  BidModel({
    required this.id,
    required this.loanRequestId,
    required this.pawnbrokerUid,
    required this.offeredAmount,
    required this.interestRate,
    required this.loanTenure,
    this.note,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory BidModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BidModel(
      id: doc.id,
      loanRequestId: data['loanRequestId'] as String,
      pawnbrokerUid: data['pawnbrokerUid'] as String,
      offeredAmount: (data['offeredAmount'] as num).toDouble(),
      interestRate: (data['interestRate'] as num).toDouble(),
      loanTenure: data['loanTenure'] as int,
      note: data['note'] as String?,
      status: data['status'] as String,
      createdAt: data['createdAt'] as Timestamp,
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'loanRequestId': loanRequestId,
      'pawnbrokerUid': pawnbrokerUid,
      'offeredAmount': offeredAmount,
      'interestRate': interestRate,
      'loanTenure': loanTenure,
      'note': note,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Create a copy of this model with some changes
  BidModel copyWith({
    String? id,
    String? loanRequestId,
    String? pawnbrokerUid,
    double? offeredAmount,
    double? interestRate,
    int? loanTenure,
    String? note,
    String? status,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return BidModel(
      id: id ?? this.id,
      loanRequestId: loanRequestId ?? this.loanRequestId,
      pawnbrokerUid: pawnbrokerUid ?? this.pawnbrokerUid,
      offeredAmount: offeredAmount ?? this.offeredAmount,
      interestRate: interestRate ?? this.interestRate,
      loanTenure: loanTenure ?? this.loanTenure,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
