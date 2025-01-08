import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:database_final_project/provider/api.dart';
import 'package:database_final_project/provider/shared_state.dart';
import 'package:database_final_project/screen/home_screen/utils/show_profile_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  bool isLoading = false; // 控制全屏遮罩的狀態
  int _loadingIndex = 0; // 當前顯示字的索引
  late Timer _loadingTimer;

  @override
  void initState() {
    super.initState();

    // 啟動 Timer 用於控制字體動畫
    _loadingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (isLoading) {
        setState(() {
          _loadingIndex = (_loadingIndex + 1) % 14; // 循環切換索引
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
    final serverAPI = Provider.of<ServerAPI>(context);
    final sharedState = Provider.of<SharedState>(context);

    // 獲取 CardPool 數據
    final cardPool = serverAPI.cardPool;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FF),
      body: Stack(
        children: [
          SafeArea(
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
                                    showProfileDialog(context);
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
                                children:
                                    List.generate(cardPool.length, (index) {
                                  final card = cardPool[index];
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedIndex = index;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8.0),
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
                                              cardPool[selectedIndex]
                                                  .cardImage),
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
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    '${(cardPool[selectedIndex].highRarityProbability * 100).toStringAsFixed(2)}%', // 格式化為兩位小數，並加上 %
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              final serverAPI =
                                                  Provider.of<ServerAPI>(
                                                      context,
                                                      listen: false);
                                              final selectedCardPoolID =
                                                  serverAPI
                                                      .cardPool[selectedIndex]
                                                      .cardPoolId;
                                              //當前寶石數量
                                              final currentGem = serverAPI
                                                      .characterData?.gem ??
                                                  0;

                                              if (currentGem < 160) {
                                                // 寶石不足
                                                Fluttertoast.showToast(
                                                  msg: "寶石不足抽取失敗",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  backgroundColor: Colors.red,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0,
                                                );
                                                return;
                                              }

                                              // 開啟轉場遮擋層
                                              setState(() {
                                                isLoading = true;
                                              });
                                              sharedState
                                                  .setButtonsDisabled(true);

                                              final String gachaTenTimesResult =
                                                  await serverAPI.gachaOnce(
                                                characterID: serverAPI
                                                    .characterData!.characterId
                                                    .toString(),
                                                cardPoolID: selectedCardPoolID
                                                    .toString(),
                                              );
                                              log('gachaTenTimesResult = $gachaTenTimesResult');
                                              if (gachaTenTimesResult ==
                                                  'gachaOnce success') {
                                                await serverAPI
                                                    .getCharacterList(serverAPI
                                                        .characterData!
                                                        .characterId
                                                        .toString());
                                                await serverAPI
                                                    .getCharacterBackpack(
                                                        serverAPI.characterData!
                                                            .characterId
                                                            .toString());
                                                // 關閉轉場層，進行跳轉
                                                setState(() {
                                                  isLoading = false;
                                                });
                                                sharedState
                                                    .setButtonsDisabled(false);
                                                sharedState.toggleDrawed(false);
                                                sharedState
                                                    .updateCurrentIndex(3);
                                              } else {
                                                sharedState
                                                    .setButtonsDisabled(false);
                                                setState(() {
                                                  isLoading = false;
                                                });
                                                Fluttertoast.showToast(
                                                  msg: "抽取失敗",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4.0,
                                                      horizontal: 8.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                    '祈願1次',
                                                    style: TextStyle(
                                                      color: Color(0xFF8D6E63),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Image.asset(
                                                        'assets/logo/gen_stone.png',
                                                        width: 12,
                                                        height: 12,
                                                      ),
                                                      const SizedBox(width: 2),
                                                      const Text(
                                                        'x 160',
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xFF8D6E63),
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
                                                  Provider.of<ServerAPI>(
                                                      context,
                                                      listen: false);
                                              final selectedCardPoolID =
                                                  serverAPI
                                                      .cardPool[selectedIndex]
                                                      .cardPoolId;
                                              //當前寶石數量
                                              final currentGem = serverAPI
                                                      .characterData?.gem ??
                                                  0;

                                              if (currentGem < 1600) {
                                                // 寶石不足
                                                Fluttertoast.showToast(
                                                  msg: "寶石不足抽取失敗",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  backgroundColor: Colors.red,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0,
                                                );
                                                return;
                                              }

                                              // 開啟轉場遮擋層
                                              setState(() {
                                                isLoading = true;
                                              });
                                              sharedState
                                                  .setButtonsDisabled(true);

                                              final String gachaTenTimesResult =
                                                  await serverAPI.gachaTenTimes(
                                                characterID: serverAPI
                                                    .characterData!.characterId
                                                    .toString(),
                                                cardPoolID: selectedCardPoolID
                                                    .toString(),
                                              );
                                              if (gachaTenTimesResult ==
                                                  'gachaTenTimes success') {
                                                await serverAPI
                                                    .getCharacterList(serverAPI
                                                        .characterData!
                                                        .characterId
                                                        .toString());
                                                await serverAPI
                                                    .getCharacterBackpack(
                                                        serverAPI.characterData!
                                                            .characterId
                                                            .toString());
                                                // 關閉轉場層，進行跳轉
                                                setState(() {
                                                  isLoading = false;
                                                });

                                                sharedState
                                                    .setButtonsDisabled(false);
                                                sharedState.toggleDrawed(false);
                                                sharedState
                                                    .updateCurrentIndex(3);
                                              } else {
                                                sharedState
                                                    .setButtonsDisabled(false);
                                                setState(() {
                                                  isLoading = false;
                                                });
                                                Fluttertoast.showToast(
                                                  msg: "抽取失敗",
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4.0,
                                                      horizontal: 8.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                    '祈願10次',
                                                    style: TextStyle(
                                                      color: Color(0xFF8D6E63),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Image.asset(
                                                        'assets/logo/gen_stone.png',
                                                        width: 12,
                                                        height: 12,
                                                      ),
                                                      const SizedBox(width: 2),
                                                      const Text(
                                                        'x 1600',
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xFF8D6E63),
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
          if (isLoading)
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.black.withOpacity(0.5), // 半透明遮罩
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < 14; i++)
                          Stack(
                            children: [
                              // 外邊框層
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize:
                                      _loadingIndex == i ? 40 : 30, // 當前字母變大
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke // 外框
                                    ..strokeWidth = 2 // 外框粗細
                                    ..color = Colors.blue, // 外框顏色
                                  letterSpacing: 5, // 字母間距
                                ),
                                child: Text([
                                  '你',
                                  '說',
                                  '的',
                                  '對',
                                  '!',
                                  '但',
                                  '是',
                                  '原',
                                  '神',
                                  '是',
                                  '由',
                                  '.',
                                  '.',
                                  '.'
                                ][i]),
                              ),
                              // 白色填充層
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize:
                                      _loadingIndex == i ? 40 : 30, // 當前字母變大
                                  color: Colors.white, // 內部填充顏色
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 5, // 字母間距
                                ),
                                child: Text([
                                  '你',
                                  '說',
                                  '的',
                                  '對',
                                  '!',
                                  '但',
                                  '是',
                                  '原',
                                  '神',
                                  '是',
                                  '由',
                                  '.',
                                  '.',
                                  '.'
                                ][i]),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
