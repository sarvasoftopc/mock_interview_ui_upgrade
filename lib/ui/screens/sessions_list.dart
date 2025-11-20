import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/session_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/custom_app_bar.dart';


class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  bool _initialized = false;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    if (!_initialized) {
      final provider = context.read<SessionProvider>();
      await provider.fetchSessions();
      _initialized = true;
    }
  }

  String _formatDate(DateTime dt) {
    // Use a simple human-readable format. Replace with intl if desired.
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return "$y-$m-$d $hh:$mm";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SessionProvider>();

    return Scaffold(
      appBar: CustomAppBar(
          context: context,
          titleText: "Mock Sessions Report"
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchSessions(),
        child: Builder(
          builder: (ctx) {
            if (provider.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final sessions = provider.sessions;
            if (sessions.isEmpty) {
              return ListView(
                // ListView so RefreshIndicator works even when empty
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No sessions found', style: TextStyle(fontSize: 16))),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: sessions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final s = sessions[i];

                final leading = s.completed
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.pending_actions, color: Colors.orange);

                final trailing = s.completed
                    ? Text("Score: ${s.score?.toStringAsFixed(1) ?? '-'}",
                    style: const TextStyle(fontWeight: FontWeight.bold))
                    : const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );

                // inside your ListTile
                return ListTile(
                  leading: s.completed
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.pending_actions, color: Colors.orange),
                  title: Text("Session :${s.sessionType}"),
                  subtitle: Text("Date: ${_formatDate(s.createdAt)}"),
                  trailing: s.completed
                      ? Text("Score: ${s.score?.toStringAsFixed(1) ?? '-'}")
                      : const Icon(Icons.chevron_right),
                  onTap: () => context.read<SessionProvider>().openSession(context, s.id,s.sessionType),
                );

              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // optional: trigger a manual refresh
          context.read<SessionProvider>().fetchSessions();
        },
        child: const Icon(Icons.refresh),
        tooltip: 'Refresh sessions',
      ),
    );
  }
}
