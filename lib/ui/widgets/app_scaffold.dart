import 'package:flutter/material.dart';

import '../widgets/custom_app_bar.dart'; // your existing CustomAppBar
import 'app_drawer.dart';

/// AppScaffold is a drop-in replacement for Scaffold that ensures consistent AppBar + Drawer.
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final PreferredSizeWidget? appBar; // optional custom appbar
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool centerTitle;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ?? CustomAppBar(context: context, titleText: title),
      drawer: const AppDrawer(),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
