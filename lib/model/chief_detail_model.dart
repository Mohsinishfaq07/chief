import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp

class ChiefDetailModel {
  final String address;
  final String certificateImage;
  final String certifications;
  final String email;
  final String name;
  final String number;
  final String password;
  final String rating;
  final String specialties;
  final String workExperience;
  final String userId;
  final String image;
  final String role;
  final Timestamp timestamp;

  ChiefDetailModel({
    required this.address,
    required this.certificateImage,
    required this.certifications,
    required this.email,
    required this.name,
    required this.number,
    required this.password,
    required this.rating,
    required this.specialties,
    required this.workExperience,
    required this.userId,
    required this.image,
    required this.role,
    required this.timestamp,
  });

  factory ChiefDetailModel.fromJson(Map<String, dynamic> json) {
    return ChiefDetailModel(
      address: json['address'],
      certificateImage: json['certificateImage'],
      certifications: json['certifications'],
      email: json['email'],
      name: json['name'],
      number: json['number'],
      password: json['password'],
      rating: json['rating'],
      specialties: json['specialties'],
      workExperience: json['workExperience'],
      userId: json['userId'],
      image: json['image'],
      role: json['role'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'certificateImage': certificateImage,
      'certifications': certifications,
      'email': email,
      'name': name,
      'number': number,
      'password': password,
      'rating': rating,
      'specialties': specialties,
      'workExperience': workExperience,
      'userId': userId,
      'image': image,
      'role': role,
      'timestamp': timestamp,
    };
  }
}
