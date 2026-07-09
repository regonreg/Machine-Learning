class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'admin' or 'karyawan'
  final String department;
  final String avatar;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.avatar,
  });
}
