class JobOffer {
  final int id;
  final String title;
  final String description;
  final DateTime createdAt;
  final int companyId;
  final String companyName;

  const JobOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.companyId,
    required this.companyName,
  });

  factory JobOffer.fromJson(Map<String, dynamic> json) {
    return JobOffer(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      companyId: json['companyId'] as int,
      companyName: json['companyName'] as String,
    );
  }
}
