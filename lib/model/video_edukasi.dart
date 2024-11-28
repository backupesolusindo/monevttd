class VideoEdukasi {
  final int idVideo;
  final String judul;
  final String deskripsi;
  final String youtubeId;
  final String status;
  final String createdAt;
  final String updatedAt;

  VideoEdukasi({
    required this.idVideo,
    required this.judul,
    required this.deskripsi,
    required this.youtubeId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VideoEdukasi.fromJson(Map<String, dynamic> json) {
    return VideoEdukasi(
      idVideo: json['id_video'],
      judul: json['judul'],
      deskripsi: json['deskripsi'] ?? '',
      youtubeId: json['youtube_id'],
      status: json['status'] ?? 'nonaktif',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id_video': idVideo,
    'judul': judul,
    'deskripsi': deskripsi,
    'youtube_id': youtubeId,
    'status': status,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
} 