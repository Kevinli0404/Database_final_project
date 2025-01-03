import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // 引入 Toast 插件
import 'package:provider/provider.dart';
import 'package:database_final_project/provider/api.dart';

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
                          onTap: null, // 点击无响应
                          child: _buildCharacterBox(
                            characters[index].characterName,
                          ),
                        );
                      } else if (index == characters.length) {
                        // 显示 + 按钮
                        return GestureDetector(
                          onTap: () {
                            _showAddCharacterDialog(context, serverAPI);
                          },
                          child: _buildAddCharacterBox(),
                        );
                      } else {
                        // 无角色时显示空框
                        return GestureDetector(
                          onTap: null, // 点击无响应
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

  // 显示添加角色的对话框
  void _showAddCharacterDialog(BuildContext context, ServerAPI serverAPI) {
    final TextEditingController _characterNameController =
        TextEditingController();
    bool isProcessing = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true, // 启用滚动
              title: const Text('輸入角色名稱'),
              content: TextField(
                controller: _characterNameController,
                decoration: const InputDecoration(
                  labelText: '角色名稱',
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isProcessing
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : () async {
                          final characterName =
                              _characterNameController.text.trim();
                          if (characterName.isNotEmpty) {
                            setState(() {
                              isProcessing = true;
                            });
                            await _handleAddCharacter(
                                context, serverAPI, characterName);
                            if (!context.mounted) return;
                            setState(() {
                              isProcessing = false;
                            });
                            Navigator.of(context).pop();
                          } else {
                            Fluttertoast.showToast(
                              msg: "角色名稱不能為空",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                          }
                        },
                  child: isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('確認'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 添加角色逻辑
  Future<void> _handleAddCharacter(
      BuildContext context, ServerAPI serverAPI, String characterName) async {
    try {
      await serverAPI.registerUser(characterName); // 调用注册 API
      await serverAPI.getUserCharacter(); // 更新角色数据
      Fluttertoast.showToast(
        msg: "角色已成功添加！",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "添加角色失败：$e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
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
