//角色列表的角色
class UserCharacter {
  final int characterId;
  final String characterName;
  final int userId;

  UserCharacter({
    required this.characterId,
    required this.characterName,
    required this.userId,
  });

  // 修正 JSON 映射
  factory UserCharacter.fromJson(Map<String, dynamic> json) {
    return UserCharacter(
      characterId: json['character_id'] as int,
      characterName: json['character_name'] as String,
      userId: json['user_id'] as int,
    );
  }
}
