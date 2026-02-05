class Tour {
  final String id;
  final String name;
  final int duration;
  final int maxGroupSize;
  final String difficulty;
  final double ratingsAverage;
  final int ratingsQuantity;
  final double price;
  final String summary;
  final String description;
  final String imageCover;
  final List<String> images;
  final DateTime? startDates; 

  Tour({
    required this.id,
    required this.name,
    required this.duration,
    required this.maxGroupSize,
    required this.difficulty,
    required this.ratingsAverage,
    required this.ratingsQuantity,
    required this.price,
    required this.summary,
    required this.description,
    required this.imageCover,
    required this.images,
    this.startDates,
  });

  factory Tour.fromJson(Map<String, dynamic> json) {
    return Tour(
      id: json['_id'],
      name: json['name'],
      duration: json['duration'],
      maxGroupSize: json['maxGroupSize'],
      difficulty: json['difficulty'],
      ratingsAverage: (json['ratingsAverage'] as num).toDouble(),
      ratingsQuantity: json['ratingsQuantity'],
      price: (json['price'] as num).toDouble(),
      summary: json['summary'],
      description: json['description'] ?? '',
      imageCover: json['imageCover'],
      images: List<String>.from(json['images'] ?? []),
      startDates: json['startDates'] != null && (json['startDates'] as List).isNotEmpty 
          ? DateTime.parse(json['startDates'][0]) 
          : null,
    );
  }
}
