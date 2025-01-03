import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

// class ServerAPI
class ServerAPI with ChangeNotifier {
  String _hostIP = '192.168.0.185';
  String _host = '';
  final String _port = '5000';
  String _accessToken = '';
  int? _userId; // 用戶 ID
  List<UserCharacter> _userCharacters = []; // 角色列表
  CharacterData? _characterData; // 用於存儲角色詳細資料

  // get port => _port;

  // get host => _host;

  // get hostIP => _hostIP;

  String get host => _host;
  String get hostIP => _hostIP;
  String get port => _port;

  String get accessToken => _accessToken; // 獲取 token
  int? get userId => _userId; // 獲取 user_id

  // set setHost(String hostIP) => _hostIP = hostIP;
  // late String _accessToken = '';

  // get accessToken => _accessToken;

  bool get isLogin => _accessToken.isNotEmpty;

  List<UserCharacter> get userCharacters => List.unmodifiable(_userCharacters);
  CharacterData? get characterData => _characterData;

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

      log('responseBody = ${response.body}');

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
          "user_id": _userId.toString(), // 确保 user_id 是字符串
        },
      );

      Map<String, dynamic> respose = jsonDecode(response.body);

      log('getUserCharacter respose = ${response.body}');

      if (respose["err"] == false && response.statusCode == 200) {
        // 将角色数据转换为 UserCharacter 列表并更新
        final characters = (respose["user's character"] as List)
            .map((item) => UserCharacter.fromJson(item))
            .toList();

        // 调用 setUserCharacters 更新
        setUserCharacters(characters);
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
          "user_id": _userId.toString(), // 确保 user_id 是字符串
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
        notifyListeners(); // 通知 UI 更新
        return 'getCharacterList success';
      } else {
        throw Exception(respose["err_msg"] ?? "Unknown error");
      }
    } catch (e) {
      log('Error fetching character data: $e');
      rethrow;
    }
  }
}

//裝置資料
Future<String> getDeviceInfo() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.model;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.name;
  }
  return 'Unknown';
}

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
