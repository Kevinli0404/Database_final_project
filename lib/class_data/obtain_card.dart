class ObtainCard {
  final String cardId;
  final String cardName;
  final String rarity;
  final String cardImage;
  final String cardDescription;
  final String? skillCost;
  final String? skillDamage;
  final String? skillName;

  ObtainCard({
    required this.cardId,
    required this.cardName,
    required this.rarity,
    required this.cardImage,
    required this.cardDescription,
    this.skillCost,
    this.skillDamage,
    this.skillName,
  });

  factory ObtainCard.fromJson(Map<String, dynamic> json) {
    // const defaultImagePath = 'assets/character_pictures/25.png';

    return ObtainCard(
      cardId: json['card_id']?.toString() ?? '',
      cardName: json['card_name'] ?? 'Unknown Card',
      rarity: json['rarity']?.toString() ?? '',
      cardImage: json['card_picture_path'],
      // cardImage: json['card_picture_path'] ?? defaultImagePath,
      cardDescription: json['card_description'] ?? 'No description available',
      skillCost: json['skill_cost']?.toString(),
      skillDamage: json['skill_damage']?.toString(),
      skillName: json['skill_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'card_id': cardId,
      'card_name': cardName,
      'rarity': rarity,
      'card_image': cardImage,
      'card_description': cardDescription,
      'skill_cost': skillCost,
      'skill_damage': skillDamage,
      'skill_name': skillName,
    };
  }
}
