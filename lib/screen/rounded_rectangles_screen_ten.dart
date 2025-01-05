import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:database_final_project/provider/api.dart';
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
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serverAPI = Provider.of<ServerAPI>(context);
    final sharedState = Provider.of<SharedState>(context);

    final List<Map<String, dynamic>> gachaResults =
        serverAPI.gachaTenTimesResults;

    return Scaffold(
      body: GestureDetector(
        onTap: () async {
          serverAPI.clearGachaTenTimesResults();
          // 點擊背景時改變狀態並切換頁面
          sharedState.toggleDrawed();
          sharedState.updateCurrentIndex(0);
        },
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/logo/milky_way.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: gachaResults.isEmpty
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: gachaResults
                            .sublist(0, 5)
                            .map((card) => buildCard(card))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: gachaResults
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

  Widget buildCard(Map<String, dynamic> card) {
    final int rarity = int.parse(card['gacha_result']['rarity'])+2;

    return GestureDetector(
      onTap: () {
        _showCardDetail(context, card['gacha_result']);
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
            margin: const EdgeInsets.all(8.0),
            width: 100,
            height: 115,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: rarity == 5 ? gradient : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
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
                card['gacha_result']['card_image'],
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCardDetail(BuildContext context, Map<String, dynamic> card) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final int rarity = int.parse(card['rarity']);
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF8E1),
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
