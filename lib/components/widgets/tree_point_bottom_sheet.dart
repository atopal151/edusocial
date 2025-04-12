import 'package:flutter/material.dart';

class TreePointBottomSheet extends StatelessWidget {
  const TreePointBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.person, color: Color(0xfffb535c)),
              title: const Text(
                "Bu hesap hakkında",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff414751)),
              ),
              onTap: () {
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.warning_rounded,
                color: Color(0xfffb535c),
              ),
              title: const Text("Şikayet Et",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff414751))),
              onTap: () {
              },
            ),
            
          ],
        ),
      ),
    );
  }
}
