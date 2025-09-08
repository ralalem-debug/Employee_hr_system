// lib/models/login_model.dart
class LoginModel {
  String userNameOrEmail;
  String password;

  LoginModel({required this.userNameOrEmail, required this.password});

  Map<String, dynamic> toJson() {
    return {
      // إذا الـ API بدها userName حتى لو كان ايميل، خلينا الحقل userName
      "userName": userNameOrEmail,
      "password": password,
    };
  }
}
