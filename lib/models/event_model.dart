class EventModel {
  final String title;
  final String description;
  final String date;
  final String image;
  final String location;

  EventModel({
    required this.title,
    required this.description,
    required this.date,
    required this.image,
    required this.location,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      image: json['image'] ?? '',
      location: json['location'] ?? '',
    );
  }
}
