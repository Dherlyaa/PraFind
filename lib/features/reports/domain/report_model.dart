// Sumber tunggal status laporan untuk menyeragamkan status OPEN dan ACTIVE (Issue #6)
enum ReportStatus {
  active('ACTIVE'),
  resolved('RESOLVED');

  final String value;
  const ReportStatus(this.value);

  static ReportStatus fromString(String? raw) {
    final normalized = (raw ?? 'ACTIVE').trim().toUpperCase();
    if (normalized == 'RESOLVED' || normalized == 'CLOSED' || normalized == 'DONE') {
      return ReportStatus.resolved;
    }
    // Menormalkan status lama 'OPEN' menjadi active agar tombol selesai muncul
    return ReportStatus.active;
  }
}

class ReportModel {
  final String id;
  final String title;
  final String category;
  final String location;
  final String description;
  final String type;
  final String status;
  // Field path/URL gambar barang untuk daftar & detail laporan (Issue #7)
  final String? imagePath;
  // Field pemilik laporan untuk otorisasi hapus/selesai (Issue #10)
  final String ownerId;
  // Field identitas pelapor, kontak, dan waktu pembuatan laporan (Issue #11)
  final String reporterName;
  final String contact;
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.description,
    required this.type,
    String status = 'ACTIVE',
    this.imagePath,
    this.ownerId = 'user_pradita_01',
    this.reporterName = 'Mahasiswa Pradita',
    this.contact = '081234567890',
    DateTime? createdAt,
  })  : status = ReportStatus.fromString(status).value,
        createdAt = createdAt ?? DateTime(2026, 11, 27, 9, 0);

  ReportStatus get statusEnum => ReportStatus.fromString(status);
  bool get isActive => statusEnum == ReportStatus.active;
  bool get isResolved => statusEnum == ReportStatus.resolved;
  bool get hasImage => imagePath != null && imagePath!.trim().isNotEmpty;

  // Hanya pembuat laporan atau admin yang berhak mengubah/menghapus laporan (Issue #10)
  bool canModify(String userId, {bool isAdmin = false}) {
    return isAdmin || ownerId == userId;
  }

  ReportModel copyWith({
    String? id,
    String? title,
    String? category,
    String? location,
    String? description,
    String? type,
    String? status,
    String? imagePath,
    String? ownerId,
    String? reporterName,
    String? contact,
    DateTime? createdAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      location: location ?? this.location,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      ownerId: ownerId ?? this.ownerId,
      reporterName: reporterName ?? this.reporterName,
      contact: contact ?? this.contact,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    // Validasi untuk Unit Test: Model Invalid
    if (!json.containsKey('id') || !json.containsKey('title')) {
      throw const FormatException('Invalid JSON: Key "id" atau "title" hilang');
    }

    final rawImage = json['imagePath'] ?? json['imageUrl'];
    final rawCreatedAt = json['createdAt']?.toString();

    return ReportModel(
      id: json['id'].toString(),
      title: json['title'].toString(),
      category: json['category']?.toString() ?? 'Umum',
      location: json['location']?.toString() ?? 'Tidak diketahui',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? 'LOST',
      status: ReportStatus.fromString(json['status']?.toString()).value,
      imagePath: rawImage?.toString(),
      ownerId: json['ownerId']?.toString() ?? 'user_pradita_01',
      reporterName: json['reporterName']?.toString() ?? 'Mahasiswa Pradita',
      contact: json['contact']?.toString() ?? '081234567890',
      createdAt: rawCreatedAt != null ? DateTime.tryParse(rawCreatedAt) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'location': location,
      'description': description,
      'type': type,
      'status': status,
      'imagePath': imagePath,
      'ownerId': ownerId,
      'reporterName': reporterName,
      'contact': contact,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
