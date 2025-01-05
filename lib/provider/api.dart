import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;

import 'package:database_final_project/class_data/character_data.dart';
import 'package:database_final_project/class_data/user_character.dart';
import 'package:database_final_project/class_data/obtain_card.dart';
import 'package:database_final_project/class_data/card_pool_data.dart';

// class ServerAPI
class ServerAPI with ChangeNotifier {
  String _hostIP = '192.168.2.203';
  String _host = '';
  final String _port = '5000';
  String _accessToken = '';
  int? _userId; // 用戶 ID
  List<UserCharacter> _userCharacters = []; // 角色列表
  CharacterData? _characterData; // 用於存儲角色詳細資料
  List<ObtainCard> _backpackCards = []; // 用於儲存背包數據
  List<CardPoolData> _cardPool = []; // 儲存 CardPool 數據
  final List<Map<String, dynamic>> _gachaResults = [];
  final List<Map<String, dynamic>> _gachaTenTimesResults = [];

  String get host => _host;
  String get hostIP => _hostIP;
  String get port => _port;
  String get accessToken => _accessToken;
  int? get userId => _userId;
  CharacterData? get characterData => _characterData;

  List<UserCharacter> get userCharacters => List.unmodifiable(_userCharacters);
  List<ObtainCard> get backpackCards => List.unmodifiable(_backpackCards);
  List<CardPoolData> get cardPool => List.unmodifiable(_cardPool);
  // 提供只讀訪問
  List<Map<String, dynamic>> get gachaResults =>
      List.unmodifiable(_gachaResults);
  List<Map<String, dynamic>> get gachaTenTimesResults =>
      List.unmodifiable(_gachaTenTimesResults);

  bool get isLogin => _accessToken.isNotEmpty;

  set setHost(String hostIP) {
    _hostIP = hostIP;
    initHost();
    notifyListeners();
  }

  void setToken(String token) {
    _accessToken = token;
    notifyListeners();
  }

  void setUserId(int id) {
    _userId = id;
    notifyListeners();
  }

  void setUserCharacters(List<UserCharacter> characters) {
    // 限制最多只有 3 个角色
    _userCharacters =
        characters.length > 3 ? characters.sublist(0, 3) : characters;
    notifyListeners();
  }

  void initHost() {
    if (_hostIP.isNotEmpty) {
      _host = '$_hostIP:$_port';
    } else {
      _host = '0.0.0.0:0';
    }
  }

  Future<String> initLocalServer() async {
    Uri hostUrl = Uri.http(_host, '/api/v1/hello');
    http.Response response = await http.post(
      hostUrl,
      body: {'access_token': _accessToken},
    );
    return response.body;
  }

