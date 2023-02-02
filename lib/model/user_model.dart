class UserModel {
  final String name;
  final String email;
  final String photo;
  final double latitude;
  final double longitude;
  final String id;

  UserModel(
      {required this.name,
      required this.email,
      required this.photo,
      required this.latitude,
      required this.longitude,
      required this.id});

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "photo": photo,
        "latitude": latitude,
        "longitude": longitude,
        "id": id
      };

  static UserModel fromJson(Map<String, dynamic> json) => UserModel(
      name: json['name'],
      email: json['email'],
      photo: json['photo'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      id: json['id']);
}
