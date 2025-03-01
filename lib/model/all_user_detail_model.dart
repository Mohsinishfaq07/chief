import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp

class AllUserDetailModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final Timestamp timestamp;

  AllUserDetailModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.timestamp,
  });

  factory AllUserDetailModel.fromJson(Map<String, dynamic> json) {
    return AllUserDetailModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      timestamp: json['timestamp'] as Timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'timestamp': timestamp,
    };
  }
}
