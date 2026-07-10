import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/facility_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/facility_model.dart';

class AssetListScreen extends StatelessWidget {
  final String gedungId;
  final int nomorLantai;
  final String ruanganId;
  final String lantaiName;
  final String gedungName;

  const AssetListScreen({
    super.key,
    required this.gedungId,
    required this.nomorLantai,
    required this.ruanganId,
    required this.lantaiName,
    required this.gedungName,
  });

  @override
  Widget build(BuildContext context) {
    final facility = context.watch<FacilityProvider>();
    final gedung = facility.getGedungById(gedungId);
    if (gedung == null) {
      return const Scaffold(
        body: Center(
          child: Text('Gedung tidak ditemukan'),
        ),
      );
    }

    final lantai = gedung.lantai.firstWhere(
      (l) => l.nomorLantai == nomorLantai,
      orElse: () => LantaiModel(id: 'temp_floor', nomorLantai: nomorLantai, name: lantaiName, gedungId: gedungId, ruangan: []),
    );

    final ruangan = lantai.ruangan.firstWhere(
      (r) => r.id == ruanganId,
      orElse: () => RuanganModel(id: ruanganId, name: 'Ruangan', lantaiId: lantaiName, kapasitas: 10, tipe: 'Ruang Kerja', assets: []),
    );

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.bgDark,
            floating: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ruangan.name,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$gedungName • $lantaiName',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded,
                    color: AppColors.textPrimary, size: 26),
                onPressed: () => _showAssetDialog(context),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Room summary
                _buildRoomSummary(ruangan),
                const SizedBox(height: 20),
                Text(
                  '${ruangan.assets.length} Aset di ${ruangan.name}',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ...ruangan.assets.map((a) => _buildAssetCard(context, ruangan, a)),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomSummary(RuanganModel ruangan) {
    int baik = ruangan.assets.where((a) => a.status == AssetStatus.baik).length;
    int rusak =
        ruangan.assets.where((a) => a.status == AssetStatus.rusak).length;
    int maint = ruangan.assets
        .where((a) => a.status == AssetStatus.maintenance)
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.room_rounded,
                  color: AppColors.primaryLight, size: 18),
              const SizedBox(width: 8),
              Text(
                ruangan.tipe,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              const Icon(Icons.people_rounded,
                  color: AppColors.textMuted, size: 16),
              const SizedBox(width: 4),
              Text(
                'Kapasitas: ${ruangan.kapasitas}',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _summaryItem('Baik', baik, AppColors.success),
              _summaryItem('Rusak', rusak, AppColors.danger),
              _summaryItem('Maintenance', maint, AppColors.warning),
              _summaryItem('Total', ruangan.assets.length, AppColors.accent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, int count, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$count',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCard(BuildContext context, RuanganModel ruangan, AssetModel asset) {
    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    switch (asset.status) {
      case AssetStatus.baik:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_rounded;
        statusLabel = 'Baik';
        break;
      case AssetStatus.rusak:
        statusColor = AppColors.danger;
        statusIcon = Icons.cancel_rounded;
        statusLabel = 'Rusak';
        break;
      case AssetStatus.maintenance:
        statusColor = AppColors.warning;
        statusIcon = Icons.build_circle_rounded;
        statusLabel = 'Maintenance';
        break;
      case AssetStatus.tidakAktif:
        statusColor = AppColors.textMuted;
        statusIcon = Icons.remove_circle_rounded;
        statusLabel = 'Tidak Aktif';
        break;
    }

    IconData categoryIcon;
    switch (asset.category) {
      case 'AC':
        categoryIcon = Icons.ac_unit_rounded;
        break;
      case 'Proyektor':
        categoryIcon = Icons.videocam_rounded;
        break;
      case 'Smart TV':
        categoryIcon = Icons.tv_rounded;
        break;
      case 'Printer':
        categoryIcon = Icons.print_rounded;
        break;
      case 'CCTV':
        categoryIcon = Icons.camera_outdoor_rounded;
        break;
      case 'Lampu':
        categoryIcon = Icons.lightbulb_rounded;
        break;
      case 'Server':
        categoryIcon = Icons.dns_rounded;
        break;
      default:
        categoryIcon = Icons.devices_rounded;
    }

    return GestureDetector(
      onTap: () => _showAssetDetail(context, asset, statusColor, statusLabel),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statusColor.withOpacity(0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.bgCardLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(categoryIcon, color: AppColors.accent, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        asset.category,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: GoogleFonts.outfit(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        asset.brand,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'SN: ${asset.serialNumber}',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Kondisi: ${asset.kondisi}',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(height: 4),
                Text(
                  statusLabel,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAssetDetail(
    BuildContext context,
    AssetModel asset,
    Color statusColor,
    String statusLabel,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Detail Aset',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      statusLabel,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _detailRow('Nama', asset.name),
              _detailRow('Kategori', asset.category),
              _detailRow('Brand', asset.brand),
              _detailRow('Serial Number', asset.serialNumber),
              _detailRow('Kondisi', asset.kondisi),
              _detailRow(
                'Terakhir Maintenance',
                '${asset.lastMaintenance.day}/${asset.lastMaintenance.month}/${asset.lastMaintenance.year}',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_outline_rounded, size: 16),
                      label: const Text('Hapus'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _confirmDeleteAsset(context, asset);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit_rounded, size: 16),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showAssetDialog(context, asset: asset);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAssetDialog(BuildContext context, {AssetModel? asset}) {
    final nameController = TextEditingController(text: asset?.name ?? '');
    final brandController = TextEditingController(text: asset?.brand ?? '');
    final snController = TextEditingController(text: asset?.serialNumber ?? '');
    final kondisiController = TextEditingController(text: asset?.kondisi ?? 'Sangat Baik');
    String selectedCategory = asset?.category ?? 'AC';
    AssetStatus selectedStatus = asset?.status ?? AssetStatus.baik;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppColors.bgCardLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.border),
              ),
              title: Text(
                asset == null ? 'Tambah Aset Baru' : 'Edit Aset',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        style: GoogleFonts.outfit(color: AppColors.textPrimary),
                        decoration: const InputDecoration(labelText: 'Nama Aset'),
                        validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        dropdownColor: AppColors.bgCardLight,
                        style: GoogleFonts.outfit(color: AppColors.textPrimary),
                        decoration: const InputDecoration(labelText: 'Kategori'),
                        items: const [
                          DropdownMenuItem(value: 'AC', child: Text('AC')),
                          DropdownMenuItem(value: 'Proyektor', child: Text('Proyektor')),
                          DropdownMenuItem(value: 'Smart TV', child: Text('Smart TV')),
                          DropdownMenuItem(value: 'Printer', child: Text('Printer')),
                          DropdownMenuItem(value: 'CCTV', child: Text('CCTV')),
                          DropdownMenuItem(value: 'Lampu', child: Text('Lampu')),
                          DropdownMenuItem(value: 'Server', child: Text('Server')),
                        ],
                        onChanged: (val) {
                          setModalState(() {
                            selectedCategory = val!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: brandController,
                        style: GoogleFonts.outfit(color: AppColors.textPrimary),
                        decoration: const InputDecoration(labelText: 'Merek / Brand'),
                        validator: (v) => v == null || v.isEmpty ? 'Merek wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: snController,
                        style: GoogleFonts.outfit(color: AppColors.textPrimary),
                        decoration: const InputDecoration(labelText: 'Serial Number'),
                        validator: (v) => v == null || v.isEmpty ? 'Serial number wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: kondisiController,
                        style: GoogleFonts.outfit(color: AppColors.textPrimary),
                        decoration: const InputDecoration(labelText: 'Detail Kondisi (Fisik)'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<AssetStatus>(
                        value: selectedStatus,
                        dropdownColor: AppColors.bgCardLight,
                        style: GoogleFonts.outfit(color: AppColors.textPrimary),
                        decoration: const InputDecoration(labelText: 'Status Aset'),
                        items: const [
                          DropdownMenuItem(value: AssetStatus.baik, child: Text('Baik')),
                          DropdownMenuItem(value: AssetStatus.rusak, child: Text('Rusak')),
                          DropdownMenuItem(value: AssetStatus.maintenance, child: Text('Maintenance')),
                          DropdownMenuItem(value: AssetStatus.tidakAktif, child: Text('Tidak Aktif')),
                        ],
                        onChanged: (val) {
                          setModalState(() {
                            selectedStatus = val!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    
                    final provider = context.read<FacilityProvider>();
                    if (asset == null) {
                      final newAsset = AssetModel(
                        id: 'asset_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameController.text.trim(),
                        category: selectedCategory,
                        status: selectedStatus,
                        ruanganId: ruanganId,
                        lastMaintenance: DateTime.now(),
                        serialNumber: snController.text.trim(),
                        brand: brandController.text.trim(),
                        kondisi: kondisiController.text.trim(),
                      );
                      provider.addAsset(gedungId, nomorLantai, ruanganId, newAsset);
                    } else {
                      final updatedAsset = AssetModel(
                        id: asset.id,
                        name: nameController.text.trim(),
                        category: selectedCategory,
                        status: selectedStatus,
                        ruanganId: asset.ruanganId,
                        lastMaintenance: asset.lastMaintenance,
                        serialNumber: snController.text.trim(),
                        brand: brandController.text.trim(),
                        kondisi: kondisiController.text.trim(),
                      );
                      provider.updateAsset(gedungId, nomorLantai, ruanganId, updatedAsset);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: Text('Simpan', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteAsset(BuildContext context, AssetModel asset) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.bgCardLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border),
          ),
          title: Text(
            'Hapus Aset',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              color: AppColors.danger,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus aset "${asset.name}"? Data ini tidak dapat dikembalikan.',
            style: GoogleFonts.outfit(color: AppColors.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<FacilityProvider>().deleteAsset(gedungId, nomorLantai, ruanganId, asset.id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              child: Text('Hapus', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }
}
