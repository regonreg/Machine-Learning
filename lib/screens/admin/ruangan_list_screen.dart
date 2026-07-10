import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/facility_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/facility_model.dart';
import 'asset_list_screen.dart';

class RuanganListScreen extends StatelessWidget {
  final String gedungId;
  final int nomorLantai;
  final String gedungName;

  const RuanganListScreen({
    super.key,
    required this.gedungId,
    required this.nomorLantai,
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
      orElse: () => LantaiModel(id: 'temp_floor', nomorLantai: nomorLantai, name: 'Lantai $nomorLantai', gedungId: gedungId, ruangan: []),
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
                  lantai.name,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$gedungName • Daftar Ruangan',
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
                onPressed: () => _showAddRuanganDialog(context),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  '${lantai.ruangan.length} Ruangan di ${lantai.name}',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ...lantai.ruangan
                    .map((r) => _buildRuanganCard(context, lantai, r)),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuanganCard(BuildContext context, LantaiModel lantai, RuanganModel ruangan) {
    int asetBaik =
        ruangan.assets.where((a) => a.status == AssetStatus.baik).length;
    int asetRusak =
        ruangan.assets.where((a) => a.status == AssetStatus.rusak).length;
    int asetMaintenance =
        ruangan.assets.where((a) => a.status == AssetStatus.maintenance).length;

    Color statusColor;
    String statusLabel;
    if (asetRusak > 0) {
      statusColor = AppColors.danger;
      statusLabel = '$asetRusak aset rusak';
    } else if (asetMaintenance > 0) {
      statusColor = AppColors.warning;
      statusLabel = '$asetMaintenance maintenance';
    } else {
      statusColor = AppColors.success;
      statusLabel = 'Semua baik';
    }

    IconData tipeIcon;
    switch (ruangan.tipe) {
      case 'Ruang Rapat':
        tipeIcon = Icons.meeting_room_rounded;
        break;
      case 'Ruang Kerja':
        tipeIcon = Icons.work_rounded;
        break;
      case 'Lobby':
        tipeIcon = Icons.door_sliding_rounded;
        break;
      case 'Ruang Eksekutif':
        tipeIcon = Icons.star_rounded;
        break;
      case 'Aula':
        tipeIcon = Icons.festival_rounded;
        break;
      case 'Gudang':
        tipeIcon = Icons.warehouse_rounded;
        break;
      default:
        tipeIcon = Icons.room_rounded;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AssetListScreen(
              gedungId: gedungId,
              nomorLantai: nomorLantai,
              ruanganId: ruangan.id,
              lantaiName: lantai.name,
              gedungName: gedungName,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: statusColor.withOpacity(0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(tipeIcon, color: AppColors.primaryLight, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ruangan.name,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _infoChip(ruangan.tipe, AppColors.accent),
                      const SizedBox(width: 6),
                      _infoChip(
                          '${ruangan.kapasitas} org', AppColors.textMuted),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.inventory_2_rounded,
                          color: AppColors.textMuted, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${ruangan.assets.length} Aset',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.danger, size: 20),
              onPressed: () => _confirmDeleteRuangan(context, ruangan),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showAddRuanganDialog(BuildContext context) {
    final nameController = TextEditingController();
    final kapasitasController = TextEditingController(text: '10');
    String selectedTipe = 'Ruang Kerja';
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
                'Tambah Ruangan Baru',
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
                        decoration: const InputDecoration(labelText: 'Nama Ruangan'),
                        validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedTipe,
                        dropdownColor: AppColors.bgCardLight,
                        style: GoogleFonts.outfit(color: AppColors.textPrimary),
                        decoration: const InputDecoration(labelText: 'Tipe Ruangan'),
                        items: const [
                          DropdownMenuItem(value: 'Ruang Kerja', child: Text('Ruang Kerja')),
                          DropdownMenuItem(value: 'Ruang Rapat', child: Text('Ruang Rapat')),
                          DropdownMenuItem(value: 'Ruang Eksekutif', child: Text('Ruang Eksekutif')),
                          DropdownMenuItem(value: 'Aula', child: Text('Aula')),
                          DropdownMenuItem(value: 'Gudang', child: Text('Gudang')),
                          DropdownMenuItem(value: 'Lobby', child: Text('Lobby')),
                        ],
                        onChanged: (val) {
                          setModalState(() {
                            selectedTipe = val!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: kapasitasController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.outfit(color: AppColors.textPrimary),
                        decoration: const InputDecoration(labelText: 'Kapasitas (Orang)'),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Kapasitas wajib diisi';
                          if (int.tryParse(v) == null) return 'Kapasitas harus angka';
                          return null;
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
                    
                    final newRoom = RuanganModel(
                      id: 'room_${DateTime.now().millisecondsSinceEpoch}',
                      name: nameController.text.trim(),
                      lantaiId: nomorLantai.toString(),
                      tipe: selectedTipe,
                      kapasitas: int.parse(kapasitasController.text),
                      assets: [],
                    );

                    context.read<FacilityProvider>().addRuangan(gedungId, nomorLantai, newRoom);
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

  void _confirmDeleteRuangan(BuildContext context, RuanganModel ruangan) {
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
            'Hapus Ruangan',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              color: AppColors.danger,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus ruangan "${ruangan.name}"? Semua aset di dalamnya juga akan terhapus.',
            style: GoogleFonts.outfit(color: AppColors.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<FacilityProvider>().deleteRuangan(gedungId, nomorLantai, ruangan.id);
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
