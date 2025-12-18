class User {
  final int? id;
  final String username;
  final String nama;
  final String password;
  final String role; // anggota, admin_keuangan, ketua
  final DateTime? createdAt;

  User({
    this.id,
    required this.username,
    required this.nama,
    required this.password,
    required this.role,
    this.createdAt,
  });

  // Convert from JSON (API response)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      nama: json['nama'],
      password: json['password'],
      role: json['role'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  // Convert to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nama': nama,
      'password': password,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Copy with new values
  User copyWith({
    int? id,
    String? username,
    String? nama,
    String? password,
    String? role,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      nama: nama ?? this.nama,
      password: password ?? this.password,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}