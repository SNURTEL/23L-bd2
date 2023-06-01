import 'package:flutter/material.dart';

class Logout extends StatelessWidget {
  final VoidCallback logoutCallback;

  const Logout({super.key, required this.logoutCallback,});

  @override
  Widget build(BuildContext context) {
    return Center
      (child: FilledButton(
        onPressed: logoutCallback,
        child: const Text('LogOut'))
    );
  }
}