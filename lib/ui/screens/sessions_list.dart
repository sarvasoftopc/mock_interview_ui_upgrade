import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/session_provider.dart';
import '../../widgets/modern_widgets.dart';
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
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: CustomAppBar(context: context, titleText: "Interview Sessions"),
      drawer: const AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: RefreshIndicator(
          onRefresh: () => provider.fetchSessions(),
          color: AppTheme.primaryPurple,
          child: Builder(
            builder: (ctx) {
              if (provider.loading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryPurple,
                  ),
                );
              }

              final sessions = provider.sessions;
              if (sessions.isEmpty) {
                return ListView(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    const Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 80,
                            color: AppTheme.textLight,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No sessions found',
                            style: AppTheme.bodyLarge,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Start your first interview to see results here',
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 1000 : double.infinity),
                  child: ListView.separated(
                    padding: EdgeInsets.all(isWide ? 24 : 16),
                    itemCount: sessions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final s = sessions[i];

                      return InkWell(
                        onTap: () => context.read<SessionProvider>().openSession(context, s.id, s.sessionType),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        child: Container(
                          decoration: AppTheme.cardDecoration,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Status Icon
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: s.completed
                                      ? const LinearGradient(
                                          colors: [Colors.green, Colors.lightGreen],
                                        )
                                      : LinearGradient(
                                          colors: [Colors.orange.shade400, Colors.orange.shade600],
                                        ),
                                ),
                                child: Icon(
                                  s.completed ? Icons.check_circle : Icons.pending_actions,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Session Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.sessionType!,
                                      style: AppTheme.titleMedium.copyWith(fontSize: 18),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: AppTheme.textLight,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _formatDate(s.createdAt),
                                          style: AppTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Score or Chevron
                              if (s.completed)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                  ),
                                  child: Text(
                                    s.score?.toStringAsFixed(1) ?? '-',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.chevron_right,
                                  color: AppTheme.textLight,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
