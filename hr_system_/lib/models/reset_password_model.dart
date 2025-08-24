class ResetPasswordModel {
  final String newPassword;
  final String confirmPassword;

  ResetPasswordModel({
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
    "newPassword": newPassword,
    "confirmPassword": confirmPassword,
  };
}
