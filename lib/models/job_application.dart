class JobApplication {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String cvFileName;
  final DateTime createdAt;
  final int jobOfferId;

  const JobApplication({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.cvFileName,
    required this.createdAt,
    required this.jobOfferId,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      cvFileName: json['cvFileName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      jobOfferId: json['jobOfferId'] as int,
    );
  }
}
