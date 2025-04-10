import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String kycStatus;
  final bool isActive;
  final bool isPawnbroker;
  final String? pawnbrokerId;
  final DateTime createdAt;
  final DateTime? kycVerifiedAt;
  final String? kycRejectionReason;
  final String? address;
  final String? city;
  final String? state;
  final String? pinCode;
  final String? idProofUrl;
  final String? addressProofUrl;
  final String? selfieUrl;

  AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.kycStatus,
    required this.isActive,
    required this.isPawnbroker,
    this.pawnbrokerId,
    required this.createdAt,
    this.kycVerifiedAt,
    this.kycRejectionReason,
    this.address,
    this.city,
    this.state,
    this.pinCode,
    this.idProofUrl,
    this.addressProofUrl,
    this.selfieUrl,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return AppUser(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      kycStatus: data['kycStatus'] ?? 'pending',
      isActive: data['isActive'] ?? true,
      isPawnbroker: data['isPawnbroker'] ?? false,
      pawnbrokerId: data['pawnbrokerId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      kycVerifiedAt: (data['kycVerifiedAt'] as Timestamp?)?.toDate(),
      kycRejectionReason: data['kycRejectionReason'],
      address: data['address'],
      city: data['city'],
      state: data['state'],
      pinCode: data['pinCode'],
      idProofUrl: data['idProofUrl'],
      addressProofUrl: data['addressProofUrl'],
      selfieUrl: data['selfieUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'kycStatus': kycStatus,
      'isActive': isActive,
      'isPawnbroker': isPawnbroker,
      'pawnbrokerId': pawnbrokerId,
      'createdAt': createdAt,
      'kycVerifiedAt': kycVerifiedAt,
      'kycRejectionReason': kycRejectionReason,
      'address': address,
      'city': city,
      'state': state,
      'pinCode': pinCode,
      'idProofUrl': idProofUrl,
      'addressProofUrl': addressProofUrl,
      'selfieUrl': selfieUrl,
    };
  }
}
