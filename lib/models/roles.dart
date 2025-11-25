class RoleModel {
  final int id;
  final String role;
  final String category;

  String get roleName => role;
  String get roleCategory => category;
  int get roleId => id;
  RoleModel({required this.id, required this.role, required this.category});

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'],
      role: json['role_name'],
      category: json['category'] ?? '',
    );
  }
}
