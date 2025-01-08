import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:database_final_project/class_data/obtain_card.dart';
import 'package:database_final_project/provider/api.dart';
import 'package:database_final_project/provider/shared_state.dart';
import 'package:database_final_project/screen/card_display_page/utils/card_widget.dart';
import 'package:database_final_project/screen/card_display_page/utils/card_detail_dialog.dart';

class CardDisplayPage extends StatefulWidget {
  const CardDisplayPage({super.key});

  @override
  State<CardDisplayPage> createState() => _CardDisplayPageState();
}

class _CardDisplayPageState extends State<CardDisplayPage>
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
                              5,
                              (index) => CardWidget(
                                card: gachaResults[index],
                                isLarge: false,
                                animation: _controller,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (context) => CardDetailDialog(
                                        card: gachaResults[index]),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              5,
                              (index) => CardWidget(
                                card: gachaResults[index + 5],
                                isLarge: false,
                                animation: _controller,
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (context) => CardDetailDialog(
                                        card: gachaResults[index + 5]),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      )
                    : CardWidget(
                        card: gachaResults[0],
                        isLarge: true,
                        animation: _controller,
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (context) =>
                                CardDetailDialog(card: gachaResults[0]),
                          );
                        },
                      )),
          ),
        ),
      ),
    );
  }
}
