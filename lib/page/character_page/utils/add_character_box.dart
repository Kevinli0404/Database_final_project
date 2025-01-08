import 'package:flutter/material.dart';

class AddCharacterBox extends StatelessWidget {
  final VoidCallback onTap;

  const AddCharacterBox({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        height: 300,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            size: 40,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
