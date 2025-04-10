import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? city;
  final String? state;
  final String? pinCode;
  final bool kycSubmitted;
  final String kycStatus; // pending, approved, rejected
  final bool hasActiveLoanRequest;
  final Timestamp? lastLoanRequestDate;
  final Timestamp createdAt;
  final Timestamp? updatedAt;
  final Map<String, dynamic>? kycDocuments;
  final GeoPoint? location;
  final bool isDisabled;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.city,
    this.state,
    this.pinCode,
    this.kycSubmitted = false,
    this.kycStatus = 'pending',
    this.hasActiveLoanRequest = false,
    this.lastLoanRequestDate,
    required this.createdAt,
    this.updatedAt,
    this.kycDocuments,
    this.location,
    this.isDisabled = false,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] as String,
      phone: data['phone'] as String,
      email: data['email'] as String?,
      address: data['address'] as String?,
      city: data['city'] as String?,
      state: data['state'] as String?,
      pinCode: data['pinCode'] as String?,
      kycSubmitted: data['kycSubmitted'] as bool? ?? false,
      kycStatus: data['kycStatus'] as String? ?? 'pending',
      hasActiveLoanRequest: data['hasActiveLoanRequest'] as bool? ?? false,
      lastLoanRequestDate: data['lastLoanRequestDate'] as Timestamp?,
      createdAt: data['createdAt'] as Timestamp,
      updatedAt: data['updatedAt'] as Timestamp?,
      kycDocuments: data['kycDocuments'] as Map<String, dynamic>?,
      location: data['location'] as GeoPoint?,
      isDisabled: data['isDisabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'state': state,
      'pinCode': pinCode,
      'kycSubmitted': kycSubmitted,
      'kycStatus': kycStatus,
      'hasActiveLoanRequest': hasActiveLoanRequest,
      'lastLoanRequestDate': lastLoanRequestDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'kycDocuments': kycDocuments,
      'location': location,
      'isDisabled': isDisabled,
    };
  }

  // Create a copy of this model with some changes
  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? state,
    String? pinCode,
    bool? kycSubmitted,
    String? kycStatus,
    bool? hasActiveLoanRequest,
    Timestamp? lastLoanRequestDate,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Map<String, dynamic>? kycDocuments,
    GeoPoint? location,
    bool? isDisabled,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      kycSubmitted: kycSubmitted ?? this.kycSubmitted,
      kycStatus: kycStatus ?? this.kycStatus,
      hasActiveLoanRequest: hasActiveLoanRequest ?? this.hasActiveLoanRequest,
      lastLoanRequestDate: lastLoanRequestDate ?? this.lastLoanRequestDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      kycDocuments: kycDocuments ?? this.kycDocuments,
      location: location ?? this.location,
      isDisabled: isDisabled ?? this.isDisabled,
    );
  }
}
