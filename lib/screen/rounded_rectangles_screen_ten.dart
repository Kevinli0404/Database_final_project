import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:database_final_project/provider/shared_state.dart';
import 'package:provider/provider.dart';

class RoundedRectanglesScreenTen extends StatefulWidget {
  const RoundedRectanglesScreenTen({super.key});

  @override
  State<RoundedRectanglesScreenTen> createState() =>
      _RoundedRectanglesScreenTenState();
}

class _RoundedRectanglesScreenTenState extends State<RoundedRectanglesScreenTen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> cards = []; // 儲存卡片數據
  late AnimationController _controller; // 控制動畫

  @override
  void initState() {
    super.initState();
    loadCardData(); // 載入 JSON 數據
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // 動畫循環
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 從 assets/json/cards.json 載入卡片數據
  Future<void> loadCardData() async {
    final String response =
        await rootBundle.loadString('assets/json/cards.json');
    final List<dynamic> data = json.decode(response);

    setState(() {
      cards = data.cast<Map<String, dynamic>>();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sharedState = Provider.of<SharedState>(context);
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // 點擊背景時改變狀態
          sharedState.toggleDrawed();
          sharedState.updateCurrentIndex(0);
        },
        child: Container(
          // 設置背景圖片
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/logo/milky_way.png'), // 背景圖片路徑
              fit: BoxFit.cover, // 讓圖片填滿整個畫面
            ),
          ),
          child: Center(
            child: cards.isEmpty
                ? const CircularProgressIndicator() // 如果數據還在載入中
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 上排顯示 5 張卡片
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: cards
                            .sublist(0, 5)
                            .map((card) => buildCard(card))
                            .toList(),
                      ),
                      const SizedBox(height: 20), // 上下排間距
                      // 下排顯示 5 張卡片
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: cards
                            .sublist(5, 10)
                            .map((card) => buildCard(card))
                            .toList(),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // 構建每個卡片
  Widget buildCard(Map<String, dynamic> card) {
    final int rarity = int.parse(card['card_rarity']);

    return GestureDetector(
      onTap: () {
        // 點擊卡片顯示詳細資訊
        _showCardDetail(context, card);
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final gradient = LinearGradient(
            colors: [
              Colors.yellowAccent,
              Colors.orangeAccent,
              Colors.yellowAccent.withOpacity(0.5),
            ],
            stops: [
              0.0,
              (_controller.value + 0.5) % 1.0,
              1.0,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

          return Container(
            margin: const EdgeInsets.all(8.0), // 卡片間距
            width: 100, // 卡片寬度
            height: 115, // 卡片高度
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), // 圓角
              gradient: rarity == 5 ? gradient : null, // 動態閃耀效果
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 3), // 陰影位置
                ),
              ],
              border: Border.all(
                color: rarity == 5 ? Colors.yellowAccent : Colors.transparent,
                width: rarity == 5 ? 2 : 0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                card['card_image'], // 卡片圖片
                fit: BoxFit.contain, // 填滿整個 Container
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          );
        },
      ),
    );
  }

  // 顯示卡片詳細資訊的對話框
  void _showCardDetail(BuildContext context, Map<String, dynamic> card) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final int rarity = int.parse(card['card_rarity']);
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF8E1), // 米白色背景
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    card['card_name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      rarity,
                      (index) => const Icon(
                        Icons.star,
                        color: Colors.yellow,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Image.asset(
                card['card_image'],
                height: 150,
                width: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              Text(
                card['card_description'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
