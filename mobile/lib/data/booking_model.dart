class Booking {
  final String id;
  final String tour;
  final String tourName;
  final String user;
  final double price;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.tour,
    required this.tourName,
    required this.user,
    required this.price,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'],
      tour: json['tour'] is Map ? json['tour']['_id'] : json['tour'],
      tourName: json['tour'] is Map ? json['tour']['name'] : 'Tour',
      user: json['user'] is Map ? json['user']['_id'] : json['user'],
      price: (json['price'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
