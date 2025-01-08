import 'package:flutter/material.dart';
import 'package:database_final_project/class_data/obtain_card.dart';

class CardDetailDialog extends StatelessWidget {
  final ObtainCard card;

  const CardDetailDialog({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final int rarity = int.parse(card.rarity) + 2;

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
                card.cardName,
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
  }
}
