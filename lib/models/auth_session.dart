class AuthSession {
  final String token;
  final int companyId;
  final String companyName;

  const AuthSession({
    required this.token,
    required this.companyId,
    required this.companyName,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token'] as String,
      companyId: json['companyId'] as int,
      companyName: json['companyName'] as String,
    );
  }
}
