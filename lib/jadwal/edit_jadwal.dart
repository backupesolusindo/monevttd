import 'package:flutter/material.dart';
import 'package:monitoringobat/util/colors.dart';
import 'package:monitoringobat/util/core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:monitoringobat/model/user.dart';

class EditJadwal extends StatefulWidget {
  final Map<String, dynamic> jadwal;
  
  EditJadwal({required this.jadwal});
  
  @override
  _EditJadwalState createState() => _EditJadwalState();
}

class _EditJadwalState extends State<EditJadwal> {
  String? selectedDay;
  int? selectedObatId;
  TimeOfDay selectedTime = TimeOfDay.now();
  bool _isLoading = false;
  List<String> days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  List<Map<String, dynamic>> obatList = [];
  
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    selectedDay = widget.jadwal['hari'];
    selectedObatId = widget.jadwal['id_obat'];
    selectedTime = TimeOfDay(
      hour: int.parse(widget.jadwal['waktu'].split(':')[0]),
      minute: int.parse(widget.jadwal['waktu'].split(':')[1])
    );
    _loadObatList();
  }

  Future<void> _loadObatList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var userDataString = prefs.getString('user_data');
      
      if (userDataString == null) {
        throw Exception('Data user tidak ditemukan');
      }

      final userData = UserData.fromJson(json.decode(userDataString));
      
      var response = await http.get(
        Uri.parse('${base_url}api/JadwalObat/list_obat?id_user=${userData.idUser}'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['message']['status'] == 200) {
          setState(() {
            obatList = List<Map<String, dynamic>>.from(jsonResponse['response']);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _updateJadwal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      var accessToken = prefs.getString('access_token');

      var response = await http.put(
        Uri.parse('${base_url}api/JadwalObat/edit_jadwal'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'id_jadwal': widget.jadwal['id_jadwal'].toString(),
          'id_obat': selectedObatId.toString(),
          'hari': selectedDay,
          'waktu': '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
        },
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Jadwal berhasil diperbarui')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui jadwal: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Edit Jadwal',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: PrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Hari Minum',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: selectedDay,
                  items: days.map((String day) {
                    return DropdownMenuItem<String>(
                      value: day,
                      child: Text(day),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDay = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mohon pilih hari';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Pilih Obat',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: selectedObatId,
                  items: obatList.map((obat) {
                    return DropdownMenuItem<int>(
                      value: obat['id_obat'] as int,
                      child: Text('${obat['nama_obat']} - ${obat['dosis']} ${obat['satuan']}'),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedObatId = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Mohon pilih obat';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectTime(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Waktu/Jam Minum',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(selectedTime.format(context)),
                        Icon(Icons.access_time, color: PrimaryColor),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateJadwal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PrimaryColor,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'SIMPAN',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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