import 'package:flutter/material.dart';
import '../models/facility_model.dart';
import '../utils/dummy_data.dart';

class FacilityProvider extends ChangeNotifier {
  List<GedungModel> _gedungList = [];
  List<MaintenanceRecord> _maintenanceRecords = [];
  List<LaporanKerusakan> _laporanKerusakan = [];

  List<GedungModel> get gedungList => _gedungList;
  List<MaintenanceRecord> get maintenanceRecords => _maintenanceRecords;
  List<LaporanKerusakan> get laporanKerusakan => _laporanKerusakan;

  FacilityProvider() {
    _loadData();
  }

  void _loadData() {
    _gedungList = DummyData.gedungList;
    _maintenanceRecords = DummyData.maintenanceRecords;
    _laporanKerusakan = DummyData.laporanKerusakan;
    notifyListeners();
  }

  // ============================================================
  // DASHBOARD STATS
  // ============================================================
  int get totalGedung => _gedungList.length;

  int get totalAsset {
    int count = 0;
    for (var g in _gedungList) {
      for (var l in g.lantai) {
        for (var r in l.ruangan) {
          count += r.assets.length;
        }
      }
    }
    return count;
  }

  int get totalAssetBaik {
    int count = 0;
    for (var g in _gedungList) {
      for (var l in g.lantai) {
        for (var r in l.ruangan) {
          count += r.assets.where((a) => a.status == AssetStatus.baik).length;
        }
      }
    }
    return count;
  }

  int get totalAssetRusak {
    int count = 0;
    for (var g in _gedungList) {
      for (var l in g.lantai) {
        for (var r in l.ruangan) {
          count += r.assets.where((a) => a.status == AssetStatus.rusak).length;
        }
      }
    }
    return count;
  }

  int get totalAssetMaintenance {
    int count = 0;
    for (var g in _gedungList) {
      for (var l in g.lantai) {
        for (var r in l.ruangan) {
          count +=
              r.assets.where((a) => a.status == AssetStatus.maintenance).length;
        }
      }
    }
    return count;
  }

  int get totalLaporan => _laporanKerusakan.length;
  int get laporanBelumDitindak =>
      _laporanKerusakan.where((l) => !l.sudahDitindak).length;

  void addLaporanKerusakan(LaporanKerusakan laporan) {
    _laporanKerusakan.insert(0, laporan);

    // =====================================================
    // SINKRONISASI: Otomatis ubah status aset menjadi RUSAK
    // saat karyawan mengirim laporan kerusakan
    // =====================================================
    _updateAssetStatusByLocation(
      laporan.gedungId,
      laporan.nomorLantai,
      laporan.ruanganId,
      laporan.assetId,
      AssetStatus.rusak,
    );

    notifyListeners();
  }

  /// Admin menandai laporan sebagai sudah ditindak.
  /// Sekaligus mengubah status aset terkait menjadi 'maintenance' (sedang diperbaiki).
  void tandaiDitindak(String laporanId) {
    final index = _laporanKerusakan.indexWhere((l) => l.id == laporanId);
    if (index != -1) {
      final laporan = _laporanKerusakan[index];
      _laporanKerusakan[index] = laporan.copyWith(sudahDitindak: true);

      // Ubah status aset menjadi maintenance (sedang ditindak)
      _updateAssetStatusByLocation(
        laporan.gedungId,
        laporan.nomorLantai,
        laporan.ruanganId,
        laporan.assetId,
        AssetStatus.maintenance,
      );

      notifyListeners();
    }
  }

  /// Helper: update status aset berdasarkan lokasi hierarki
  void _updateAssetStatusByLocation(
    String gedungId, int nomorLantai, String ruanganId, String assetId, AssetStatus newStatus,
  ) {
    final gIndex = _gedungList.indexWhere((g) => g.id == gedungId);
    if (gIndex != -1) {
      final lIndex = _gedungList[gIndex].lantai.indexWhere((l) => l.nomorLantai == nomorLantai);
      if (lIndex != -1) {
        final rIndex = _gedungList[gIndex].lantai[lIndex].ruangan.indexWhere((r) => r.id == ruanganId);
        if (rIndex != -1) {
          final aIndex = _gedungList[gIndex].lantai[lIndex].ruangan[rIndex].assets.indexWhere((a) => a.id == assetId);
          if (aIndex != -1) {
            final old = _gedungList[gIndex].lantai[lIndex].ruangan[rIndex].assets[aIndex];
            _gedungList[gIndex].lantai[lIndex].ruangan[rIndex].assets[aIndex] = AssetModel(
              id: old.id,
              name: old.name,
              category: old.category,
              status: newStatus,
              ruanganId: old.ruanganId,
              lastMaintenance: old.lastMaintenance,
              serialNumber: old.serialNumber,
              brand: old.brand,
              kondisi: old.kondisi,
            );
          }
        }
      }
    }
  }

  int get maintenanceAktif =>
      _maintenanceRecords
          .where((m) =>
              m.status == MaintenanceStatus.proses ||
              m.status == MaintenanceStatus.menunggu)
          .length;

