import 'package:flutter/material.dart';
import '../widgets/top_navigation_bar.dart';
import '../widgets/sidebar.dart';
import '../widgets/content_area.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const TopNavigationBar(),
          Expanded(
            child: Row(
              children: [
                const SizedBox(
                  width: 280,
                  child: Sidebar(),
                ),
                Container(
                  width: 1,
                  color: Theme.of(context).dividerColor,
                ),
                const Expanded(
                  child: ContentArea(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}