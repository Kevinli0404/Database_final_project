import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:database_final_project/provider/api.dart';
import 'package:database_final_project/class_data/user_character.dart';
import 'package:database_final_project/page/home_page.dart';

import 'package:database_final_project/page/character_page/utils/add_character_box.dart';
import 'package:database_final_project/page/character_page/utils/character_box.dart';
import 'package:database_final_project/page/character_page/utils/loading_overlay.dart';
import 'package:database_final_project/page/character_page/utils/show_add_character_dialog.dart';

class CharacterPage extends StatefulWidget {
  const CharacterPage({super.key});

  @override
  State<CharacterPage> createState() => _CharacterPageState();
}

class _CharacterPageState extends State<CharacterPage> {
  // 控制全螢幕遮罩
  bool isLoading = false;
  // 當前文字動畫索引
  int _loadingIndex = 0;
  late final Timer _loadingTimer;

  @override
  void initState() {
    super.initState();

    // 啟動文字動畫的 Timer
    _loadingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (isLoading) {
        setState(() {
          // 循環文字動畫索引
          _loadingIndex = (_loadingIndex + 1) % 16;
        });
      }
    });
  }

  @override
  void dispose() {
    // 停止 Timer
    _loadingTimer.cancel();
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
                  children: List.generate(3, (index) {
                    if (index < displayedCharacters.length) {
                      return CharacterBox(
                        title: displayedCharacters[index].characterName,
                        onTap: () async {
                          await _handleCharacterTap(
                              context, serverAPI, displayedCharacters[index]);
                        },
                      );
                    } else if (index == displayedCharacters.length) {
                      return AddCharacterBox(
                        onTap: () {
                          _showAddCharacterDialog(context, serverAPI);
                        },
                      );
                    } else {
                      return const CharacterBox(title: '', onTap: null);
                    }
                  }),
                );
              },
            ),
          ),
          // 加載動畫
          if (isLoading) LoadingOverlay(loadingIndex: _loadingIndex),
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

  void _showAddCharacterDialog(BuildContext context, ServerAPI serverAPI) {
    final TextEditingController characterNameController =
        TextEditingController();

    showAddCharacterDialog(
      context: context,
      controller: characterNameController,
      serverAPI: serverAPI,
      onRegisterSuccess: () {
        setState(() {
          isLoading = false;
        });
      },
      onLoading: () {
        setState(() {
          isLoading = true;
        });
      },
    );
  }
}