  // ============================================================
  // GEDUNG OPERATIONS
  // ============================================================
  GedungModel? getGedungById(String id) {
    try {
      return _gedungList.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  List<AssetModel> getAllAssets() {
    List<AssetModel> all = [];
    for (var g in _gedungList) {
      for (var l in g.lantai) {
        for (var r in l.ruangan) {
          all.addAll(r.assets);
        }
      }
    }
    return all;
  }

  Map<String, int> get assetByCategory {
    Map<String, int> map = {};
    for (var asset in getAllAssets()) {
      map[asset.category] = (map[asset.category] ?? 0) + 1;
    }
    return map;
  }

  // ============================================================
  // ADMIN CRUD OPERATIONS
  // ============================================================

  // 1. GEDUNG CRUD
  void addGedung(GedungModel g) {
    _gedungList.add(g);
    notifyListeners();
  }

  void updateGedung(String id, String name, String alamat, String penanggungJawab) {
    final index = _gedungList.indexWhere((g) => g.id == id);
    if (index != -1) {
      final old = _gedungList[index];
      _gedungList[index] = GedungModel(
        id: old.id,
        name: name,
        alamat: alamat,
        penanggungJawab: penanggungJawab,
        totalLantai: old.totalLantai,
        lantai: old.lantai,
      );
      notifyListeners();
    }
  }

  void deleteGedung(String id) {
    _gedungList.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  // 2. RUANGAN CRUD
  void addRuangan(String gedungId, int nomorLantai, RuanganModel r) {
    final gIndex = _gedungList.indexWhere((g) => g.id == gedungId);
    if (gIndex != -1) {
      final lIndex = _gedungList[gIndex].lantai.indexWhere((l) => l.nomorLantai == nomorLantai);
      if (lIndex != -1) {
        _gedungList[gIndex].lantai[lIndex].ruangan.add(r);
        notifyListeners();
      }
    }
  }

  void deleteRuangan(String gedungId, int nomorLantai, String ruanganId) {
    final gIndex = _gedungList.indexWhere((g) => g.id == gedungId);
    if (gIndex != -1) {
      final lIndex = _gedungList[gIndex].lantai.indexWhere((l) => l.nomorLantai == nomorLantai);
      if (lIndex != -1) {
        _gedungList[gIndex].lantai[lIndex].ruangan.removeWhere((r) => r.id == ruanganId);
        notifyListeners();
      }
    }
  }

  // 3. ASET CRUD
  void addAsset(String gedungId, int nomorLantai, String ruanganId, AssetModel a) {
    final gIndex = _gedungList.indexWhere((g) => g.id == gedungId);
    if (gIndex != -1) {
      final lIndex = _gedungList[gIndex].lantai.indexWhere((l) => l.nomorLantai == nomorLantai);
      if (lIndex != -1) {
        final rIndex = _gedungList[gIndex].lantai[lIndex].ruangan.indexWhere((r) => r.id == ruanganId);
        if (rIndex != -1) {
          _gedungList[gIndex].lantai[lIndex].ruangan[rIndex].assets.add(a);
          notifyListeners();
        }
      }
    }
  }

  void updateAsset(String gedungId, int nomorLantai, String ruanganId, AssetModel updatedAsset) {
    final gIndex = _gedungList.indexWhere((g) => g.id == gedungId);
    if (gIndex != -1) {
      final lIndex = _gedungList[gIndex].lantai.indexWhere((l) => l.nomorLantai == nomorLantai);
      if (lIndex != -1) {
        final rIndex = _gedungList[gIndex].lantai[lIndex].ruangan.indexWhere((r) => r.id == ruanganId);
        if (rIndex != -1) {
          final aIndex = _gedungList[gIndex].lantai[lIndex].ruangan[rIndex].assets.indexWhere((a) => a.id == updatedAsset.id);
          if (aIndex != -1) {
            _gedungList[gIndex].lantai[lIndex].ruangan[rIndex].assets[aIndex] = updatedAsset;
            notifyListeners();
          }
        }
      }
    }
  }

  void deleteAsset(String gedungId, int nomorLantai, String ruanganId, String assetId) {
    final gIndex = _gedungList.indexWhere((g) => g.id == gedungId);
    if (gIndex != -1) {
      final lIndex = _gedungList[gIndex].lantai.indexWhere((l) => l.nomorLantai == nomorLantai);
      if (lIndex != -1) {
        final rIndex = _gedungList[gIndex].lantai[lIndex].ruangan.indexWhere((r) => r.id == ruanganId);
        if (rIndex != -1) {
          _gedungList[gIndex].lantai[lIndex].ruangan[rIndex].assets.removeWhere((a) => a.id == assetId);
          notifyListeners();
        }
      }
    }
  }

  // ============================================================
  // MOBILE COMPUTING SPECIAL COMPONENT: Future & Stream Simulation
  // ============================================================

  // Untuk FutureBuilder: Simulasi pengambilan data gedung dari API dengan delay 1.5 detik
  Future<List<GedungModel>> getGedungListAsync() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return _gedungList;
  }

  // Untuk StreamBuilder: Aliran data log aktivitas sistem real-time setiap 4 detik
  Stream<String> get activityLogStream {
    final List<String> logs = [
      'Gedung Utama: Lift Lantai 2 berfungsi normal setelah maintenance.',
      'Gedung IT: Sensor suhu Ruang Server mendeteksi suhu aman (21°C).',
      'Gedung B: Petugas Sari memulai patroli rutin di Lantai 1.',
      'Gedung Utama: AC Ruang Rapat A dibersihkan oleh vendor.',
      'Gedung Utama: Penggantian lampu koridor Lantai 3 selesai.',
      'Gedung B: Pengecekan APAR di Lantai 2 terverifikasi aman.',
      'Gedung IT: Akses pintu Ruang Server dibuka oleh Admin.',
    ];
    return Stream.periodic(const Duration(seconds: 4), (count) {
      return logs[count % logs.length];
    });
  }
}
