import 'package:hive/hive.dart';

part 'show.g.dart';

@HiveType(typeId: 0)
class Show extends HiveObject {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String? summary;
  
  @HiveField(3)
  final List<String> genres;
  
  @HiveField(4)
  final double? rating;
  
  @HiveField(5)
  final String? imageUrl;

  Show({
    required this.id,
    required this.name,
    this.summary,
    required this.genres,
    this.rating,
    this.imageUrl,
  });

  factory Show.fromJson(Map<String, dynamic> json) {
    return Show(
      id: json['id'],
      name: json['name'],
      summary: json['summary'],
      genres: List<String>.from(json['genres'] ?? []),
      rating: json['rating']?['average']?.toDouble(),
      imageUrl: json['image']?['medium'],
    );
  }
}