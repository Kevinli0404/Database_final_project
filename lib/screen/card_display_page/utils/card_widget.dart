import 'package:flutter/material.dart';
import 'package:database_final_project/class_data/obtain_card.dart';

class CardWidget extends StatelessWidget {
  final ObtainCard card;
  final bool isLarge;
  final Animation<double> animation;
  final VoidCallback onTap;

  const CardWidget({
    super.key,
    required this.card,
    required this.isLarge,
    required this.animation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final int rarity = int.parse(card.rarity) + 2;

    final gradient = LinearGradient(
      colors: [
        Colors.yellowAccent,
        Colors.orangeAccent,
        Colors.yellowAccent.withOpacity(0.5),
      ],
      stops: [
        0.0,
        (animation.value + 0.5) % 1.0,
        1.0,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        width: isLarge ? 200 : 100,
        height: isLarge ? 230 : 115,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isLarge ? 20 : 15),
          gradient: rarity == 5 ? gradient : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isLarge ? 0.5 : 0.3),
              blurRadius: isLarge ? 10 : 5,
              offset: Offset(0, isLarge ? 5 : 3),
            ),
          ],
          border: Border.all(
            color: rarity == 5 ? Colors.yellowAccent : Colors.transparent,
            width: rarity == 5 ? (isLarge ? 3 : 2) : 0,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isLarge ? 20 : 15),
          child: Image.asset(
            card.cardImage,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
