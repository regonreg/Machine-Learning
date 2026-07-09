import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../providers/facility_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/facility_model.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final facility = context.watch<FacilityProvider>();
    final authState = context.watch<AuthBloc>().state;
    final isAdmin = authState.currentUser?.role == 'admin';

    final allBelumDitindak = facility.laporanKerusakan.where((l) => !l.sudahDitindak);
    final allSudahDitindak = facility.laporanKerusakan.where((l) => l.sudahDitindak);

    final belumDitindak = isAdmin 
        ? allBelumDitindak.toList() 
        : allBelumDitindak.where((l) => l.pelaporId == authState.currentUser?.id).toList();

    final sudahDitindak = isAdmin 
        ? allSudahDitindak.toList() 
        : allSudahDitindak.where((l) => l.pelaporId == authState.currentUser?.id).toList();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.bgDark,
            floating: true,
            title: Text(
              'Laporan Kerusakan',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(96),
              child: Column(
                children: [
                  // Stats row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Row(
                      children: [
                        _topStat('Total Laporan',
                            '${facility.laporanKerusakan.length}',
                            AppColors.accent),
                        const SizedBox(width: 10),
                        _topStat('Belum Ditindak', '${belumDitindak.length}',
                            AppColors.danger),
                        const SizedBox(width: 10),
                        _topStat('Selesai', '${sudahDitindak.length}',
                            AppColors.success),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.primaryLight,
                    labelColor: AppColors.primaryLight,
                    unselectedLabelColor: AppColors.textMuted,
                    labelStyle: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: [
                      Tab(
                          text:
                              'Belum Ditindak (${belumDitindak.length})'),
                      Tab(text: 'Sudah Ditindak (${sudahDitindak.length})'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(belumDitindak, isAdmin),
                _buildList(sudahDitindak, isAdmin),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: !isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showAddLaporanBottomSheet(context),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
              label: Text(
                'Buat Laporan',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }

  Widget _topStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
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
      ),
    );
  }

  Widget _buildList(List<LaporanKerusakan> laporan, bool isAdmin) {
    if (laporan.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: AppColors.success, size: 56),
            const SizedBox(height: 12),
            Text(
              'Tidak ada laporan',
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
      itemCount: laporan.length,
      itemBuilder: (_, i) => _buildCard(laporan[i], isAdmin),
    );
  }

  Widget _buildCard(LaporanKerusakan laporan, bool isAdmin) {
    Color prioritasColor;
    IconData prioritasIcon;

    switch (laporan.prioritas) {
      case 'tinggi':
        prioritasColor = AppColors.danger;
        prioritasIcon = Icons.priority_high_rounded;
        break;
      case 'sedang':
        prioritasColor = AppColors.warning;
        prioritasIcon = Icons.remove_rounded;
        break;
      default:
        prioritasColor = AppColors.info;
        prioritasIcon = Icons.arrow_downward_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: laporan.sudahDitindak
              ? AppColors.border
              : prioritasColor.withOpacity(0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: prioritasColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    Icon(prioritasIcon, color: prioritasColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      laporan.assetName,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      laporan.lokasiLengkap,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: prioritasColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      laporan.prioritas.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        color: prioritasColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (laporan.sudahDitindak)
                    const Icon(Icons.verified_rounded,
                        color: AppColors.success, size: 18)
                  else
                    const Icon(Icons.pending_rounded,
                        color: AppColors.warning, size: 18),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            laporan.deskripsi,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person_rounded,
                  color: AppColors.textMuted, size: 13),
              const SizedBox(width: 4),
              Text(
                laporan.pelaporName,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              const Icon(Icons.calendar_today_rounded,
                  color: AppColors.textMuted, size: 13),
              const SizedBox(width: 4),
              Text(
                '${laporan.tanggalLapor.day}/${laporan.tanggalLapor.month}/${laporan.tanggalLapor.year}',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (!laporan.sudahDitindak && isAdmin) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('Tandai Ditindak'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () {
                  context.read<FacilityProvider>().tandaiDitindak(laporan.id);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddLaporanBottomSheet(BuildContext context) {
    final facility = context.read<FacilityProvider>();
    final authState = context.read<AuthBloc>().state;
    final user = authState.currentUser;
    if (user == null) return;

    // Cascading selection state
    GedungModel? selectedGedung;
    LantaiModel? selectedLantai;
    RuanganModel? selectedRuangan;
    AssetModel? selectedAsset;
    String? selectedPrioritas = 'sedang';
    final deskripsiController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Derive lists from cascading selections
            final gedungOptions = facility.gedungList;
            final lantaiOptions = selectedGedung?.lantai ?? [];
            final ruanganOptions = selectedLantai?.ruangan ?? [];
            final assetOptions = selectedRuangan?.assets
                    .where((a) => a.status == AssetStatus.baik || a.status == AssetStatus.tidakAktif)
                    .toList() ??
                [];

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              decoration: const BoxDecoration(
                color: AppColors.bgCardLight,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      Text(
                        'Laporkan Kerusakan Fasilitas',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pilih lokasi dan aset yang rusak secara bertahap',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ============ STEP 1: GEDUNG ============
                      _sectionLabel('1. Pilih Gedung'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<GedungModel>(
                        value: selectedGedung,
                        dropdownColor: AppColors.bgCardLight,
                        style: GoogleFonts.outfit(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Pilih gedung...',
                          prefixIcon: Icon(Icons.apartment_rounded, color: AppColors.textMuted, size: 20),
                        ),
                        items: gedungOptions.map((g) {
                          return DropdownMenuItem<GedungModel>(
                            value: g,
                            child: Text(g.name, style: GoogleFonts.outfit(color: AppColors.textPrimary)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setModalState(() {
                            selectedGedung = val;
                            selectedLantai = null;
                            selectedRuangan = null;
                            selectedAsset = null;
                          });
                        },
                        validator: (v) => v == null ? 'Pilih gedung' : null,
                      ),
                      const SizedBox(height: 16),

                      // ============ STEP 2: LANTAI ============
                      _sectionLabel('2. Pilih Lantai'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<LantaiModel>(
                        value: selectedLantai,
                        dropdownColor: AppColors.bgCardLight,
                        style: GoogleFonts.outfit(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: selectedGedung == null ? 'Pilih gedung dulu' : 'Pilih lantai...',
                          prefixIcon: const Icon(Icons.layers_rounded, color: AppColors.textMuted, size: 20),
                        ),
                        items: lantaiOptions.map((l) {
                          return DropdownMenuItem<LantaiModel>(
                            value: l,
                            child: Text(l.name, style: GoogleFonts.outfit(color: AppColors.textPrimary)),
                          );
                        }).toList(),
                        onChanged: selectedGedung == null
                            ? null
                            : (val) {
                                setModalState(() {
                                  selectedLantai = val;
                                  selectedRuangan = null;
                                  selectedAsset = null;
                                });
                              },
                        validator: (v) => v == null ? 'Pilih lantai' : null,
                      ),
                      const SizedBox(height: 16),

                      // ============ STEP 3: RUANGAN ============
                      _sectionLabel('3. Pilih Ruangan'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<RuanganModel>(
                        value: selectedRuangan,
                        dropdownColor: AppColors.bgCardLight,
                        style: GoogleFonts.outfit(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: selectedLantai == null ? 'Pilih lantai dulu' : 'Pilih ruangan...',
                          prefixIcon: const Icon(Icons.meeting_room_rounded, color: AppColors.textMuted, size: 20),
                        ),
                        items: ruanganOptions.map((r) {
                          return DropdownMenuItem<RuanganModel>(
                            value: r,
                            child: Text('${r.name} (${r.tipe})', style: GoogleFonts.outfit(color: AppColors.textPrimary)),
                          );
                        }).toList(),
                        onChanged: selectedLantai == null
                            ? null
                            : (val) {
                                setModalState(() {
                                  selectedRuangan = val;
                                  selectedAsset = null;
                                });
                              },
                        validator: (v) => v == null ? 'Pilih ruangan' : null,
                      ),
                      const SizedBox(height: 16),

                      // ============ STEP 4: ASET ============
                      _sectionLabel('4. Pilih Aset / Fasilitas yang Rusak'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<AssetModel>(
                        value: selectedAsset,
                        dropdownColor: AppColors.bgCardLight,
                        style: GoogleFonts.outfit(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: selectedRuangan == null
                              ? 'Pilih ruangan dulu'
                              : assetOptions.isEmpty
                                  ? 'Tidak ada aset yang bisa dilaporkan'
                                  : 'Pilih aset...',
                          prefixIcon: const Icon(Icons.build_rounded, color: AppColors.textMuted, size: 20),
                        ),
                        items: assetOptions.map((a) {
                          return DropdownMenuItem<AssetModel>(
                            value: a,
                            child: Text(
                              '${a.name} (${a.brand})',
                              style: GoogleFonts.outfit(color: AppColors.textPrimary),
                            ),
                          );
                        }).toList(),
                        onChanged: selectedRuangan == null
                            ? null
                            : (val) {
                                setModalState(() {
                                  selectedAsset = val;
                                });
                              },
                        validator: (v) => v == null ? 'Pilih aset yang bermasalah' : null,
                      ),
                      const SizedBox(height: 20),

                      // ============ DESKRIPSI ============
                      _sectionLabel('Deskripsi Kerusakan'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: deskripsiController,
                        maxLines: 3,
                        style: GoogleFonts.outfit(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Jelaskan kondisi kerusakan secara detail...',
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Jelaskan deskripsi kerusakan' : null,
                      ),
                      const SizedBox(height: 20),

                      // ============ PRIORITAS ============
                      _sectionLabel('Tingkat Prioritas'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedPrioritas,
                        dropdownColor: AppColors.bgCardLight,
                        style: GoogleFonts.outfit(color: AppColors.textPrimary),
                        decoration: const InputDecoration(),
                        items: [
                          DropdownMenuItem(
                            value: 'rendah',
                            child: Text('Rendah', style: GoogleFonts.outfit(color: AppColors.textPrimary)),
                          ),
                          DropdownMenuItem(
                            value: 'sedang',
                            child: Text('Sedang', style: GoogleFonts.outfit(color: AppColors.textPrimary)),
                          ),
                          DropdownMenuItem(
                            value: 'tinggi',
                            child: Text('Tinggi (Mendesak)', style: GoogleFonts.outfit(color: AppColors.textPrimary)),
                          ),
                        ],
                        onChanged: (val) {
                          setModalState(() {
                            selectedPrioritas = val;
                          });
                        },
                      ),
                      const SizedBox(height: 28),

                      // ============ SUBMIT BUTTON ============
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) return;

                            final newLaporan = LaporanKerusakan(
                              id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
                              assetId: selectedAsset!.id,
                              assetName: selectedAsset!.name,
                              gedungId: selectedGedung!.id,
                              gedungName: selectedGedung!.name,
                              nomorLantai: selectedLantai!.nomorLantai,
                              lantaiName: selectedLantai!.name,
                              ruanganId: selectedRuangan!.id,
                              ruanganName: selectedRuangan!.name,
                              deskripsi: deskripsiController.text,
                              pelaporId: user.id,
                              pelaporName: user.name,
                              tanggalLapor: DateTime.now(),
                              prioritas: selectedPrioritas!,
                              sudahDitindak: false,
                            );

                            // addLaporanKerusakan juga OTOMATIS mengubah status aset → rusak
                            facility.addLaporanKerusakan(newLaporan);
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Laporan berhasil! Status "${selectedAsset!.name}" otomatis berubah menjadi RUSAK.',
                                ),
                                backgroundColor: AppColors.success,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Kirim Laporan',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}
