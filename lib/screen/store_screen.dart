import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:database_final_project/provider/api.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  late Future<List<StoreItem>> _storeItems;

  @override
  void initState() {
    super.initState();
    _storeItems = loadStoreItems();
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
        title: const Text(
          "創世結晶商城",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue, // 設置主題色
        toolbarHeight: 40,
      ),
      backgroundColor: const Color(0xFFF5F5F5), // 設置背景顏色
      body: FutureBuilder<List<StoreItem>>(
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
    );
  }

  void _showItemDetail(BuildContext context, StoreItem item) {
    final TextEditingController cardNumberController = TextEditingController();
    final TextEditingController expiryDateController = TextEditingController();
    final TextEditingController cvvController = TextEditingController();

    void disposeControllers() {
      cardNumberController.dispose();
      expiryDateController.dispose();
      cvvController.dispose();
    }

    bool areFieldsEmpty() {
      return cardNumberController.text.isEmpty ||
          expiryDateController.text.isEmpty ||
          cvvController.text.isEmpty;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                      height: 50, // 限制圖片高度
                      width: 50, // 限制圖片寬度
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
                    const SizedBox(height: 10),
                    // 添加三個輸入框
                    TextField(
                      controller: cardNumberController,
                      decoration: const InputDecoration(
                        labelText: '輸入信用卡卡號',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: expiryDateController,
                      decoration: const InputDecoration(
                        labelText: '輸入到期日期',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: cvvController,
                      decoration: const InputDecoration(
                        labelText: '輸入後三碼',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 20),
                    // 按钮作为 Column 的一部分
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            disposeControllers();
                          },
                          child: const Text(
                            "取消",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                areFieldsEmpty() ? Colors.grey : Colors.blue,
                          ),
                          onPressed: areFieldsEmpty()
                              ? null
                              : () async {
                                  final serverAPI = Provider.of<ServerAPI>(
                                      context,
                                      listen: false);
                                  log('item.ticket : ${item.ticket}');
                                  log('item.ticket : ${item.ticket}');
                                  final String topUpResult =
                                      await serverAPI.topUp(
                                    characterID: serverAPI
                                        .characterData!.characterId
                                        .toString(),
                                    topUpGem: item.ticket,
                                  );

                                  if (topUpResult == 'topUp success') {
                                    await serverAPI.getUserCharacter();
                                    Navigator.pop(context);
                                    disposeControllers();
                                    Fluttertoast.showToast(
                                      msg: "購買成功",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                  } else {
                                    Navigator.pop(context);
                                    disposeControllers();
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
