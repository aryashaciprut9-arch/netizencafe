import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'models/menu_models.dart';
import 'services/api_services.dart';

class KelolaManuAdmin extends StatefulWidget {
  const KelolaManuAdmin({super.key});

  @override
  State<KelolaManuAdmin> createState() => _KelolaManuAdminState();
}

class _KelolaManuAdminState extends State<KelolaManuAdmin> {
  // --- VARIABEL & LOGIKA (TIDAK DIUBAH) ---
  List<MenuModel> _menus = [];
  bool _isLoading = true;
  String _selectedKategori = 'Semua';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final List<String> _kategoriList = ['Semua', 'Makanan', 'Minuman', 'Snack'];
  XFile? _pickedXFile;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getMenu();
      setState(() {
        _menus = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error Load: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(StateSetter setModalState) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setModalState(() {
        _pickedXFile = pickedFile;
        _webImage = bytes;
      });
    }
  }

  List<MenuModel> get _filteredMenus {
    return _menus.where((m) {
      final matchKat = _selectedKategori == 'Semua' || m.kategori == _selectedKategori;
      final matchSearch = m.nama.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchKat && matchSearch;
    }).toList();
  }

  // --- UI: FORM MODAL (DIPERCANTIK SESUAI FIGMA) ---
  void _showForm({MenuModel? menu}) {
    final isEdit = menu != null;
    final namaCtrl = TextEditingController(text: menu?.nama ?? '');
    final hargaCtrl = TextEditingController(text: menu?.harga.toString() ?? '');
    final descCtrl = TextEditingController(text: menu?.deskripsi ?? '');
    String kategori = menu?.kategori ?? 'Makanan';
    String tampil = menu?.tampil ?? 'Normal';

    _pickedXFile = null;
    _webImage = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 15),
                Text(isEdit ? 'Edit Menu' : 'Tambah Menu Baru', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                _buildLabel('Foto Menu'),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _pickImage(setModalState),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade300)),
                    child: _webImage != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.memory(_webImage!, fit: BoxFit.cover))
                        : (isEdit && menu.foto.isNotEmpty)
                            ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network("${ApiService.baseUrl}/menu/uploads/${menu.foto}", fit: BoxFit.cover))
                            : const Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),

                _buildLabel('Nama Menu'),
                _buildInput(namaCtrl, 'Masukkan nama menu...'),
                const SizedBox(height: 15),

                _buildLabel('Kategori'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: ['Makanan', 'Minuman', 'Snack'].map((k) => ChoiceChip(
                    label: Text(k),
                    selected: kategori == k,
                    selectedColor: const Color(0xFF8A4607),
                    labelStyle: TextStyle(color: kategori == k ? Colors.white : Colors.black),
                    onSelected: (val) => setModalState(() => kategori = k),
                  )).toList(),
                ),
                const SizedBox(height: 15),

                _buildLabel('Harga'),
                _buildInput(hargaCtrl, 'Contoh: 15000', isNumber: true),
                const SizedBox(height: 15),

                _buildLabel('Deskripsi'),
                _buildInput(descCtrl, 'Masukkan deskripsi singkat...', maxLines: 3),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8A4607),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (namaCtrl.text.isEmpty || hargaCtrl.text.isEmpty) return;
                      bool success;
                      if (isEdit) {
                        success = await ApiService.editMenu(
                          id: menu.id, nama: namaCtrl.text, kategori: kategori,
                          harga: int.parse(hargaCtrl.text), deskripsi: descCtrl.text,
                          tampil: tampil, fotoLama: menu.foto,
                          fotoBytes: _webImage, fotoFileName: _pickedXFile?.name,
                        );
                      } else {
                        success = await ApiService.tambahMenu(
                          nama: namaCtrl.text, kategori: kategori,
                          harga: int.parse(hargaCtrl.text), deskripsi: descCtrl.text,
                          tampil: tampil, fotoBytes: _webImage, fotoFileName: _pickedXFile?.name,
                        );
                      }
                      if (success) { Navigator.pop(ctx); _loadMenu(); }
                    },
                    child: Text(isEdit ? 'Update Menu' : 'Simpan Menu', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(MenuModel menu) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Menu?'),
        content: Text('Yakin ingin menghapus ${menu.nama}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              final ok = await ApiService.hapusMenu(menu.id);
              if (ok) { Navigator.pop(ctx); _loadMenu(); }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- UI UTAMA (GRID VIEW + MODERN SEARCH) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF8A4607),
        title: const Text('Manajemen Menu', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: _loadMenu, icon: const Icon(Icons.refresh))],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8A4607),
        onPressed: () => _showForm(),
        label: const Text('Tambah', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF8A4607)))
                : _filteredMenus.isEmpty 
                  ? const Center(child: Text("Menu tidak ditemukan"))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 Kolom sesuai Figma
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: _filteredMenus.length,
                      itemBuilder: (ctx, i) {
                        final menu = _filteredMenus[i];
                        return _buildGridCard(menu);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(MenuModel menu) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: menu.foto.isNotEmpty
                  ? Image.network("${ApiService.baseUrl}/menu/uploads/${menu.foto}", width: double.infinity, fit: BoxFit.cover)
                  : Container(color: Colors.grey[100], child: const Icon(Icons.fastfood, color: Colors.grey)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(menu.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('Rp ${menu.harga}', style: const TextStyle(color: Color(0xFF8A4607), fontWeight: FontWeight.bold, fontSize: 13)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(onPressed: () => _showForm(menu: menu), icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20), constraints: const BoxConstraints()),
                    IconButton(onPressed: () => _confirmDelete(menu), icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), constraints: const BoxConstraints()),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87));

  Widget _buildInput(TextEditingController ctrl, String hint, {bool isNumber = false, int maxLines = 1}) => TextField(
    controller: ctrl,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    maxLines: maxLines,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
  );

  Widget _buildSearchBar() => Padding(
      padding: const EdgeInsets.all(16),
      child: Container( // Bungkus dengan Container untuk efek Shadow
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Cari menu favorit...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF8A4607)),
            filled: true,
            fillColor: Colors.white,
            // Pindahkan borderRadius ke sini agar tetap rapi
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );

  Widget _buildCategoryFilter() => SizedBox(
    height: 45,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _kategoriList.length,
      itemBuilder: (ctx, i) {
        final k = _kategoriList[i];
        final active = k == _selectedKategori;
        return GestureDetector(
          onTap: () => setState(() => _selectedKategori = k),
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: active ? const Color(0xFF8A4607) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: active ? null : Border.all(color: Colors.grey.shade300),
            ),
            child: Center(child: Text(k, style: TextStyle(color: active ? Colors.white : Colors.black87, fontWeight: active ? FontWeight.bold : FontWeight.normal))),
          ),
        );
      },
    ),
  );
}