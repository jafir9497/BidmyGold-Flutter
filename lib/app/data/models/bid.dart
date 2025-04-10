class Bid {
  final String? id;
  final String? pawnbrokerUid;
  final String? name;
  final String? shopName;
  final double? loanAmount;
  final double? interestRate;
  final int? tenure;
  final String? status;
  final DateTime? createdAt;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final DateTime? expiresAt;
  
  // Pawnbroker details
  final String? location;
  final double? rating;
  final String? operatingHours;
  final String? contact;
  
  // Loan details
  final double? emi;
  final double? processingFee;
  
  // Comparison flags
  final bool isLowestInterest;
  final bool isHighestAmount;
  final bool isLowestFee;
  final bool isLowestEmi;

  Bid({
    this.id,
    this.pawnbrokerUid,
    this.name,
    this.shopName,
    this.loanAmount,
    this.interestRate,
    this.tenure,
    this.status,
    this.createdAt,
    this.acceptedAt,
    this.rejectedAt,
    this.expiresAt,
    this.location,
    this.rating,
    this.operatingHours,
    this.contact,
    this.emi,
    this.processingFee,
    this.isLowestInterest = false,
    this.isHighestAmount = false,
    this.isLowestFee = false,
    this.isLowestEmi = false,
  });

  factory Bid.fromMap(Map<String, dynamic> map) {
    return Bid(
      id: map['id'] as String?,
      pawnbrokerUid: map['pawnbrokerUid'] as String?,
      name: map['name'] as String?,
      shopName: map['shopName'] as String?,
      loanAmount: (map['loanAmount'] as num?)?.toDouble(),
      interestRate: (map['interestRate'] as num?)?.toDouble(),
      tenure: map['tenure'] as int?,
      status: map['status'] as String?,
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as DateTime)
          : null,
      acceptedAt: map['acceptedAt'] != null 
          ? (map['acceptedAt'] as DateTime)
          : null,
      rejectedAt: map['rejectedAt'] != null 
          ? (map['rejectedAt'] as DateTime)
          : null,
      expiresAt: map['expiresAt'] != null 
          ? (map['expiresAt'] as DateTime)
          : null,
      location: map['location'] as String?,
      rating: (map['rating'] as num?)?.toDouble(),
      operatingHours: map['operatingHours'] as String?,
      contact: map['contact'] as String?,
      emi: (map['emi'] as num?)?.toDouble(),
      processingFee: (map['processingFee'] as num?)?.toDouble(),
      isLowestInterest: map['isLowestInterest'] as bool? ?? false,
      isHighestAmount: map['isHighestAmount'] as bool? ?? false,
      isLowestFee: map['isLowestFee'] as bool? ?? false,
      isLowestEmi: map['isLowestEmi'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pawnbrokerUid': pawnbrokerUid,
      'name': name,
      'shopName': shopName,
      'loanAmount': loanAmount,
      'interestRate': interestRate,
      'tenure': tenure,
      'status': status,
      'createdAt': createdAt,
      'acceptedAt': acceptedAt,
      'rejectedAt': rejectedAt,
      'expiresAt': expiresAt,
      'location': location,
      'rating': rating,
      'operatingHours': operatingHours,
      'contact': contact,
      'emi': emi,
      'processingFee': processingFee,
      'isLowestInterest': isLowestInterest,
      'isHighestAmount': isHighestAmount,
      'isLowestFee': isLowestFee,
      'isLowestEmi': isLowestEmi,
    };
  }
}
