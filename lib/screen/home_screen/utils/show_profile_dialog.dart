import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:database_final_project/provider/api.dart';
import 'package:database_final_project/screen/home_screen/utils/build_value.dart';
import 'package:database_final_project/screen/home_screen/utils/build_label.dart';

void showProfileDialog(BuildContext context) {
  final serverAPI = Provider.of<ServerAPI>(context, listen: false);

  // 獲取角色數據
  final characterData = serverAPI.characterData;

  showDialog(
    context: context,
    barrierDismissible: true, // 點擊外部關閉對話框
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF8D6E63), // 外層深棕色
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(4), // 深棕色邊框的厚度
          child: Container(
            decoration: BoxDecoration(
              color: Colors.amber.shade50, // 內層淺棕色
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 350,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 佔用所需高度
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "冒險者日誌",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    characterData == null
                        ? const Center(
                            child: Text("無角色數據"),
                          )
                        : Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 100, // 左列寬度
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildLabel("角色名"),
                                        buildLabel("VIP等級"),
                                        buildLabel("創建時間"),
                                        buildLabel("寶石數量"),
                                        buildLabel("首充狀態"),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 250, // 右列寬度
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildValue(characterData.characterName),
                                        buildValue(
                                          characterData.vipLevel.toString(),
                                          color:
                                              const Color(0xFFFFD700), // 設置為金色
                                        ),
                                        buildValue(characterData.createTime),
                                        buildValue(
                                            characterData.gem.toString()),
                                        buildValue(
                                          characterData.topUpState == 1
                                              ? "已完成"
                                              : "未完成",
                                          color: characterData.topUpState == 1
                                              ? Colors.black
                                              : Colors.red, // 設置紅色
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
