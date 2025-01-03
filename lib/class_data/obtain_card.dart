class ObtainCard {
  final String cardId;
  final String cardImage;
  final String cardName;
  final String rarity;
  final String cardDescription;

  ObtainCard({
    required this.cardId,
    required this.cardImage,
    required this.cardName,
    required this.rarity,
    required this.cardDescription,
  });

  // 从 JSON 创建对象
  factory ObtainCard.fromJson(Map<String, dynamic> json) {
    return ObtainCard(
      cardId: json['card_id'] as String,
      cardImage: "assets/character_pictures/12.png",
      cardName: json['card_name'] as String,
      rarity: json['rarity'] as String,
      cardDescription: '握草~原!!',
    );
  }

  // 将对象转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'card_id': cardId,
      'card_image': cardImage,
      'card_name': cardName,
      'rarity': rarity,
      'card_description': cardDescription,
    };
  }
}
