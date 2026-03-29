import 'package:flutter/material.dart';

class UserScreen extends StatelessWidget {
  static const String pageLabel = "Home";
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(title: Text(UserScreen.pageLabel)),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text("Welcome")),
        ),
      ],
    );
  }
}
