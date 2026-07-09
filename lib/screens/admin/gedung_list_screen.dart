import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/facility_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/facility_model.dart';
import 'lantai_list_screen.dart';

class GedungListScreen extends StatefulWidget {
  const GedungListScreen({super.key});

  @override
  State<GedungListScreen> createState() => _GedungListScreenState();
}

class _GedungListScreenState extends State<GedungListScreen> {
  late Future<List<GedungModel>> _gedungListFuture;

  @override
  void initState() {
    super.initState();
    _gedungListFuture = context.read<FacilityProvider>().getGedungListAsync();
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
              'Manajemen Gedung',
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
                onPressed: () => _showGedungDialog(),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Summary row
                _buildSummaryRow(facility),
                const SizedBox(height: 20),
                Text(
                  'Daftar Gedung',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<GedungModel>>(
                  future: _gedungListFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'Gagal memuat data gedung',
                            style: GoogleFonts.outfit(color: AppColors.danger),
                          ),
                        ),
                      );
                    }
                    final list = snapshot.data ?? [];
                    if (list.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'Tidak ada gedung tersedia.',
                            style: GoogleFonts.outfit(color: AppColors.textMuted),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: list.map((g) => _buildGedungCard(context, g)).toList(),
                    );
                  },
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(FacilityProvider facility) {
    return Row(
      children: [
        Expanded(
          child: _miniStat(
            'Total Gedung',
            '${facility.totalGedung}',
            Icons.business_rounded,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _miniStat(
            'Total Aset',
            '${facility.totalAsset}',
            Icons.inventory_2_rounded,
            AppColors.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _miniStat(
            'Butuh Perhatian',
            '${facility.totalAssetRusak + facility.totalAssetMaintenance}',
            Icons.warning_rounded,
            AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _miniStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGedungCard(BuildContext context, GedungModel gedung) {
    // Count assets per gedung
    int totalAsset = 0;
    int asetRusak = 0;
    for (var l in gedung.lantai) {
      for (var r in l.ruangan) {
        totalAsset += r.assets.length;
        asetRusak +=
            r.assets.where((a) => a.status == AssetStatus.rusak).length;
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LantaiListScreen(gedung: gedung),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header gradient
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.3),
                    AppColors.accent.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.apartment_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gedung.name,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.textSecondary,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                gedung.alamat,
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                    color: AppColors.bgCardLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    onSelected: (val) {
                      if (val == 'edit') {
                        _showGedungDialog(gedung: gedung);
                      } else if (val == 'delete') {
                        _confirmDeleteGedung(gedung);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_rounded, color: AppColors.textPrimary, size: 18),
                            const SizedBox(width: 8),
                            Text('Edit', style: GoogleFonts.outfit(color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_rounded, color: AppColors.danger, size: 18),
                            const SizedBox(width: 8),
                            Text('Hapus', style: GoogleFonts.outfit(color: AppColors.danger)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.textMuted,
                    size: 16,
                  ),
                ],
              ),
            ),
            // Stats row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _statChip(Icons.layers_rounded, '${gedung.totalLantai} Lantai',
                      AppColors.accent),
                  const SizedBox(width: 10),
                  _statChip(Icons.inventory_2_rounded, '$totalAsset Aset',
                      AppColors.info),
                  const SizedBox(width: 10),
                  if (asetRusak > 0)
                    _statChip(Icons.warning_rounded, '$asetRusak Rusak',
                        AppColors.danger)
                  else
                    _statChip(
                        Icons.check_circle_rounded, 'Semua Baik', AppColors.success),
                ],
              ),
            ),
            // PJ row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_rounded,
                      color: AppColors.textMuted, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'PJ: ${gedung.penanggungJawab}',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _refreshGedungList() {
    setState(() {
      _gedungListFuture = context.read<FacilityProvider>().getGedungListAsync();
    });
  }

  void _showGedungDialog({GedungModel? gedung}) {
    final nameController = TextEditingController(text: gedung?.name ?? '');
    final alamatController = TextEditingController(text: gedung?.alamat ?? '');
    final pjController = TextEditingController(text: gedung?.penanggungJawab ?? '');
    final formKey = GlobalKey<FormState>();

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
            gedung == null ? 'Tambah Gedung Baru' : 'Edit Gedung',
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
                    decoration: const InputDecoration(labelText: 'Nama Gedung'),
                    validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: alamatController,
                    style: GoogleFonts.outfit(color: AppColors.textPrimary),
                    decoration: const InputDecoration(labelText: 'Alamat Gedung'),
                    validator: (v) => v == null || v.isEmpty ? 'Alamat wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: pjController,
                    style: GoogleFonts.outfit(color: AppColors.textPrimary),
                    decoration: const InputDecoration(labelText: 'Penanggung Jawab'),
                    validator: (v) => v == null || v.isEmpty ? 'Nama PJ wajib diisi' : null,
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
                if (gedung == null) {
                  final newGedungId = 'ged_${DateTime.now().millisecondsSinceEpoch}';
                  final newGedung = GedungModel(
                    id: newGedungId,
                    name: nameController.text.trim(),
                    alamat: alamatController.text.trim(),
                    penanggungJawab: pjController.text.trim(),
                    totalLantai: 1,
                    lantai: [
                      LantaiModel(
                        id: '${newGedungId}_l1',
                        nomorLantai: 1,
                        name: 'Lantai 1',
                        gedungId: newGedungId,
                        ruangan: [],
                      ),
                    ],
                  );
                  provider.addGedung(newGedung);
                } else {
                  provider.updateGedung(
                    gedung.id,
                    nameController.text.trim(),
                    alamatController.text.trim(),
                    pjController.text.trim(),
                  );
                }
                Navigator.pop(context);
                _refreshGedungList();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text('Simpan', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteGedung(GedungModel gedung) {
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
            'Hapus Gedung',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              color: AppColors.danger,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus "${gedung.name}"? Semua data lantai, ruangan, dan aset di dalamnya akan terhapus permanen.',
            style: GoogleFonts.outfit(color: AppColors.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<FacilityProvider>().deleteGedung(gedung.id);
                Navigator.pop(context);
                _refreshGedungList();
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
