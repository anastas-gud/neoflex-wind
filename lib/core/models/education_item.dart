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

  factory EducationItem.fromJson(Map<String, dynamic> json) {
    return EducationItem(
      id: json['id'],
      title: json['title'],
      shortDescription: json['shortDescription'],
      fullDescription: json['fullDescription'],
      correctCategory: json['correctCategory'],
      points: json['points'],
    );
  }
}
