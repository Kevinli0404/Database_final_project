import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:database_final_project/class_data/character_data.dart';
import 'package:database_final_project/class_data/user_character.dart';
import 'package:database_final_project/class_data/obtain_card.dart';
import 'package:database_final_project/class_data/card_pool_data.dart';

class ServerAPI with ChangeNotifier {
  String _hostIP = '192.168..';
  String _host = '';
  final String _port = '....';
  String _accessToken = '';
  // 用戶 ID
  int? _userId;
  // 角色列表
  List<UserCharacter> _userCharacters = [];
  // 用於存儲角色詳細資料
  CharacterData? _characterData;
  // 用於儲存背包數據
  List<ObtainCard> _backpackCards = [];
  // 儲存 CardPool 數據
  List<CardPoolData> _cardPool = [];

  List<ObtainCard> _gachaTenTimesResults = [];

  List<ObtainCard> get gachaTenTimesResults =>
      List.unmodifiable(_gachaTenTimesResults);

  String get host => _host;
  String get hostIP => _hostIP;
  String get port => _port;
  String get accessToken => _accessToken;
  int? get userId => _userId;
  CharacterData? get characterData => _characterData;

  // 提供只讀訪問
  List<UserCharacter> get userCharacters => List.unmodifiable(_userCharacters);
  List<ObtainCard> get backpackCards => List.unmodifiable(_backpackCards);
  List<CardPoolData> get cardPool => List.unmodifiable(_cardPool);

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
    _userCharacters = characters;
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
        _backpackCards.clear();
        _backpackCards = (respose['obtain_card'] as List)
            .map((item) => ObtainCard.fromJson(item))
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
        _cardPool.clear();
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

  // 清空 gachaTenTimes 的结果
  void cleargetCardPoolResults() {
    _cardPool.clear();
    notifyListeners();
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
        // 清空 _gachaTenTimesResults，準備存儲新結果
        _gachaTenTimesResults.clear();

        final Map<String, dynamic> gachaResult = respose['gacha_result'];
        ObtainCard obtainedCard = ObtainCard.fromJson(gachaResult);
        log('Decoded gacha_result: ${respose['gacha_result']}');

        // 將單抽結果存入 _gachaTenTimesResults
        _gachaTenTimesResults.add(obtainedCard);

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
        _gachaTenTimesResults.clear();

        // 解析抽卡结果
        _gachaTenTimesResults = (respose['gacha_result'] as List)
            .map((item) => ObtainCard.fromJson(item))
            .toList();

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

  // 清空 gachaTenTimes 的结果
  void clearGachaTenTimesResults() {
    _gachaTenTimesResults.clear();
    notifyListeners();
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
