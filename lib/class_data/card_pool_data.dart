class CardPoolData {
  final int cardId;
  final String cardName;
  final int cardPoolId;
  final double fakeHighRarityProbability;
  final double lowRarityProbability;
  final double mediumRarityProbability;
  final double realHighRarityProbability;
  final String cardImage;

  CardPoolData({
    required this.cardId,
    required this.cardName,
    required this.cardPoolId,
    required this.fakeHighRarityProbability,
    required this.lowRarityProbability,
    required this.mediumRarityProbability,
    required this.realHighRarityProbability,
    required this.cardImage,
  });

  factory CardPoolData.fromJson(Map<String, dynamic> json) {
    return CardPoolData(
      cardId: json['card_id'],
      cardName: json['card_name'],
      cardPoolId: json['card_pool_id'],
      fakeHighRarityProbability: json['fake_high_rarity_probability'],
      lowRarityProbability: json['low_rarity_probability'],
      mediumRarityProbability: json['medium_rarity_probability'],
      realHighRarityProbability: json['real_high_rarity_probability'],
      cardImage: "assets/character_pictures/8.png",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'card_id': cardId,
      'card_name': cardName,
      'card_pool_id': cardPoolId,
      'fake_high_rarity_probability': fakeHighRarityProbability,
      'low_rarity_probability': lowRarityProbability,
      'medium_rarity_probability': mediumRarityProbability,
      'real_high_rarity_probability': realHighRarityProbability,
      'card_image': cardImage,
    };
  }
}
