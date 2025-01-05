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
              'assets/logo/genshin_login.jpg',
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
                        return GestureDetector(
                          onTap: () {
                            _showAddCharacterDialog(context);
                          },
                          child: _buildAddCharacterBox(),
                        );
                      } else {
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

  Future<void> _handleCharacterTap(BuildContext context, ServerAPI serverAPI,
      UserCharacter character) async {
    try {
      final getCharacterListResult =
          await serverAPI.getCharacterList(character.characterId.toString());
      final getCardPoolResult = await serverAPI.getCardPool();
      if (getCharacterListResult == 'getCharacterList success' &&
          getCardPoolResult == 'getCardPool success') {
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

  // void _showAddCharacterDialog(BuildContext context) {
  //   Fluttertoast.showToast(
  //     msg: "showAddCharacterDialog",
  //     toastLength: Toast.LENGTH_SHORT,
  //     gravity: ToastGravity.CENTER,
  //     backgroundColor: Colors.blue,
  //     textColor: Colors.white,
  //   );
  // }
  void _showAddCharacterDialog(BuildContext context) {
    final TextEditingController characterNameController =
        TextEditingController();
    final serverAPI = Provider.of<ServerAPI>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: true, // 點擊對話框外部可關閉
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("添加角色"),
          content: TextField(
            controller: characterNameController,
            decoration: const InputDecoration(
              labelText: "角色名稱",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 關閉對話框
              },
              child: const Text("取消"),
            ),
            ElevatedButton(
              onPressed: () async {
                final characterName = characterNameController.text.trim();
                if (characterName.isEmpty) {
                  Fluttertoast.showToast(
                    msg: "角色名稱不能為空",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                  return;
                }

                try {
                  await serverAPI.registerUser(characterName);
                  await serverAPI.getUserCharacter(); // 更新角色列表
                  Navigator.of(context).pop(); // 關閉對話框
                  Fluttertoast.showToast(
                    msg: "角色添加成功",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  );
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: "角色添加失敗: $e",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                }
              },
              child: const Text("確認"),
            ),
          ],
        );
      },
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
