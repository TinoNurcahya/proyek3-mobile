class UserModel {
  final int? id;
  final String name;
  final String phone;
  final String email;
  final String status;
  final String? role;
  final String? avatar;

  UserModel({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.status = 'Online',
    this.role,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id_users'] ?? json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone_number'] ?? json['phone'] ?? '',
      role: json['role'],
      avatar: json['avatar'],
      status: 'Online',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'avatar': avatar,
      };

  UserModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? status,
    String? role,
    String? avatar,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      status: status ?? this.status,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
    );
  }
}