  //註冊
  Future<String> signUp(
    String firstname,
    String lastname,
    String email,
    String password,
    String passwordCheck,
  ) async {
    initHost();
    if (_host == '0.0.0.0:0') return 'host is empty';

    Uri hostUrl = Uri.http(
        'bev2loadbalancer-61644974.us-east-1.elb.amazonaws.com:80',
        '/api/v2/auth/signup');

    try {
      http.Response response = await http.post(
        hostUrl,
        body: jsonEncode({
          "firstname": firstname,
          "lastname": lastname,
          "email": email,
          "password": password,
          "password_check": passwordCheck,
          "role": "normal_user"
        }),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      var responseBody = json.decode(response.body);
      if (response.statusCode == 200 && responseBody["err"] == false) {
        return 'register success';
      } else {
        return 'register fail';
      }
    } catch (e) {
      if (e is SocketException) {
        return 'Connection failed';
      }
      if (e is TimeoutException) {
        return 'Connection timeout\nPlease check host and server status';
      }
      return e.toString();
    }
  }

  //登入
  Future<String> loginIn(String user, String password) async {
    initHost();
    if (_host == '0.0.0.0:0') return 'host is empty';

    Uri hostUrl = Uri.http(
        'bev2loadbalancer-61644974.us-east-1.elb.amazonaws.com:80',
        '/api/v2/auth/signin');

    try {
      http.Response response = await http.post(
        hostUrl,
        body: json.encode({'email': user, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      var responseBody = json.decode(response.body);

      if (responseBody is Map) {
        String message = responseBody["err_msg"].toString();
        if (message == "signin success") {
          if (responseBody.containsKey('token')) {
            _accessToken = responseBody["token"].toString();
            _userId = responseBody["user_id"];
            notifyListeners();
            return 'login success';
          } else {
            return 'login success, but token is missing';
          }
        } else {
          return 'login failed: $message';
        }
      } else {
        return 'Unexpected response format';
      }
    } catch (e) {
      if (e is SocketException) {
        return 'Connection failed';
      }
      if (e is TimeoutException) {
        return 'Connection timeout\nPlease check host and server status';
      }
      return 'Error: ${e.toString()}';
    }
  }

  //獲得角色資料
  Future<void> getUserCharacter() async {
    Uri hostUrl = Uri.http(_host, '/api/v1/get_user_character');
    try {
      http.Response response = await http.post(
        hostUrl,
        body: {
          "access_token": _accessToken,
          "user_id": _userId.toString(),
        },
      );

      Map<String, dynamic> respose = jsonDecode(response.body);

      log('getUserCharacter respose = ${response.body}');

      if (respose["err"] == false && response.statusCode == 200) {
        final characters = (respose["user's character"] as List)
            .map((item) => UserCharacter.fromJson(item))
            .toList();

        // 调用 setUserCharacters 更新
        setUserCharacters(characters);
        notifyListeners();
        log('_userCharacters = $_userCharacters');
      } else {
        throw Exception(respose["err_msg"] ?? "Unknown error");
      }
    } catch (e) {
      log('Error fetching user characters: $e');
      rethrow;
    }
  }

  //註冊角色
  Future<void> registerUser(String characterName) async {
    Uri hostUrl = Uri.http(_host, '/api/v1/register_user');
    try {
      http.Response response = await http.post(
        hostUrl,
        body: {
          "access_token": _accessToken,
          "user_id": _userId.toString(),
          "character_name": characterName,
        },
      );

      Map<String, dynamic> respose = jsonDecode(response.body);

      log('registerUser respose = ${response.body}');

      if (respose["err"] == false && response.statusCode == 200) {
        log('註冊成功');
      } else {
        throw Exception(respose["err_msg"] ?? "Unknown error");
      }
    } catch (e) {
      log('Error fetching user characters: $e');
      rethrow;
    }
  }

  //獲得角色資料
  Future<String> getCharacterList(String characterID) async {
    Uri hostUrl = Uri.http(_host, '/api/v1/get_character_list');
    try {
      log('character.characterId');
      log(characterID);

      log('_accessToken');
      log(_accessToken);

      http.Response response = await http.post(
        hostUrl,
        body: {
          "access_token": _accessToken,
          "character_id": characterID,
        },
      );

      Map<String, dynamic> respose = jsonDecode(response.body);

      log('getCharacterList response = ${response.body}');

      if (respose["err"] == false && response.statusCode == 200) {
        // 將角色資料映射到 CharacterData 類別
        _characterData = CharacterData.fromJson(respose["character"]);
        notifyListeners();
        return 'getCharacterList success';
      } else {
        throw Exception(respose["err_msg"] ?? "Unknown error");
      }
    } catch (e) {
      log('Error fetching character data: $e');
      rethrow;
    }
  }

  //獲得背包資料
  Future<String> getCharacterBackpack(String characterID) async {
    Uri hostUrl = Uri.http(_host, '/api/v1/get_character_backpack');
    try {
      http.Response response = await http.post(
        hostUrl,
        body: {
          "access_token": _accessToken,
          "character_id": characterID,
        },
      );
      Map<String, dynamic> respose = jsonDecode(response.body);

      log('getCharacterBackpack response = ${response.body}');

      if (respose["err"] == false && response.statusCode == 200) {
        _backpackCards = (respose['obtain_card'] as List)
            .map((item) => ObtainCard.fromJson({
                  "card_id": item['card_id'].toString(),
                  "card_name": item['card_name'],
                  "rarity": item['rarity'].toString(),
                  "card_image": item['card_picture_path'].toString(),
                  "card_description": "No description available.",
                  "skill_cost": item['skill_cost']?.toString(),
                  "skill_damage": item['skill_damage']?.toString(),
                  "skill_name": item['skill_name'],
                }))
            .toList();

        notifyListeners(); // 通知 UI 数据已更新
        return 'getCharacterBackpack success';
      } else {
        throw Exception(respose["err_msg"] ?? "Unknown error");
      }
    } catch (e) {
      log('Error fetching backpack data: $e');
      return 'getCharacterBackpack fail';
    }
  }

  //獲得卡池資料
  Future<String> getCardPool() async {
    Uri hostUrl = Uri.http(_host, '/api/v1/get_card_pool');
    try {
      http.Response response = await http.post(
        hostUrl,
        body: {
          "access_token": _accessToken,
        },
      );

      Map<String, dynamic> respose = jsonDecode(response.body);

      log('getCardPool response = ${response.body}');

      if (respose["err"] == false && response.statusCode == 200) {
        _cardPool = (respose['card_pool'] as List)
            .map((item) => CardPoolData.fromJson(item))
            .toList();

        notifyListeners();
        return 'getCardPool success';
      } else {
        throw Exception(respose["err_msg"] ?? "Unknown error");
      }
    } catch (e) {
      log('Error fetching card pool data: $e');
      return 'getCardPool fail';
    }
  }

  //單抽
  Future<String> gachaOnce({
    required String cardPoolID,
    required String characterID,
  }) async {
    Uri hostUrl = Uri.http(_host, '/api/v1/gacha_once');
    try {
      http.Response response = await http.post(
        hostUrl,
        body: {
          "access_token": _accessToken,
          "card_pool_id": cardPoolID,
          "character_id": characterID,
        },
      );

      Map<String, dynamic> respose = jsonDecode(response.body);

      log('gachaOnce response = ${response.body}');

      if (respose["err"] == false && response.statusCode == 200) {
        // 將 gacha_result 格式化為 ObtainCard 的格式
        // final ObtainCard obtainedCard = ObtainCard(
        //   cardId: respose['gacha_result']['card_id'].toString(),
        //   cardImage: respose['gacha_result']['card_picture_path'],
        //   cardName: respose['gacha_result']['card_name'],
        //   rarity: respose['gacha_result']['rarity'].toString(),
        //   cardDescription: 'No description available',
        // );
        final ObtainCard obtainedCard = ObtainCard(
          cardId: (respose['gacha_result']['card_id'] ?? '').toString(),
          cardImage: respose['gacha_result']['card_picture_path'] ??
              'assets/character_pictures/15.png',
          cardName: respose['gacha_result']['card_name'] ?? 'Unknown Card',
          rarity: (respose['gacha_result']['rarity'] ?? '').toString(),
          cardDescription: 'No description available',
        );

        _gachaResults.add({
          'gacha_result': obtainedCard.toJson(),
          'grantee': respose['grantee'],
          'grantee_state': respose['grantee_state'],
        });
        notifyListeners();

        return 'gachaOnce success';
      } else {
        throw Exception(respose["err_msg"] ?? "Unknown error");
      }
    } catch (e) {
      log('Error in gachaOnce: $e');
      return 'gachaOnce fail';
    }
  }

  // 清空 gacha 結果
  void clearGachaResults() {
    _gachaResults.clear();
    notifyListeners();
  }

  // 清空 gachaTenTimes 的结果
  void clearGachaTenTimesResults() {
    _gachaTenTimesResults.clear();
    notifyListeners();
  }

  // 十抽方法
  Future<String> gachaTenTimes({
    required String cardPoolID,
    required String characterID,
  }) async {
    Uri hostUrl = Uri.http(_host, '/api/v1/gacha_ten_times');
    try {
      http.Response response = await http.post(
        hostUrl,
        body: {
          "access_token": _accessToken,
          "card_pool_id": cardPoolID,
          "character_id": characterID,
        },
      );

      Map<String, dynamic> respose = jsonDecode(response.body);

      log('gachaTenTimes response = ${response.body}');

      if (respose["err"] == false && response.statusCode == 200) {
        // 清空之前的结果
        _gachaTenTimesResults.clear();

        // 更新结果
        final List<ObtainCard> obtainedCards = (respose['gacha_result'] as List)
            .map((item) => ObtainCard.fromJson({
                  "card_id": item['card_id'].toString(),
                  "card_name": item['card_name'],
                  "rarity": item['rarity'].toString(),
                  // 固定圖片
                  "cardImage": item['card_picture_path'].toString(),
                  "card_description": "No description available.",
                }))
            .toList();

        // 清空之前的十抽结果
        _gachaTenTimesResults.clear();

        _gachaTenTimesResults.addAll(obtainedCards.map((card) => {
              'gacha_result': card.toJson(),
              'grantee': respose['grantee'],
              'grantee_state': respose['grantee_state'],
            }));

        // 通知监听者
        notifyListeners();
        return 'gachaTenTimes success';
      } else {
        throw Exception(respose["err_msg"] ?? "Unknown error");
      }
    } catch (e) {
      log('Error in gachaTenTimes: $e');
      return 'gachaTenTimes fail';
    }
  }

  // 儲值
  Future<String> topUp({
    required String characterID,
    required String topUpGem,
  }) async {
    Uri hostUrl = Uri.http(_host, '/api/v1/top_up');
    try {
      http.Response response = await http.post(
        hostUrl,
        body: {
          "access_token": _accessToken,
          "character_id": characterID,
          "top_up_gem": topUpGem,
        },
      );

      // 将响应解码为 Map
      Map<String, dynamic> respose = jsonDecode(response.body);

      log('topUp response = ${response.body}');

      if (respose["err"] == false && response.statusCode == 200) {
        return 'topUp success';
      } else {
        throw Exception(respose["err_msg"] ?? "Unknown error");
      }
    } catch (e) {
      log('Error : $e');
      return 'topUp fail';
    }
  }
}

// //裝置資料
// Future<String> getDeviceInfo() async {
//   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//   if (Platform.isAndroid) {
//     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//     return androidInfo.model;
//   } else if (Platform.isIOS) {
//     IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
//     return iosInfo.name;
//   }
//   return 'Unknown';
// }
