/// Model untuk data meja kafe.
/// Digunakan oleh [TataLetakMejaPage] dan dapat digunakan
/// di halaman lain yang memerlukan data meja.

enum StatusMeja { empty, occupied, reserved, maintenance }

class MejaData {
  final int id;
  final String nomor;
  final int capacity;
  final String location;
  final double x;
  final double y;
  final String? notes;
  StatusMeja status;

  MejaData({
    required this.id,
    required this.nomor,
    required this.capacity,
    required this.location,
    required this.x,
    required this.y,
    this.notes,
    required this.status,
  });

  /// Parse status string dari API ke enum [StatusMeja].
  static StatusMeja parseStatus(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'occupied':
        return StatusMeja.occupied;
      case 'reserved':
        return StatusMeja.reserved;
      case 'maintenance':
        return StatusMeja.maintenance;
      default:
        return StatusMeja.empty;
    }
  }
}
