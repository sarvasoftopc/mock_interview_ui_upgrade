import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: settings.darkMode,
              onChanged: (v) => settings.setDarkMode(v),
            ),
            ListTile(
              title: const Text('Speech Rate'),
              subtitle: Text('Current: ${settings.speechRate}'),
              trailing: DropdownButton<int>(
                value: settings.speechRate,
                items: List.generate(4, (i) => i)
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
                    .toList(),
                onChanged: (v) {
                  if (v != null) settings.setSpeechRate(v);
                },
              ),
            ),
            const SizedBox(height: 20),
            Text('Version: ${Constants.appVersion}'),
          ],
        ),
      ),
    );
  }
}
