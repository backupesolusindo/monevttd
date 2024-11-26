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

class MinumObat extends StatefulWidget {
  const MinumObat({Key? key}) : super(key: key);

  @override
  State<MinumObat> createState() => _MinumObatState();
}

class _MinumObatState extends State<MinumObat> {
  File? _image;
  final _formKey = GlobalKey<FormState>();
  final _catatanController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? jadwalObat;

  @override
  void initState() {
    super.initState();
    _loadSelectedJadwal();
  }

  Future<void> _loadSelectedJadwal() async {
    final prefs = await SharedPreferences.getInstance();
    
    print('Semua keys di SharedPreferences: ${prefs.getKeys()}');
    print('selected_riwayat_id: ${prefs.getInt('selected_riwayat_id')}');
    print('selected_jadwal: ${prefs.getString('selected_jadwal')}');
    
    final jadwalString = prefs.getString('selected_jadwal');
    if (jadwalString != null) {
      setState(() {
        jadwalObat = json.decode(jadwalString);
      });
    }
  }

  Future<void> _takePicture() async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 80,
      );
      if (photo != null) {
        setState(() {
          _image = File(photo.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto: $e')),
      );
    }
  }

  Future<void> _uploadBuktiMinumObat() async {
    if (_formKey.currentState!.validate() && _image != null) {
      setState(() => _isLoading = true);

      try {
        final prefs = await SharedPreferences.getInstance();
        final idRiwayat = prefs.getInt('selected_riwayat_id');
        final jadwalString = prefs.getString('selected_jadwal');
        
        print('ID Riwayat: $idRiwayat');
        print('Data Jadwal: $jadwalString');
        
        if (idRiwayat == null || jadwalString == null) {
          throw Exception('Data tidak lengkap');
        }

        final jadwalData = json.decode(jadwalString);

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${base_url}api/JadwalObat/upload_bukti'),
        );

        request.fields.addAll({
          'id_riwayat': idRiwayat.toString(),
          'id_jadwal': jadwalData['id_jadwal'].toString(),
          'tanggal': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'catatan': _catatanController.text,
        });

        print('Data yang akan dikirim: ${request.fields}');

        String fileName = 'bukti_${DateTime.now().millisecondsSinceEpoch}.jpg'
            .replaceAll(' ', '_')
            .toLowerCase();
        
        var stream = http.ByteStream(_image!.openRead());
        var length = await _image!.length();
        var multipartFile = http.MultipartFile(
          'foto',
          stream,
          length,
          filename: fileName,
        );
        request.files.add(multipartFile);

        print('Uploading file: $fileName');
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          var jsonResponse = json.decode(response.body);
          var message = jsonResponse['message'];
          var responseData = jsonResponse['response'];
          
          if (message['status'] == 200) {
            print('Foto URL: ${responseData['foto_url']}');
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message['message']),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else {
            throw Exception(message['message']);
          }
        } else {
          throw Exception('Server error: ${response.statusCode}');
        }
      } catch (e) {
        print('Error uploading: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } else if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mohon ambil foto bukti minum obat'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (jadwalObat == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Minum Obat',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: PrimaryColor,
        ),
        body: Center(
          child: Lottie.asset(
            'assets/lottie/main_loading.json',
            width: 200,
            height: 200,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Minum Obat',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
                              // Informasi Obat
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: PrimaryColor),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Informasi Obat:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: PrimaryColor,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Nama Obat: ${jadwalObat!['nama_obat']}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      'Dosis: ${jadwalObat!['dosis']} ${jadwalObat!['satuan']}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      'Waktu: ${jadwalObat!['waktu']}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              // Area Foto
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
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Belum ada foto',
                                              style: TextStyle(color: Colors.grey),
                                            ),
                                            SizedBox(height: 10),
                                            ElevatedButton.icon(
                                              onPressed: _takePicture,
                                              icon: Icon(Icons.camera_alt, color: Colors.white),
                                              label: Text(
                                                'Ambil Foto',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: PrimaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                              if (_image != null) ...[
                                SizedBox(height: 10),
                                ElevatedButton.icon(
                                  onPressed: _takePicture,
                                  icon: Icon(Icons.camera_alt, color: Colors.white),
                                  label: Text(
                                    'Ambil Ulang Foto',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: PrimaryColor,
                                  ),
                                ),
                              ],
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
                                onPressed: _isLoading ? null : _uploadBuktiMinumObat,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: PrimaryColor,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Simpan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
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