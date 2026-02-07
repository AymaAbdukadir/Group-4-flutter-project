class Review {
  final String id;
  final String review;
  final int rating;
  final String tour;
  final String userId;
  final String userName;

  Review({
    required this.id,
    required this.review,
    required this.rating,
    required this.tour,
    required this.userId,
    required this.userName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'],
      review: json['review'],
      rating: json['rating'],
      tour: json['tour'],
      userId: json['user'] is Map ? json['user']['_id'] : json['user'],
      userName: json['user'] is Map ? json['user']['name'] : 'User',
    );
  }
}
