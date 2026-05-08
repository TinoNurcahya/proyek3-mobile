class UserModel {
  final String name;
  final String phone;
  final String email;
  final String status;

  UserModel({
    required this.name,
    required this.phone,
    required this.email,
    this.status = 'Online',
  });

  UserModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? status,
  }) {
    return UserModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      status: status ?? this.status,
    );
  }
}