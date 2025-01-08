class CardPoolData {
  final int cardId;
  final String cardName;
  final int cardPoolId;
  final double lowRarityProbability;
  final double mediumRarityProbability;
  final double highRarityProbability;
  final String cardImage;

  CardPoolData({
    required this.cardId,
    required this.cardName,
    required this.cardPoolId,
    required this.lowRarityProbability,
    required this.mediumRarityProbability,
    required this.highRarityProbability,
    required this.cardImage,
  });

  factory CardPoolData.fromJson(Map<String, dynamic> json) {
    return CardPoolData(
      cardId: json['card_id'],
      cardName: json['card_name'],
      cardPoolId: json['card_pool_id'],
      lowRarityProbability: json['low_rarity_probability'],
      mediumRarityProbability: json['medium_rarity_probability'],
      highRarityProbability: json['high_rarity_probability'],
      cardImage: json['card_picture_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'card_id': cardId,
      'card_name': cardName,
      'card_pool_id': cardPoolId,
      'low_rarity_probability': lowRarityProbability,
      'medium_rarity_probability': mediumRarityProbability,
      'real_high_rarity_probability': highRarityProbability,
      'card_image': cardImage,
    };
  }
}
