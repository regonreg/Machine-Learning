import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../providers/facility_provider.dart';
import '../../utils/app_theme.dart';
import 'dashboard_screen.dart';
import 'gedung_list_screen.dart';
import 'maintenance_screen.dart';
import 'laporan_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  late final List<_NavItem> _navItems;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final isAdmin = authState.currentUser?.role == 'admin';

    if (isAdmin) {
      _navItems = [
        _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
        _NavItem(icon: Icons.business_rounded, label: 'Gedung'),
        _NavItem(icon: Icons.build_circle_rounded, label: 'Maintenance'),
        _NavItem(icon: Icons.report_problem_rounded, label: 'Laporan'),
      ];
      _screens = [
        const DashboardScreen(),
        const GedungListScreen(),
        const MaintenanceScreen(),
        const LaporanScreen(),
      ];
    } else {
      _navItems = [
        _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
        _NavItem(icon: Icons.report_problem_rounded, label: 'Laporan'),
      ];
      _screens = [
        const DashboardScreen(),
        const LaporanScreen(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = index == _selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected
                              ? AppColors.primaryLight
                              : AppColors.textMuted,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primaryLight
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
