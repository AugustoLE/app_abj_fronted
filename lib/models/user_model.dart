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
    childName: json['childName'],
    childLastName: json['childLastName'],
    courses: List<String>.from(json['courses']),
  );

  Map<String, dynamic> toJson() => {
    'parentName': parentName,
    'parentLastName': parentLastName,
    'parentEmail': parentEmail,
    'parentPassword': parentPassword,
    'childName': childName,
    'childLastName': childLastName,
    'courses': courses,
  };
}