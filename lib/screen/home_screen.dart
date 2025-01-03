import 'package:flutter/material.dart';
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
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              cardPool[selectedIndex].cardName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
