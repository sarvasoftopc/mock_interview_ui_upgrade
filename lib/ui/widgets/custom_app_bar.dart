import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../providers/auth_provider.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({
    Key? key,
    required BuildContext context,
    required String titleText,
    List<Widget>? extraActions,
  }) : super(
    key: key,
    title: Text(titleText),
    actions: [
      // 🔤 Global Language Switch
      PopupMenuButton<Locale>(
        icon: const Icon(Icons.language),
        onSelected: (locale) {
          InterviewPrepApp.of(context)?.setLocale(locale);
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: Locale('en'),
            child: Text("English"),
          ),
          const PopupMenuItem(
            value: Locale('hi'),
            child: Text("हिन्दी"),
          ),
        ],
      ),
      // ⚙️ Settings Button
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () {
          Navigator.pushNamed(context, '/settings');
        },
      ),
      IconButton(
        icon: const Icon(Icons.logout),
        onPressed: (){
          final auth = context.read<AuthProvider>(); // ✅ use read, not watch
          auth.signOut();
          Navigator.pushNamed(context, '/login');
        },
      ),
      // Any extra actions from a screen
      if (extraActions != null) ...extraActions,
    ],
  );
}