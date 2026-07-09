import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/facility_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/facility_model.dart';
import 'ruangan_list_screen.dart';

class LantaiListScreen extends StatelessWidget {
  final GedungModel gedung;
  const LantaiListScreen({super.key, required this.gedung});

  @override
  Widget build(BuildContext context) {
    final facility = context.watch<FacilityProvider>();
    final updatedGedung = facility.getGedungById(gedung.id) ?? gedung;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        slivers: [
          // AppBar
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
                  updatedGedung.name,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Daftar Lantai',
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
                onPressed: () {},
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Gedung info banner
                _buildGedungBanner(updatedGedung),
                const SizedBox(height: 20),

                // Lantai header
                Text(
                  '${updatedGedung.lantai.length} Lantai ditemukan',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Grid of lantai cards
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: updatedGedung.lantai.length,
                  itemBuilder: (context, index) {
                    final lantai = updatedGedung.lantai[index];
                    return _buildLantaiCard(context, updatedGedung, lantai);
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

  Widget _buildGedungBanner(GedungModel updatedGedung) {
    int totalRuangan = 0;
    int totalAsset = 0;
    int asetBaik = 0;
    int asetRusak = 0;

    for (var l in updatedGedung.lantai) {
      totalRuangan += l.ruangan.length;
      for (var r in l.ruangan) {
        totalAsset += r.assets.length;
        asetBaik += r.assets.where((a) => a.status == AssetStatus.baik).length;
        asetRusak +=
            r.assets.where((a) => a.status == AssetStatus.rusak).length;
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.25),
            AppColors.accent.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gedung.name,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      gedung.alamat,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _bannerStat('${gedung.lantai.length}', 'Lantai'),
              _divider(),
              _bannerStat('$totalRuangan', 'Ruangan'),
              _divider(),
              _bannerStat('$totalAsset', 'Total Aset'),
              _divider(),
              _bannerStat('$asetRusak', 'Rusak',
                  color: asetRusak > 0 ? AppColors.danger : null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bannerStat(String value, String label, {Color? color}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color ?? AppColors.textPrimary,
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

  Widget _divider() {
    return Container(
      width: 1,
      height: 30,
      color: AppColors.border,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildLantaiCard(BuildContext context, GedungModel updatedGedung, LantaiModel lantai) {
    int totalRuangan = lantai.ruangan.length;
    int totalAsset = 0;
    int asetBaik = 0;
    int asetRusak = 0;
    int asetMaintenance = 0;

    for (var r in lantai.ruangan) {
      totalAsset += r.assets.length;
      asetBaik += r.assets.where((a) => a.status == AssetStatus.baik).length;
      asetRusak += r.assets.where((a) => a.status == AssetStatus.rusak).length;
      asetMaintenance +=
          r.assets.where((a) => a.status == AssetStatus.maintenance).length;
    }

    // Card color based on status
    Color accentColor;
    if (asetRusak > 0) {
      accentColor = AppColors.danger;
    } else if (asetMaintenance > 0) {
      accentColor = AppColors.warning;
    } else {
      accentColor = AppColors.success;
    }

    // Floor number colors for visual variety
    final List<List<Color>> floorColors = [
      [const Color(0xFF1565C0), const Color(0xFF00ACC1)],
      [const Color(0xFF6A1B9A), const Color(0xFFAD1457)],
      [const Color(0xFF00695C), const Color(0xFF00838F)],
      [const Color(0xFFE65100), const Color(0xFFF57F17)],
    ];
    final gradientColors = floorColors[lantai.nomorLantai % floorColors.length];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RuanganListScreen(
              gedungId: updatedGedung.id,
              nomorLantai: lantai.nomorLantai,
              gedungName: updatedGedung.name,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accentColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top gradient section with floor number
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${lantai.nomorLantai}',
                        style: GoogleFonts.outfit(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      Text(
                        'LANTAI',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom info section
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      lantai.name,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        _cardMiniStat(
                          '$totalRuangan',
                          'Ruang',
                          AppColors.accent,
                        ),
                        const SizedBox(width: 6),
                        _cardMiniStat(
                          '$totalAsset',
                          'Aset',
                          AppColors.info,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          asetRusak > 0
                              ? '$asetRusak Rusak'
                              : asetMaintenance > 0
                                  ? '$asetMaintenance Maintenance'
                                  : 'Semua Baik',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardMiniStat(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$value $label',
        style: GoogleFonts.outfit(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
