import 'package:meta/meta.dart';

class JWTResponse {
  final String token;
  final String userEmail;
  final String userDisplayName;

  JWTResponse(
      {@required this.token, @required this.userEmail, @required this.userDisplayName});

  JWTResponse.fromJson(Map<String, dynamic> json):
    token = json['token'],
    userEmail = json['user_email'],
    userDisplayName = json['user_display_name'];

  @override
  String toString() =>
      "JWTResponse (email: $userEmail, name: $userDisplayName, token: $token)";

}