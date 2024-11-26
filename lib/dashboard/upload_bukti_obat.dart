import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monitoringobat/util/colors.dart';
import 'package:monitoringobat/util/core.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:monitoringobat/model/user.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'package:path/path.dart' as path;

class UploadBuktiObat extends StatefulWidget {
  final File? imageFile;

  const UploadBuktiObat({Key? key, this.imageFile}) : super(key: key);

  @override
  State<UploadBuktiObat> createState() => _UploadBuktiObatState();
}

class _UploadBuktiObatState extends State<UploadBuktiObat> {
  File? _image;
  final _formKey = GlobalKey<FormState>();
  final _catatanController = TextEditingController();
  bool _isLoading = false;
  int? _idRiwayat;
  int? _idJadwal;
  String? _tanggal;

  @override
  void initState() {
    super.initState();
    _image = widget.imageFile;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedJadwal = prefs.getString('selected_jadwal');
      
      print('Data jadwal dari SharedPreferences: $selectedJadwal');
      
      if (selectedJadwal != null) {
        final jadwalData = json.decode(selectedJadwal);
        setState(() {
          _idRiwayat = jadwalData['id_riwayat'];
          _idJadwal = jadwalData['id_jadwal'];
          _tanggal = jadwalData['tanggal'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
        });
        
        print('Data yang diload:');
        print('ID Riwayat: $_idRiwayat');
        print('ID Jadwal: $_idJadwal');
        print('Tanggal: $_tanggal');
      } else {
        throw Exception('Data jadwal tidak ditemukan');
      }
    } catch (e) {
      print('Error loading data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: ${e.toString()}')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _uploadBuktiObat() async {
    if (_formKey.currentState!.validate() && _image != null) {
      if (_idRiwayat == null || _idJadwal == null || _tanggal == null) {
        print('Error: Data tidak lengkap');
        print('ID Riwayat: $_idRiwayat');
        print('ID Jadwal: $_idJadwal');
        print('Tanggal: $_tanggal');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data tidak lengkap')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        print('Mulai upload dengan data:');
        print('ID Riwayat: $_idRiwayat');
        print('ID Jadwal: $_idJadwal');
        print('Tanggal: $_tanggal');
        
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${base_url}api/JadwalObat/upload_bukti'),
        );

        request.fields.addAll({
          'id_riwayat': _idRiwayat.toString(),
          'id_jadwal': _idJadwal.toString(),
          'tanggal': _tanggal!,
          'catatan': _catatanController.text,
        });

        print('Data yang akan dikirim: ${request.fields}');

        if (_image != null) {
          var stream = http.ByteStream(_image!.openRead());
          var length = await _image!.length();
          var multipartFile = http.MultipartFile(
            'foto',
            stream,
            length,
            filename: path.basename(_image!.path),
          );
          request.files.add(multipartFile);
        }

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('selected_riwayat_id');
          await prefs.remove('selected_jadwal');
          
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bukti berhasil diupload')),
          );
        } else {
          throw Exception('Gagal upload bukti');
        }
      } catch (e) {
        print('Error during upload: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload bukti: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mohon lengkapi data dan pilih foto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Upload Bukti Minum Obat', 
          style: TextStyle(
            color: Colors.white, 
            fontSize: 20, 
            fontWeight: FontWeight.bold
          )
        ),
        backgroundColor: PrimaryColor,
      ),
      body: _isLoading 
          ? Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              child: Center(
                child: Lottie.asset(
                  'assets/lottie/main_loading.json',
                  width: 200,
                  height: 200,
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bgmonevminumobatbaru.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                height: 300,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: _image != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          _image!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          'Tidak ada foto yang dipilih',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                controller: _catatanController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: 'Catatan',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelStyle: TextStyle(color: Colors.black),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Mohon isi catatan';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _isLoading ? null : _uploadBuktiObat,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: PrimaryColor,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: _isLoading
                                    ? CircularProgressIndicator(color: Colors.white)
                                    : Text(
                                        'Upload Bukti',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                              SizedBox(height: 20),
                              Divider(color: PrimaryColor),
                              SizedBox(height: 20),
                              Text(
                                'Petunjuk Penggunaan:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: PrimaryColor,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                '1. Pilih foto bukti minum obat\n'
                                '2. Tambahkan catatan jika diperlukan\n'
                                '3. Tekan tombol Upload Bukti untuk mengirim',
                                style: TextStyle(
                                  fontSize: 16, 
                                  color: Colors.black87
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
} 