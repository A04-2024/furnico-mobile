class Rating {
  final String id;
  final String username;
  final int rating;
  final String description;
  final bool isOwner;

  Rating({
    required this.id,
    required this.username,
    required this.rating,
    required this.description,
    required this.isOwner,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      username: json['user']['username'],  
      rating: json['rating'],
      description: json['description'],
      isOwner: json['is_owner'],
    );
  }
}
