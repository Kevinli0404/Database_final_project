//角色基本資料
class CharacterData {
  final int characterId;
  final String characterName;
  final String createTime;
  final int gem;
  final int granteeState;
  final int topUpState;
  final int userId;
  final int vipLevel;

  CharacterData({
    required this.characterId,
    required this.characterName,
    required this.createTime,
    required this.gem,
    required this.granteeState,
    required this.topUpState,
    required this.userId,
    required this.vipLevel,
  });

  // 從 JSON 映射到 CharacterData
  factory CharacterData.fromJson(Map<String, dynamic> json) {
    return CharacterData(
      characterId: json['character_id'] as int,
      characterName: json['character_name'] as String,
      createTime: json['create_time'] as String,
      gem: json['gem'] as int,
      granteeState: json['grantee_state'] as int,
      topUpState: json['top_up_state'] as int,
      userId: json['user_id'] as int,
      vipLevel: json['vip_level'] as int,
    );
  }

  // 將 CharacterData 映射回 JSON
  Map<String, dynamic> toJson() {
    return {
      'character_id': characterId,
      'character_name': characterName,
      'create_time': createTime,
      'gem': gem,
      'grantee_state': granteeState,
      'top_up_state': topUpState,
      'user_id': userId,
      'vip_level': vipLevel,
    };
  }
}
