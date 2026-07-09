import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/auth/auth_event.dart';
import '../../providers/facility_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/facility_model.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isAdmin = authState.currentUser?.role == 'admin';

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildGreeting(context),
                const SizedBox(height: 20),
                if (isAdmin) ...[
                  _buildStatCards(context),
                  const SizedBox(height: 24),
                  _buildAssetStatusChart(context),
                  const SizedBox(height: 24),
                  _buildRecentMaintenance(context),
                  const SizedBox(height: 24),
                ],
                _buildRecentLaporan(context),
                const SizedBox(height: 24),
                if (isAdmin) ...[
                  _buildRealtimeActivity(context),
                  const SizedBox(height: 80),
                ] else ...[
                  const SizedBox(height: 80),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.bgDark,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.business_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'FOM',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      actions: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return PopupMenuButton(
              color: AppColors.bgCardLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              itemBuilder: (_) => <PopupMenuEntry<dynamic>>[
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline_rounded,
                          color: AppColors.textPrimary, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        state.currentUser?.name ?? '',
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  onTap: () {
                    context.read<AuthBloc>().add(LogoutRequested());
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.logout_rounded,
                          color: AppColors.danger, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        'Keluar',
                        style: GoogleFonts.outfit(
                          color: AppColors.danger,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      state.currentUser?.avatar ?? 'A',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final now = DateTime.now();
    String greeting;
    if (now.hour < 12) {
      greeting = 'Selamat Pagi';
    } else if (now.hour < 17) {
      greeting = 'Selamat Siang';
    } else {
      greeting = 'Selamat Malam';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting + ',',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  authState.currentUser?.name ?? 'Admin',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    authState.currentUser?.department ?? 'Admin',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(BuildContext context) {
    final facility = context.watch<FacilityProvider>();
    final stats = [
      _StatItem(
        label: 'Total Gedung',
        value: facility.totalGedung.toString(),
        icon: Icons.business_rounded,
        color: AppColors.primary,
        subtitle: 'Aktif',
      ),
      _StatItem(
        label: 'Total Aset',
        value: facility.totalAsset.toString(),
        icon: Icons.inventory_2_rounded,
        color: AppColors.accent,
        subtitle: 'Terdaftar',
      ),
      _StatItem(
        label: 'Aset Baik',
        value: facility.totalAssetBaik.toString(),
        icon: Icons.check_circle_rounded,
        color: AppColors.success,
        subtitle: 'Kondisi baik',
      ),
      _StatItem(
        label: 'Aset Rusak',
        value: facility.totalAssetRusak.toString(),
        icon: Icons.warning_rounded,
        color: AppColors.danger,
        subtitle: 'Perlu perhatian',
      ),
      _StatItem(
        label: 'Maintenance',
        value: facility.maintenanceAktif.toString(),
        icon: Icons.build_rounded,
        color: AppColors.warning,
        subtitle: 'Sedang berjalan',
      ),
      _StatItem(
        label: 'Laporan',
        value: facility.laporanBelumDitindak.toString(),
        icon: Icons.report_rounded,
        color: const Color(0xFFAB47BC),
        subtitle: 'Belum ditindak',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: stats.length,
      itemBuilder: (_, index) => _buildStatCard(stats[index]),
    );
  }

  Widget _buildStatCard(_StatItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.value,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                item.label,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssetStatusChart(BuildContext context) {
    final facility = context.watch<FacilityProvider>();
    final total = facility.totalAsset;
    final baik = facility.totalAssetBaik;
    final rusak = facility.totalAssetRusak;
    final maint = facility.totalAssetMaintenance;
    final tidakAktif = total - baik - rusak - maint;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Aset',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Distribusi kondisi seluruh aset',
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: baik.toDouble(),
                        color: AppColors.success,
                        title: '$baik',
                        radius: 55,
                        titleStyle: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        value: rusak.toDouble(),
                        color: AppColors.danger,
                        title: '$rusak',
                        radius: 55,
                        titleStyle: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        value: maint.toDouble(),
                        color: AppColors.warning,
                        title: '$maint',
                        radius: 55,
                        titleStyle: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      if (tidakAktif > 0)
                        PieChartSectionData(
                          value: tidakAktif.toDouble(),
                          color: AppColors.textMuted,
                          title: '$tidakAktif',
                          radius: 55,
                          titleStyle: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                    ],
                    sectionsSpace: 3,
                    centerSpaceRadius: 30,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _legendItem('Baik', AppColors.success, baik),
                    const SizedBox(height: 10),
                    _legendItem('Rusak', AppColors.danger, rusak),
                    const SizedBox(height: 10),
                    _legendItem('Maintenance', AppColors.warning, maint),
                    const SizedBox(height: 10),
                    _legendItem('Tidak Aktif', AppColors.textMuted, tidakAktif),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          '$count',
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentMaintenance(BuildContext context) {
    final facility = context.watch<FacilityProvider>();
    final records = facility.maintenanceRecords.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Maintenance Terkini',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Lihat semua',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...records.map((r) => _maintenanceCard(r)),
      ],
    );
  }

  Widget _maintenanceCard(MaintenanceRecord record) {
    Color statusColor;
    IconData statusIcon;
    switch (record.status) {
      case MaintenanceStatus.selesai:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_rounded;
        break;
      case MaintenanceStatus.proses:
        statusColor = AppColors.warning;
        statusIcon = Icons.sync_rounded;
        break;
      case MaintenanceStatus.menunggu:
        statusColor = AppColors.textMuted;
        statusIcon = Icons.schedule_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: statusColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.assetName,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${record.ruangan} • ${record.gedung}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              record.statusLabel,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLaporan(BuildContext context) {
    final facility = context.watch<FacilityProvider>();
    final authState = context.watch<AuthBloc>().state;
    final isAdmin = authState.currentUser?.role == 'admin';

    final allLaporan = facility.laporanKerusakan.where((l) => !l.sudahDitindak);
    final filteredLaporan = isAdmin
        ? allLaporan.toList()
        : allLaporan.where((l) => l.pelaporId == authState.currentUser?.id).toList();

    final laporan = filteredLaporan.take(3).toList();
    final title = isAdmin ? 'Laporan Belum Ditindak' : 'Laporan Saya (Belum Ditindak)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Lihat semua',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (laporan.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      color: AppColors.success, size: 36),
                  const SizedBox(height: 8),
                  Text(
                    'Semua laporan sudah ditindak!',
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...laporan.map((l) => _laporanCard(l)),
      ],
    );
  }

  Widget _laporanCard(laporanKerusakan) {
    Color prioritasColor;
    switch (laporanKerusakan.prioritas) {
      case 'tinggi':
        prioritasColor = AppColors.danger;
        break;
      case 'sedang':
        prioritasColor = AppColors.warning;
        break;
      default:
        prioritasColor = AppColors.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: prioritasColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: prioritasColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.report_problem_rounded,
                color: prioritasColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  laporanKerusakan.assetName,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  laporanKerusakan.lokasiLengkap,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: prioritasColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              laporanKerusakan.prioritas.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: prioritasColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimeActivity(BuildContext context) {
    final facility = context.watch<FacilityProvider>();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sensors_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live System Activity Log',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Simulasi monitoring real-time (StreamBuilder)',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'LIVE',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.greenAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<String>(
            stream: facility.activityLogStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                );
              }
              final logText = snapshot.data ?? 'Tidak ada aktivitas baru.';
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.2),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  key: ValueKey<String>(logText),
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.circle_notifications_rounded,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          logText,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });
}
