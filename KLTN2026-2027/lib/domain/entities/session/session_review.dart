class SessionRating {
  const SessionRating(this.sessionId, this.rating, this.comment, this.createdAt);

  final String sessionId;
  final int rating;
  final String? comment;
  final DateTime? createdAt;
}
