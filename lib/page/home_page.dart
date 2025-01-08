import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:database_final_project/provider/shared_state.dart';

import 'package:database_final_project/screen/home_screen/home_screen.dart';
import 'package:database_final_project/screen/backpack_screen.dart';
import 'package:database_final_project/screen/store_screen.dart';
import 'package:database_final_project/screen/card_display_page/card_display_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final List<Widget> _pages = [
    const HomeScreen(),
    const BackpackScreen(),
    const StoreScreen(),
    const CardDisplayPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final sharedState = Provider.of<SharedState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FF),
      body: IndexedStack(
        index: sharedState.currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: sharedState.buttonsDrawed
          ? Container(
              height: 35,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.home,
                      color: sharedState.currentIndex == 0
                          ? Colors.blue
                          : Colors.grey,
                      size: 24,
                    ),
                    onPressed: sharedState.buttonsDisabled
                        ? null
                        : () {
                            sharedState.updateCurrentIndex(0);
                          },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.backpack,
                      color: sharedState.currentIndex == 1
                          ? Colors.blue
                          : Colors.grey,
                      size: 24,
                    ),
                    onPressed: sharedState.buttonsDisabled
                        ? null
                        : () {
                            sharedState.updateCurrentIndex(1);
                          },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.shopping_bag_outlined,
                      color: sharedState.currentIndex == 2
                          ? Colors.blue
                          : Colors.grey,
                      size: 24,
                    ),
                    onPressed: sharedState.buttonsDisabled
                        ? null
                        : () {
                            sharedState.updateCurrentIndex(2);
                          },
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
