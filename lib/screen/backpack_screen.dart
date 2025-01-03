import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackpackScreen extends StatefulWidget {
  const BackpackScreen({super.key});

  @override
  State<BackpackScreen> createState() => _BackpackScreenState();
}

class _BackpackScreenState extends State<BackpackScreen> {
  late Future<List<CardItem>> _cardList;

  @override
  void initState() {
    super.initState();
    _cardList = loadCards(); // 加载卡片列表
  }

  // 加载 JSON 并解析为 CardItem 列表
  Future<List<CardItem>> loadCards() async {
    final String response =
        await rootBundle.loadString('assets/json/cards.json');
    final List<dynamic> data = jsonDecode(response);
    return data.map((json) => CardItem.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "背包",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF8D6E63),
        toolbarHeight: 40,
      ),
      body: FutureBuilder<List<CardItem>>(
        future: _cardList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("加载失败: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("背包为空"));
          } else {
            final cardList = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                //每行顯示幾個格子
                crossAxisCount: 6,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: cardList.length,
              itemBuilder: (context, index) {
                final card = cardList[index];
                return GestureDetector(
                  onTap: () {
                    _showCardDetail(context, card);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child:
                              Image.asset(card.cardImage, fit: BoxFit.contain),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          card.cardName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showCardDetail(BuildContext context, CardItem card) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
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
                    card.cardName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      _getStarCount(card.cardRarity),
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
                card.cardImage,
                height: 150,
                width: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              Text(
                card.cardDescription,
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

  int _getStarCount(String rarity) {
    try {
      return int.parse(rarity);
    } catch (e) {
      return 0;
    }
  }
}

// 卡片数据模型
class CardItem {
  final String cardId;
  final String cardImage;
  final String cardName;
  final String cardRarity;
  final String cardDescription;

  CardItem({
    required this.cardId,
    required this.cardImage,
    required this.cardName,
    required this.cardRarity,
    required this.cardDescription,
  });

  factory CardItem.fromJson(Map<String, dynamic> json) {
    return CardItem(
      cardId: json['card_id'],
      cardImage: json['card_image'],
      cardName: json['card_name'],
      cardRarity: json['card_rarity'],
      cardDescription: json['card_description'],
    );
  }
}
