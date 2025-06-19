class UserModel {
  String parentName;
  String parentLastName;
  String parentEmail;
  String parentPassword;
  String childName;
  String childLastName;
  List<String> courses;

  UserModel({
    this.parentName = '',
    this.parentLastName = '',
    this.parentEmail = '',
    this.parentPassword = '',
    this.childName = '',
    this.childLastName = '',
    this.courses = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    parentName: json['parentName'],
    parentLastName: json['parentLastName'],
    parentEmail: json['parentEmail'],
    // no devolvemos la contraseña para seguridad
    childName: json['childName'],
    childLastName: json['childLastName'],
    courses: List<String>.from(json['courses']),
  );
}
