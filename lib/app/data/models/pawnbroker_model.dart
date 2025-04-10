import 'package:cloud_firestore/cloud_firestore.dart';

class PawnbrokerModel {
  final String id;
  final String shopName;
  final String ownerName;
  final String address;
  final String city;
  final String state;
  final String pinCode;
  final String? email;
  final String phone;
  final String? gstNumber;
  final String licenseNumber;
  final String experience;
  final String shopLicenseUrl;
  final String idProofUrl;
  final String? shopPhotoUrl;
  final bool isVerified;
  final String status; // pending, approved, rejected
  final Timestamp createdAt;
  final Timestamp? updatedAt;
  final Timestamp? verifiedAt;
  final GeoPoint? location;
  final Map<String, dynamic>? businessHours;
  final double averageRating;
  final int ratingCount;

  PawnbrokerModel({
    required this.id,
    required this.shopName,
    required this.ownerName,
    required this.address,
    required this.city,
    required this.state,
    required this.pinCode,
    this.email,
    required this.phone,
    this.gstNumber,
    required this.licenseNumber,
    required this.experience,
    required this.shopLicenseUrl,
    required this.idProofUrl,
    this.shopPhotoUrl,
    this.isVerified = false,
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
    this.verifiedAt,
    this.location,
    this.businessHours,
    this.averageRating = 0.0,
    this.ratingCount = 0,
  });

  factory PawnbrokerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PawnbrokerModel(
      id: doc.id,
      shopName: data['shopName'] as String,
      ownerName: data['ownerName'] as String,
      address: data['address'] as String,
      city: data['city'] as String,
      state: data['state'] as String,
      pinCode: data['pinCode'] as String,
      email: data['email'] as String?,
      phone: data['phone'] as String,
      gstNumber: data['gstNumber'] as String?,
      licenseNumber: data['licenseNumber'] as String,
      experience: data['experience'] as String,
      shopLicenseUrl: data['shopLicenseUrl'] as String,
      idProofUrl: data['idProofUrl'] as String,
      shopPhotoUrl: data['shopPhotoUrl'] as String?,
      isVerified: data['isVerified'] as bool? ?? false,
      status: data['status'] as String? ?? 'pending',
      createdAt: data['createdAt'] as Timestamp,
      updatedAt: data['updatedAt'] as Timestamp?,
      verifiedAt: data['verifiedAt'] as Timestamp?,
      location: data['location'] as GeoPoint?,
      businessHours: data['businessHours'] as Map<String, dynamic>?,
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      ratingCount: data['ratingCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'shopName': shopName,
      'ownerName': ownerName,
      'address': address,
      'city': city,
      'state': state,
      'pinCode': pinCode,
      'email': email,
      'phone': phone,
      'gstNumber': gstNumber,
      'licenseNumber': licenseNumber,
      'experience': experience,
      'shopLicenseUrl': shopLicenseUrl,
      'idProofUrl': idProofUrl,
      'shopPhotoUrl': shopPhotoUrl,
      'isVerified': isVerified,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'verifiedAt': verifiedAt,
      'location': location,
      'businessHours': businessHours,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
    };
  }

  // Create a copy of this model with some changes
  PawnbrokerModel copyWith({
    String? id,
    String? shopName,
    String? ownerName,
    String? address,
    String? city,
    String? state,
    String? pinCode,
    String? email,
    String? phone,
    String? gstNumber,
    String? licenseNumber,
    String? experience,
    String? shopLicenseUrl,
    String? idProofUrl,
    String? shopPhotoUrl,
    bool? isVerified,
    String? status,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Timestamp? verifiedAt,
    GeoPoint? location,
    Map<String, dynamic>? businessHours,
    double? averageRating,
    int? ratingCount,
  }) {
    return PawnbrokerModel(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      ownerName: ownerName ?? this.ownerName,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gstNumber: gstNumber ?? this.gstNumber,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      experience: experience ?? this.experience,
      shopLicenseUrl: shopLicenseUrl ?? this.shopLicenseUrl,
      idProofUrl: idProofUrl ?? this.idProofUrl,
      shopPhotoUrl: shopPhotoUrl ?? this.shopPhotoUrl,
      isVerified: isVerified ?? this.isVerified,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      location: location ?? this.location,
      businessHours: businessHours ?? this.businessHours,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }
}
