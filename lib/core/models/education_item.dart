class EducationItem {
  final int id;
  final String title;
  final String shortDescription;
  final String fullDescription;
  final String correctCategory; // 'children' или 'adults'
  final int points;

  EducationItem({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.fullDescription,
    required this.correctCategory,
    required this.points,
  });
}