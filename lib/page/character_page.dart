import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:database_final_project/provider/api.dart';
import 'package:database_final_project/page/home_page.dart';
import 'package:database_final_project/class_data/user_character.dart';

class CharacterPage extends StatelessWidget {
  const CharacterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景圖片
          Positioned.fill(
            child: Image.asset(
              'assets/logo/genshin_login.jpg', // 替換為你的圖片路徑
              fit: BoxFit.cover,
            ),
          ),
          // 半透明遮罩，讓框框更突出
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          // 角色框框
          Center(
            child: Consumer<ServerAPI>(
              builder: (context, serverAPI, child) {
                final characters = serverAPI.userCharacters;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) {
                      if (index < characters.length) {
                        // 有角色时显示角色信息
                        return GestureDetector(
                          onTap: () async {
                            await _handleCharacterTap(
                                context, serverAPI, characters[index]);
                          },
                          child: _buildCharacterBox(
                            characters[index].characterName,
                          ),
                        );
                      } else if (index == characters.length) {
                        // 显示 + 按钮
                        return GestureDetector(
                          onTap: () {
                            _showAddCharacterDialog(context);
                          },
                          child: _buildAddCharacterBox(),
                        );
                      } else {
                        // 无角色时显示空框
                        return GestureDetector(
                          onTap: null,
                          child: _buildCharacterBox(''),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 处理角色点击事件并导航到 HomePage
  Future<void> _handleCharacterTap(BuildContext context, ServerAPI serverAPI,
      UserCharacter character) async {
    try {
      final getCharacterListResult =
          await serverAPI.getCharacterList(character.characterId.toString());
      final getCardPoolResult = await serverAPI.getCardPool();
      if (getCharacterListResult == 'getCharacterList success' &&
          getCardPoolResult == 'getCardPool success') {
        // log('Character data fetched successfully.');
        // log('serverAPI.cardPool');
        // log('${serverAPI.cardPool}');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        Fluttertoast.showToast(
          msg: "加载角色失败：$getCharacterListResult",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "加载角色失败：$e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // 显示添加角色的对话框
  void _showAddCharacterDialog(BuildContext context) {
    Fluttertoast.showToast(
      msg: "添加角色功能尚未实现",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
  }

  // 建立角色框框的函式
  Widget _buildCharacterBox(String title) {
    return Container(
      width: 200,
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          title.isEmpty ? '空位' : title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 建立添加角色的框框
  Widget _buildAddCharacterBox() {
    return Container(
      width: 200,
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.add,
          size: 40,
          color: Colors.black,
        ),
      ),
    );
  }
}
