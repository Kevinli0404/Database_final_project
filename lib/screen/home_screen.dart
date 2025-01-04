import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:database_final_project/provider/api.dart';
import 'package:database_final_project/provider/shared_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final serverAPI = Provider.of<ServerAPI>(context);
    final sharedState = Provider.of<SharedState>(context);

    // 獲取 CardPool 數據
    final cardPool = serverAPI.cardPool;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FF),
      body: SafeArea(
        child: cardPool.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Row(
                children: [
                  // 左側卡池選擇欄
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 6.0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showProfileDialog(context);
                              },
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/character_pictures/1.jpg',
                                    fit: BoxFit.cover,
                                    width: 40,
                                    height: 40,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'VIP ${serverAPI.characterData?.vipLevel ?? 0}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFFD700), // 字體顏色金色
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: List.generate(cardPool.length, (index) {
                              final card = cardPool[index];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  width: 80,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: selectedIndex == index
                                        ? Colors.blueAccent.withOpacity(0.5)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: AssetImage(card.cardImage),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 右側大區域
                  Expanded(
                    child: cardPool.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : Container(
                            margin: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // 卡池圖像展示
                                Container(
                                  margin: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    image: DecorationImage(
                                      image: AssetImage(
                                          cardPool[selectedIndex].cardImage),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                // 底部信息展示
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Center(
                                          child: Row(
                                            children: [
                                              Text(
                                                cardPool[selectedIndex]
                                                    .cardName,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                '${(cardPool[selectedIndex].fakeHighRarityProbability * 100).toStringAsFixed(2)}%', // 格式化為兩位小數，並加上 %
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(
                                                width: 50,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // 祈願按鈕
                                Positioned(
                                  bottom: 17,
                                  right: 30,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          final serverAPI =
                                              Provider.of<ServerAPI>(context,
                                                  listen: false);
                                          final selectedCardPoolID = serverAPI
                                              .cardPool[selectedIndex]
                                              .cardPoolId;
                                          //當前寶石數量
                                          final currentGem =
                                              serverAPI.characterData?.gem ?? 0;

                                          if (currentGem < 160) {
                                            // 寶石不足
                                            Fluttertoast.showToast(
                                              msg: "寶石不足抽取失敗",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 16.0,
                                            );
                                            return;
                                          }

                                          final String gachaOnceResult =
                                              await serverAPI.gachaOnce(
                                            characterID: serverAPI
                                                .characterData!.characterId
                                                .toString(),
                                            cardPoolID:
                                                selectedCardPoolID.toString(),
                                          );

                                          if (gachaOnceResult ==
                                              'gachaOnce success') {
                                            await serverAPI.getCharacterList(
                                                serverAPI
                                                    .characterData!.characterId
                                                    .toString());
                                            sharedState.toggleDrawed();
                                            sharedState.updateCurrentIndex(3);
                                          } else {
                                            Fluttertoast.showToast(
                                              msg: "抽取失敗",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 16.0,
                                            );
                                          }
                                        },
                                        child: Container(
                                          width: 70,
                                          decoration: BoxDecoration(
                                            color: Colors.amber.shade50,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                blurRadius: 5,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0, horizontal: 8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                '祈願1次',
                                                style: TextStyle(
                                                  color: Color(0xFF8D6E63),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/logo/gen_stone.png',
                                                    width: 12,
                                                    height: 12,
                                                  ),
                                                  const SizedBox(width: 2),
                                                  const Text(
                                                    'x 10',
                                                    style: TextStyle(
                                                      color: Color(0xFF8D6E63),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () async {
                                          final serverAPI =
                                              Provider.of<ServerAPI>(context,
                                                  listen: false);
                                          final selectedCardPoolID = serverAPI
                                              .cardPool[selectedIndex]
                                              .cardPoolId;
                                          //當前寶石數量
                                          final currentGem =
                                              serverAPI.characterData?.gem ?? 0;

                                          if (currentGem < 1600) {
                                            // 寶石不足
                                            Fluttertoast.showToast(
                                              msg: "寶石不足抽取失敗",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 16.0,
                                            );
                                            return;
                                          }

                                          final String gachaTenTimesResult =
                                              await serverAPI.gachaTenTimes(
                                            characterID: serverAPI
                                                .characterData!.characterId
                                                .toString(),
                                            cardPoolID:
                                                selectedCardPoolID.toString(),
                                          );
                                          if (gachaTenTimesResult ==
                                              'gachaTenTimes success') {
                                            await serverAPI.getCharacterList(
                                                serverAPI
                                                    .characterData!.characterId
                                                    .toString());
                                            sharedState.toggleDrawed();
                                            sharedState.updateCurrentIndex(4);
                                          } else {
                                            Fluttertoast.showToast(
                                              msg: "抽取失敗",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              fontSize: 16.0,
                                            );
                                          }
                                        },
                                        child: Container(
                                          width: 70,
                                          decoration: BoxDecoration(
                                            color: Colors.amber.shade50,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                blurRadius: 5,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0, horizontal: 8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                '祈願10次',
                                                style: TextStyle(
                                                  color: Color(0xFF8D6E63),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/logo/gen_stone.png',
                                                    width: 12,
                                                    height: 12,
                                                  ),
                                                  const SizedBox(width: 2),
                                                  const Text(
                                                    'x 100',
                                                    style: TextStyle(
                                                      color: Color(0xFF8D6E63),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    final serverAPI = Provider.of<ServerAPI>(context, listen: false);

    // 獲取角色數據
    final characterData = serverAPI.characterData;

    showDialog(
      context: context,
      barrierDismissible: true, // 點擊外部關閉對話框
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF8D6E63), // 外層深棕色
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(4), // 深棕色邊框的厚度
            child: Container(
              decoration: BoxDecoration(
                color: Colors.amber.shade50, // 內層淺棕色
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 350,
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // 佔用所需高度
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "冒險者日誌",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      characterData == null
                          ? const Center(
                              child: Text("無角色數據"),
                            )
                          : Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 100, // 左列寬度
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel("角色名"),
                                          _buildLabel("VIP等級"),
                                          _buildLabel("創建時間"),
                                          _buildLabel("寶石數量"),
                                          _buildLabel("首充狀態"),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 200, // 右列寬度
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildValue(
                                              characterData.characterName),
                                          _buildValue(
                                            characterData.vipLevel.toString(),
                                            color: const Color(
                                                0xFFFFD700), // 設置為金色
                                          ),
                                          _buildValue(characterData.createTime),
                                          _buildValue(
                                              characterData.gem.toString()),
                                          _buildValue(
                                            characterData.topUpState == 1
                                                ? "已完成"
                                                : "未完成",
                                            color: characterData.topUpState == 1
                                                ? Colors.black
                                                : Colors.red, // 設置紅色
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 創建標籤方法
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        "$text：",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  // 創建值方法，支持可選顏色
  Widget _buildValue(String text, {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: color,
        ),
      ),
    );
  }
}
