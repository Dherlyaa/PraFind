class ReportModel {
  final String id;
  final String title;
  final String category;
  final String location;
  final String description;
  final String type;
  final String status;

  ReportModel({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.description,
    required this.type,
    this.status = 'ACTIVE',
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      location: json['location'],
      description: json['description'],
      type: json['type'],
      status: json['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'location': location,
      'description': description,
      'type': type,
      'status': status,
    };
  }
}
