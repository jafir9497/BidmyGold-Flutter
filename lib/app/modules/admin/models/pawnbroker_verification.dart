import 'package:cloud_firestore/cloud_firestore.dart';

class PawnbrokerVerification {
  final String id;
  final String userId;
  final String shopName;
  final String ownerName;
  final String address;
  final String city;
  final String state;
  final String pinCode;
  final String phone;
  final String email;
  final String licenseNumber;
  final String licenseUrl;
  final String idProofUrl;
  final String verificationStatus;
  final String rejectionReason;
  final DateTime createdAt;
  final DateTime? verifiedAt;
  final String? verifiedBy;

  PawnbrokerVerification({
    required this.id,
    required this.userId,
    required this.shopName,
    required this.ownerName,
    required this.address,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.phone,
    required this.email,
    required this.licenseNumber,
    required this.licenseUrl,
    required this.idProofUrl,
    required this.verificationStatus,
    this.rejectionReason = '',
    required this.createdAt,
    this.verifiedAt,
    this.verifiedBy,
  });

  factory PawnbrokerVerification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PawnbrokerVerification(
      id: doc.id,
      userId: data['userId'] ?? '',
      shopName: data['shopName'] ?? '',
      ownerName: data['ownerName'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      pinCode: data['pinCode'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      licenseNumber: data['licenseNumber'] ?? '',
      licenseUrl: data['licenseUrl'] ?? '',
      idProofUrl: data['idProofUrl'] ?? '',
      verificationStatus: data['verificationStatus'] ?? 'pending',
      rejectionReason: data['rejectionReason'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      verifiedAt: (data['verifiedAt'] as Timestamp?)?.toDate(),
      verifiedBy: data['verifiedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'shopName': shopName,
      'ownerName': ownerName,
      'address': address,
      'city': city,
      'state': state,
      'pinCode': pinCode,
      'phone': phone,
      'email': email,
      'licenseNumber': licenseNumber,
      'licenseUrl': licenseUrl,
      'idProofUrl': idProofUrl,
      'verificationStatus': verificationStatus,
      'rejectionReason': rejectionReason,
      'createdAt': Timestamp.fromDate(createdAt),
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'verifiedBy': verifiedBy,
    };
  }
}
