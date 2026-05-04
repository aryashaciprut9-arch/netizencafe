class MenuModel {
  final String id;
  final String nama;
  final String kategori;
  final int harga;
  final String deskripsi;
  final String foto;
  final String tampil;
  final bool tersedia;

  MenuModel({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.deskripsi,
    required this.foto,
    required this.tampil,
    required this.tersedia,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? '',
      // Konversi string "13000" ke int 13000
      harga: int.tryParse(json['harga']?.toString() ?? '0') ?? 0,
      // Jaga-jaga kalau deskripsi di DB NULL
      deskripsi: json['deskripsi']?.toString() ?? '',
      foto: json['foto']?.toString() ?? '',
      tampil: json['tampil']?.toString() ?? 'Normal',
      // JSON kamu ngirim "1", kita ubah ke true
      tersedia: json['tersedia'].toString() == '1' || json['tersedia'].toString() == 'true',
    );
  }
}