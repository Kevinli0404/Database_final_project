import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:database_final_project/provider/api.dart';
import 'package:database_final_project/class_data/obtain_card.dart';

class BackpackScreen extends StatefulWidget {
  const BackpackScreen({super.key});

  @override
  State<BackpackScreen> createState() => _BackpackScreenState();
}

class _BackpackScreenState extends State<BackpackScreen> {
  @override
  Widget build(BuildContext context) {
    final serverAPI = Provider.of<ServerAPI>(context);

    final cardList = serverAPI.backpackCards;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "背包",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF8D6E63),
        toolbarHeight: 40,
      ),
      body: cardList.isEmpty
          ? const Center(child: Text("背包是空的"))
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
            ),
    );
  }

  void _showCardDetail(BuildContext context, ObtainCard card) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          // 米白色背景
          backgroundColor: const Color(0xFFFFF8E1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: SingleChildScrollView(
            child: Column(
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
                        _getStarCount(card.rarity),
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
                const SizedBox(height: 10),
                if (card.skillName != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "技能名稱: ${card.skillName ?? 'N/A'}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "技能消耗: ${card.skillCost ?? 'N/A'}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "技能傷害: ${card.skillDamage ?? 'N/A'}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _getStarCount(String rarity) {
    try {
      return int.parse(rarity)+2;
    } catch (e) {
      return 0;
    }
  }
}
