import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:database_final_project/provider/api.dart';
import 'package:database_final_project/provider/shared_state.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  late Future<List<StoreItem>> _storeItems;
  bool isLoading = false; // 控制全螢幕遮罩
  int _loadingIndex = 0; // 當前文字動畫索引
  late final Timer _loadingTimer;

  @override
  void initState() {
    super.initState();
    _storeItems = loadStoreItems();

    // 啟動文字動畫的 Timer
    _loadingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (isLoading) {
        setState(() {
          _loadingIndex = (_loadingIndex + 1) % 4;
        });
      }
    });
  }

  @override
  void dispose() {
    _loadingTimer.cancel(); // 停止 Timer
    super.dispose();
  }

  // 載入 JSON 並解析為 StoreItem 列表
  Future<List<StoreItem>> loadStoreItems() async {
    final String response =
        await rootBundle.loadString('assets/json/top_up.json');
    final List<dynamic> data = jsonDecode(response);
    return data.map((json) => StoreItem.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "創世結晶商城",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue, // 設置主題色
        toolbarHeight: 40,
      ),
      backgroundColor: const Color(0xFFF5F5F5), // 設置背景顏色
      body: Stack(
        children: [
          FutureBuilder<List<StoreItem>>(
            future: _storeItems,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("載入失敗: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("沒有可購買的商品"));
              } else {
                final items = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // 每行顯示 4 個格子
                    mainAxisSpacing: 16.0, // 垂直間距
                    crossAxisSpacing: 16.0, // 水平間距
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () {
                        _showItemDetail(context, item);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                              child: Image.asset(
                                item.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '創世結晶 x ${item.ticket}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'NT\$${item.twd}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < 4; i++)
                        Stack(
                          children: [
                            // 外邊框層
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: _loadingIndex == i ? 40 : 30,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 2
                                  ..color = Colors.blue,
                                letterSpacing: 5,
                              ),
                              child: Text(['原', '又', '贏', '~'][i]),
                            ),
                            // 白色填充層
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: _loadingIndex == i ? 40 : 30,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 5,
                              ),
                              child: Text(['原', '又', '贏', '~'][i]),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showItemDetail(BuildContext context, StoreItem item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '創世結晶 x ${item.ticket}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  width: 50,
                  child: Image.asset(
                    item.image,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '價格: NT\$${item.twd}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "取消",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () async {
                        final serverAPI =
                            Provider.of<ServerAPI>(context, listen: false);
                        final sharedState =
                            Provider.of<SharedState>(context, listen: false);
                        Navigator.pop(context);
                        sharedState.setButtonsDisabled(true);
                        setState(() {
                          isLoading = true;
                        });

                        final String topUpResult = await serverAPI.topUp(
                          characterID:
                              serverAPI.characterData!.characterId.toString(),
                          topUpGem: item.ticket,
                        );

                        if (topUpResult == 'topUp success') {
                          await serverAPI.getCharacterList(
                              serverAPI.characterData!.characterId.toString());
                          sharedState.setButtonsDisabled(false);
                          setState(() {
                            isLoading = false;
                          });
                          Fluttertoast.showToast(
                            msg: "購買成功",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        } else {
                          sharedState.setButtonsDisabled(false);
                          setState(() {
                            isLoading = false;
                          });
                          Fluttertoast.showToast(
                            msg: "購買失敗",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                      },
                      child: const Text("確認"),
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
}

class StoreItem {
  final String id;
  final String image;
  final String twd;
  final String ticket;

  StoreItem({
    required this.id,
    required this.image,
    required this.twd,
    required this.ticket,
  });

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    return StoreItem(
      id: json['top_up_id'],
      image: json['top_up_image'],
      twd: json['TWD'],
      ticket: json['ticket'],
    );
  }
}
