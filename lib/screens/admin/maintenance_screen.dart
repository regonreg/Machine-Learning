import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/facility_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/facility_model.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final facility = context.watch<FacilityProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.bgDark,
            floating: true,
            title: Text(
              'Riwayat Maintenance',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded,
                    color: AppColors.textPrimary, size: 26),
                onPressed: () {},
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryLight,
              labelColor: AppColors.primaryLight,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Semua'),
                Tab(text: 'Berjalan'),
                Tab(text: 'Selesai'),
              ],
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(facility.maintenanceRecords, null),
                _buildList(
                  facility.maintenanceRecords,
                  [MaintenanceStatus.proses, MaintenanceStatus.menunggu],
                ),
                _buildList(
                  facility.maintenanceRecords,
                  [MaintenanceStatus.selesai],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
      List<MaintenanceRecord> records, List<MaintenanceStatus>? filter) {
    final filtered = filter == null
        ? records
        : records.where((r) => filter.contains(r.status)).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.build_circle_outlined,
                color: AppColors.textMuted, size: 56),
            const SizedBox(height: 12),
            Text(
              'Tidak ada data maintenance',
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (_, i) => _buildCard(filtered[i]),
    );
  }

  Widget _buildCard(MaintenanceRecord record) {
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  record.assetName,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  record.statusLabel,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            record.deskripsi,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoItem(Icons.location_on_rounded,
                  '${record.ruangan} • ${record.gedung}'),
              const Spacer(),
              _infoItem(Icons.calendar_today_rounded,
                  '${record.tanggal.day}/${record.tanggal.month}/${record.tanggal.year}'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _infoItem(Icons.person_rounded, record.teknisi),
              const Spacer(),
              if (record.biaya > 0)
                _infoItem(
                  Icons.payments_rounded,
                  'Rp ${_formatNumber(record.biaya)}',
                  color: AppColors.success,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String text, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color ?? AppColors.textMuted, size: 13),
        const SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: color ?? AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int n) {
    return n.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}
