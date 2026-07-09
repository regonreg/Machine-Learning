enum AssetStatus { baik, rusak, maintenance, tidakAktif }

enum MaintenanceStatus { selesai, proses, menunggu }

class AssetModel {
  final String id;
  final String name;
  final String category;
  final AssetStatus status;
  final String ruanganId;
  final DateTime lastMaintenance;
  final String serialNumber;
  final String brand;
  final String kondisi;

  const AssetModel({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.ruanganId,
    required this.lastMaintenance,
    required this.serialNumber,
    required this.brand,
    required this.kondisi,
  });

  String get statusLabel {
    switch (status) {
      case AssetStatus.baik:
        return 'Baik';
      case AssetStatus.rusak:
        return 'Rusak';
      case AssetStatus.maintenance:
        return 'Maintenance';
      case AssetStatus.tidakAktif:
        return 'Tidak Aktif';
    }
  }
}

class RuanganModel {
  final String id;
  final String name;
  final String lantaiId;
  final int kapasitas;
  final String tipe;
  final List<AssetModel> assets;

  const RuanganModel({
    required this.id,
    required this.name,
    required this.lantaiId,
    required this.kapasitas,
    required this.tipe,
    required this.assets,
  });
}

class LantaiModel {
  final String id;
  final String name;
  final int nomorLantai;
  final String gedungId;
  final List<RuanganModel> ruangan;

  const LantaiModel({
    required this.id,
    required this.name,
    required this.nomorLantai,
    required this.gedungId,
    required this.ruangan,
  });
}

class GedungModel {
  final String id;
  final String name;
  final String alamat;
  final String penanggungJawab;
  final int totalLantai;
  final List<LantaiModel> lantai;

  const GedungModel({
    required this.id,
    required this.name,
    required this.alamat,
    required this.penanggungJawab,
    required this.totalLantai,
    required this.lantai,
  });
}

class MaintenanceRecord {
  final String id;
  final String assetId;
  final String assetName;
  final String ruangan;
  final String lantai;
  final String gedung;
  final String deskripsi;
  final MaintenanceStatus status;
  final DateTime tanggal;
  final String teknisi;
  final int biaya;

  const MaintenanceRecord({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.ruangan,
    required this.lantai,
    required this.gedung,
    required this.deskripsi,
    required this.status,
    required this.tanggal,
    required this.teknisi,
    required this.biaya,
  });

  String get statusLabel {
    switch (status) {
      case MaintenanceStatus.selesai:
        return 'Selesai';
      case MaintenanceStatus.proses:
        return 'Dalam Proses';
      case MaintenanceStatus.menunggu:
        return 'Menunggu';
    }
  }
}

class LaporanKerusakan {
  final String id;
  final String assetId;
  final String assetName;
  final String gedungId;
  final String gedungName;
  final int nomorLantai;
  final String lantaiName;
  final String ruanganId;
  final String ruanganName;
  final String deskripsi;
  final String pelaporId;
  final String pelaporName;
  final DateTime tanggalLapor;
  final String prioritas; // tinggi, sedang, rendah
  final bool sudahDitindak;

  const LaporanKerusakan({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.gedungId,
    required this.gedungName,
    required this.nomorLantai,
    required this.lantaiName,
    required this.ruanganId,
    required this.ruanganName,
    required this.deskripsi,
    required this.pelaporId,
    required this.pelaporName,
    required this.tanggalLapor,
    required this.prioritas,
    required this.sudahDitindak,
  });

  /// Lokasi lengkap untuk ditampilkan di UI
  String get lokasiLengkap => '$ruanganName, $lantaiName, $gedungName';

  /// Buat salinan dengan field sudahDitindak yang diubah
  LaporanKerusakan copyWith({bool? sudahDitindak}) {
    return LaporanKerusakan(
      id: id,
      assetId: assetId,
      assetName: assetName,
      gedungId: gedungId,
      gedungName: gedungName,
      nomorLantai: nomorLantai,
      lantaiName: lantaiName,
      ruanganId: ruanganId,
      ruanganName: ruanganName,
      deskripsi: deskripsi,
      pelaporId: pelaporId,
      pelaporName: pelaporName,
      tanggalLapor: tanggalLapor,
      prioritas: prioritas,
      sudahDitindak: sudahDitindak ?? this.sudahDitindak,
    );
  }
}
