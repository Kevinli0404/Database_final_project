import 'dart:convert';
import 'package:database_final_project/class_data/obtain_card.dart';
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

    final List<ObtainCard> gachaResults = serverAPI.gachaTenTimesResults;

    return Scaffold(
      body: GestureDetector(
        onTap: () async {
          serverAPI.clearGachaTenTimesResults();
          sharedState.toggleDrawed(true);
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
                : (gachaResults.length == 10
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                                5, (index) => buildCard(gachaResults[index])),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5,
                                (index) => buildCard(gachaResults[index + 5])),
                          ),
                        ],
                      )
                    : Center(
                        child: buildCardLarge(gachaResults[0]),
                      )),
          ),
        ),
      ),
    );
  }

  Widget buildCard(ObtainCard card) {
    final int rarity = int.parse(card.rarity) + 2;

    return GestureDetector(
      onTap: () {
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
                card.cardImage,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }

  // 單抽時顯示放大的卡片
  Widget buildCardLarge(ObtainCard card) {
    final int rarity = int.parse(card.rarity) + 2;

    return GestureDetector(
      onTap: () {
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
            margin: const EdgeInsets.all(16.0),
            width: 200,
            height: 230,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: rarity == 5 ? gradient : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: rarity == 5 ? Colors.yellowAccent : Colors.transparent,
                width: rarity == 5 ? 3 : 0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                card.cardImage,
                fit: BoxFit.contain,
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
      },
    );
  }
}
