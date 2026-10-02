class ReportModel {
  final String id;
  final String title;
  final String category;
  final String location;
  final String description;
  final String type; // 'LOST' atau 'FOUND'

  ReportModel({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.description,
    required this.type,
  });
}