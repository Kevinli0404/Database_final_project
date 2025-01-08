import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:database_final_project/provider/api.dart';
import 'package:database_final_project/page/home_page.dart';
import 'package:database_final_project/class_data/user_character.dart';

class CharacterPage extends StatefulWidget {
  const CharacterPage({super.key});

  @override
  State<CharacterPage> createState() => _CharacterPageState();
}

class _CharacterPageState extends State<CharacterPage> {
  bool isLoading = false; // 控制全螢幕遮罩
  int _loadingIndex = 0; // 當前文字動畫索引
  late final Timer _loadingTimer;

  @override
  void initState() {
    super.initState();

    // 啟動文字動畫的 Timer
    _loadingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (isLoading) {
        setState(() {
          _loadingIndex = (_loadingIndex + 1) % 16; // 循環文字動畫索引
        });
      }
    });
  }

  @override
  void dispose() {
    _loadingTimer.cancel(); // 停止 Timer
    super.dispose();
  }

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
                final characters = serverAPI.userCharacters.toList();
                final displayedCharacters = characters.length > 3
                    ? characters.sublist(0, 3)
                    : characters;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) {
                      if (index < displayedCharacters.length) {
                        return GestureDetector(
                          onTap: () async {
                            await _handleCharacterTap(
                                context, serverAPI, displayedCharacters[index]);
                          },
                          child: _buildCharacterBox(
                            displayedCharacters[index].characterName,
                          ),
                        );
                      } else if (index == displayedCharacters.length) {
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
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < 16; i++)
                        Stack(
                          children: [
                            // 外邊框層
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: _loadingIndex == i ? 40 : 30,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 2
                                  ..color = Colors.blue,
                                letterSpacing: 5,
                              ),
                              child: Text([
                                '我',
                                '最',
                                '喜',
                                '歡',
                                '玩',
                                '原',
                                '神',
                                '了',
                                '!',
                                '我',
                                '是',
                                '可',
                                '莉',
                                '玩',
                                '家',
                                '!'
                              ][i]),
                            ),
                            // 白色填充層
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: _loadingIndex == i ? 40 : 30,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 5,
                              ),
                              child: Text([
                                '我',
                                '最',
                                '喜',
                                '歡',
                                '玩',
                                '原',
                                '神',
                                '了',
                                '!',
                                '我',
                                '是',
                                '可',
                                '莉',
                                '玩',
                                '家',
                                '!'
                              ][i]),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleCharacterTap(BuildContext context, ServerAPI serverAPI,
      UserCharacter character) async {
    setState(() {
      isLoading = true;
    });

    try {
      final getCharacterListResult =
          await serverAPI.getCharacterList(character.characterId.toString());
      if (getCharacterListResult == 'getCharacterList success') {
        final getCardPoolResult = await serverAPI.getCardPool();
        if (getCardPoolResult == 'getCardPool success') {
          final String getCharacterBackpackResult = await serverAPI
              .getCharacterBackpack(character.characterId.toString());
          if (getCharacterBackpackResult == 'getCharacterBackpack success') {
            setState(() {
              isLoading = false;
            });
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: "加載角色失敗：$e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _showAddCharacterDialog(BuildContext context) {
    final TextEditingController characterNameController =
        TextEditingController();
    final serverAPI = Provider.of<ServerAPI>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: characterNameController,
                  decoration: const InputDecoration(
                    labelText: "角色名稱",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
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
                  // 關閉對話框
                  Navigator.of(context).pop();

                  setState(() {
                    isLoading = true;
                  });
                  // 註冊角色
                  await serverAPI.registerUser(characterName);

                  // 更新角色列表
                  await serverAPI.getUserCharacter();

                  setState(() {
                    isLoading = false;
                  });

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
