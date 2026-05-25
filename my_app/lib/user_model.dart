class UserModel {
  final String id;
  final String fullName;
  final String username;
  final String email;
  final String phone;
  final String aadharNumber;
  final String panNumber;
  final String role;
  final bool isVerified;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phone,
    required this.aadharNumber,
    required this.panNumber,
    required this.role,
    required this.isVerified,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      aadharNumber: json['aadharNumber'] ?? '',
      panNumber: json['panNumber'] ?? '',
      role: json['role'] ?? 'user',
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'email': email,
      'phone': phone,
      'aadharNumber': aadharNumber,
      'panNumber': panNumber,
      'role': role,
      'isVerified': isVerified,
      'createdAt': createdAt,
    };
  }

  // Get initials for avatar
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';
  }
}
