import 'package:flutter/material.dart';
import 'package:monitoringobat/util/colors.dart';
import 'package:monitoringobat/util/core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:monitoringobat/model/user.dart';
import 'package:lottie/lottie.dart';

class TambahObat extends StatefulWidget {
  @override
  _TambahObatState createState() => _TambahObatState();
}

class _TambahObatState extends State<TambahObat> {
  final _formKey = GlobalKey<FormState>();
  final _namaObatController = TextEditingController();
  final _dosisController = TextEditingController();
  String? selectedUnit;
  List<String> units = ['Tablet', 'Pack'];
  bool _isLoading = false;

  Future<void> _tambahObat() async {
    if (_formKey.currentState!.validate() && selectedUnit != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final prefs = await SharedPreferences.getInstance();
        var userDataString = prefs.getString('user_data');
        var accessToken = prefs.getString('access_token');

        if (userDataString == null || accessToken == null) {
          throw Exception('User data atau token tidak ditemukan');
        }

        final userData = UserData.fromJson(json.decode(userDataString));

        double dosis = double.parse(_dosisController.text);
        if (dosis <= 0) {
          throw Exception('Dosis harus lebih dari 0');
        }

        var uri = Uri.parse('${base_url}api/Obat/tambah');
        var response = await http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'id_user': userData.idUser.toString(),
            'nama_obat': _namaObatController.text.trim(),
            'dosis': dosis.toString(),
            'satuan': selectedUnit,
          },
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        var jsonResponse = json.decode(response.body);
        
        if (jsonResponse['message']['status'] == 200) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: PrimaryColor,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Berhasil',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  jsonResponse['message']['message'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: PrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            },
          );
        } else {
          throw Exception(jsonResponse['message']['message']);
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back, color: Colors.white),
      //     onPressed: () => Navigator.of(context).pop(),
      //   ),
      //   title: Text('Tambah Obat', 
      //     style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
      //   ),
      //   backgroundColor: PrimaryColor,
      // ),
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
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _namaObatController,
                          decoration: InputDecoration(
                            labelText: 'Nama Obat',
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mohon isi nama obat';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _dosisController,
                                decoration: InputDecoration(
                                  labelText: 'Dosis Obat',
                                  border: OutlineInputBorder(),
                                  labelStyle: TextStyle(color: Colors.black),
                                ),
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Mohon isi dosis obat';
                                  }
                                  try {
                                    double dosis = double.parse(value);
                                    if (dosis <= 0) {
                                      return 'Dosis harus lebih dari 0';
                                    }
                                  } catch (e) {
                                    return 'Masukkan angka yang valid';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Satuan',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  labelStyle: TextStyle(color: Colors.black),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                ),
                                value: selectedUnit,
                                dropdownColor: Colors.white,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                                icon: Icon(Icons.arrow_drop_down, color: PrimaryColor),
                                isExpanded: true,
                                items: units.map((String unit) {
                                  return DropdownMenuItem<String>(
                                    value: unit,
                                    child: Text(
                                      unit,
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Pilih satuan';
                                  }
                                  return null;
                                },
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedUnit = newValue;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _tambahObat,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PrimaryColor,
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text('SIMPAN', style: TextStyle(color: Colors.white)),
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
                          '1. Masukkan nama obat\n'
                          '2. Masukkan dosis obat dan pilih satuan\n'
                          '3. Masukkan jadwal konsumsi obat\n'
                          '4. Tekan tombol SIMPAN untuk menyimpan data obat',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Catatan: Pastikan untuk selalu mengikuti petunjuk dokter dalam mengonsumsi obat.',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: PrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 250,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
