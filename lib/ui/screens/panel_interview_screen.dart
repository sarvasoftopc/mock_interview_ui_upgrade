import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/modern_widgets.dart';
import '../widgets/app_drawer.dart';

class PanelInterviewScreen extends StatefulWidget {
  const PanelInterviewScreen({super.key});

  @override
  State<PanelInterviewScreen> createState() => _PanelInterviewScreenState();
}

class _PanelInterviewScreenState extends State<PanelInterviewScreen> {
  int _selectedPanelSize = 2;
  final List<String> _selectedPanelists = [];

  final List<Map<String, dynamic>> _availablePanelists = [
    {
      "name": "Technical Lead",
      "icon": Icons.code,
      "color": AppTheme.primaryPurple,
    },
    {"name": "HR Manager", "icon": Icons.people, "color": Color(0xFFF5576C)},
    {
      "name": "Product Manager",
      "icon": Icons.lightbulb,
      "color": Color(0xFF4FACFE),
    },
    {
      "name": "Senior Engineer",
      "icon": Icons.engineering,
      "color": Color(0xFF43E97B),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Interview'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? 800 : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isWide ? 32 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      boxShadow: AppTheme.shadowSm,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.groups,
                          size: 64,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Panel Interview Mode',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Experience a multi-interviewer session',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Panel Size Selection
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.elevatedCard,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.group_add,
                              color: AppTheme.primaryPurple,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Select Panel Size',
                              style: AppTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: List.generate(3, (index) {
                            final size = index + 2;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: index < 2 ? 8 : 0,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedPanelSize = size;
                                      _selectedPanelists.clear();
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMd,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: _selectedPanelSize == size
                                          ? AppTheme.primaryGradient
                                          : null,
                                      color: _selectedPanelSize == size
                                          ? null
                                          : AppTheme.primaryLight.withOpacity(
                                              0.3,
                                            ),
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.radiusMd,
                                      ),
                                      border: Border.all(
                                        color: _selectedPanelSize == size
                                            ? Colors.transparent
                                            : AppTheme.primaryPurple
                                                  .withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '$size',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: _selectedPanelSize == size
                                                ? Colors.white
                                                : AppTheme.primaryPurple,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Panelists',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _selectedPanelSize == size
                                                ? Colors.white70
                                                : AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Panelist Selection
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.elevatedCard,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.how_to_reg,
                              color: AppTheme.primaryPurple,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Choose $_selectedPanelSize Panelists',
                              style: AppTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(_availablePanelists.length, (index) {
                          final panelist = _availablePanelists[index];
                          final isSelected = _selectedPanelists.contains(
                            panelist['name'],
                          );
                          final canSelect =
                              _selectedPanelists.length < _selectedPanelSize;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedPanelists.remove(panelist['name']);
                                  } else if (canSelect) {
                                    _selectedPanelists.add(
                                      panelist['name'] as String,
                                    );
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMd,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryLight
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMd,
                                  ),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primaryPurple
                                        : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: (panelist['color'] as Color)
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.radiusSm,
                                        ),
                                      ),
                                      child: Icon(
                                        panelist['icon'] as IconData,
                                        color: panelist['color'] as Color,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        panelist['name'] as String,
                                        style: AppTheme.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle,
                                        color: AppTheme.primaryPurple,
                                      )
                                    else if (!canSelect)
                                      Icon(
                                        Icons.lock,
                                        color: Colors.grey.shade400,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Start Button
                  GradientButton(
                    text: 'Start Panel Interview',
                    icon: Icons.play_arrow,
                    onPressed: _selectedPanelists.length == _selectedPanelSize
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Starting panel interview with: ${_selectedPanelists.join(", ")}',
                                ),
                                backgroundColor: AppTheme.primaryPurple,
                              ),
                            );
                          }
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please select $_selectedPanelSize panelists',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
