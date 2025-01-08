import 'package:database_final_project/provider/api.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showAddCharacterDialog({
  required BuildContext context,
  required TextEditingController controller,
  required ServerAPI serverAPI,
  required VoidCallback onRegisterSuccess,
  required VoidCallback onLoading,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: "角色名稱",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 關閉對話框
            },
            child: const Text("取消"),
          ),
          ElevatedButton(
            onPressed: () async {
              final characterName = controller.text.trim();
              if (characterName.isEmpty) {
                Fluttertoast.showToast(
                  msg: "角色名稱不能為空",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                );
                return;
              }

              try {
                // 關閉對話框
                Navigator.of(context).pop();

                onLoading(); // 開始加載狀態
                // 註冊角色
                await serverAPI.registerUser(characterName);

                // 更新角色列表
                await serverAPI.getUserCharacter();

                onRegisterSuccess(); // 完成加載狀態

                Fluttertoast.showToast(
                  msg: "角色添加成功",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                );
              } catch (e) {
                Fluttertoast.showToast(
                  msg: "角色添加失敗: $e",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                );
              }
            },
            child: const Text("確認"),
          ),
        ],
      );
    },
  );
}


// void showAddCharacterDialog(
//     BuildContext context, TextEditingController controller, ServerAPI serverAPI,
//     {required VoidCallback onRegisterSuccess, required VoidCallback onLoading}) {
//   showDialog(
//     context: context,
//     barrierDismissible: true,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: controller,
//                 decoration: const InputDecoration(
//                   labelText: "角色名稱",
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // 關閉對話框
//             },
//             child: const Text("取消"),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               final characterName = controller.text.trim();
//               if (characterName.isEmpty) {
//                 Fluttertoast.showToast(
//                   msg: "角色名稱不能為空",
//                   toastLength: Toast.LENGTH_SHORT,
//                   gravity: ToastGravity.CENTER,
//                   backgroundColor: Colors.red,
//                   textColor: Colors.white,
//                 );
//                 return;
//               }

//               try {
//                 Navigator.of(context).pop(); // 關閉對話框
//                 onLoading(); // 開啟加載狀態
//                 await serverAPI.registerUser(characterName);
//                 await serverAPI.getUserCharacter();
//                 onRegisterSuccess(); // 加載完成
//                 Fluttertoast.showToast(
//                   msg: "角色添加成功",
//                   toastLength: Toast.LENGTH_SHORT,
//                   gravity: ToastGravity.BOTTOM,
//                   backgroundColor: Colors.green,
//                   textColor: Colors.white,
//                 );
//               } catch (e) {
//                 Fluttertoast.showToast(
//                   msg: "角色添加失敗: $e",
//                   toastLength: Toast.LENGTH_SHORT,
//                   gravity: ToastGravity.CENTER,
//                   backgroundColor: Colors.red,
//                   textColor: Colors.white,
//                 );
//               }
//             },
//             child: const Text("確認"),
//           ),
//         ],
//       );
//     },
//   );
// }
