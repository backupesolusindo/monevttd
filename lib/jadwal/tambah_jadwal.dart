import 'package:flutter/material.dart';
import 'package:monitoringobat/util/colors.dart';
import 'package:monitoringobat/util/core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:monitoringobat/model/user.dart';
import 'package:lottie/lottie.dart';
import 'package:monitoringobat/util/alarm_service.dart';

// Helper: konversi nama hari ke DateTime weekday number
int _dayNumber(String dayName) {
  const map = {
    'Senin': DateTime.monday,
    'Selasa': DateTime.tuesday,
    'Rabu': DateTime.wednesday,
    'Kamis': DateTime.thursday,
    'Jumat': DateTime.friday,
    'Sabtu': DateTime.saturday,
    'Minggu': DateTime.sunday,
  };
  return map[dayName] ?? DateTime.monday;
}

class TambahJadwal extends StatefulWidget {
  @override
  _TambahJadwalState createState() => _TambahJadwalState();
}

class _TambahJadwalState extends State<TambahJadwal> {
  String? selectedDay;
  String? selectedObat;
  int? selectedObatId;
  TimeOfDay selectedTime = TimeOfDay.now();
  bool _isLoading = false;
  bool _isLoadingData = true;

  List<String> days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];
  List<Map<String, dynamic>> obatList = [];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadObatList();
  }

  Future<void> _loadObatList() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      var userDataString = prefs.getString('user_data');

      if (userDataString == null) {
        throw Exception('Data user tidak ditemukan');
      }

      final userData = UserData.fromJson(json.decode(userDataString));

      var uri = Uri.parse('${base_url}api/JadwalObat/list_obat')
          .replace(queryParameters: {'id_user': userData.idUser.toString()});

      var response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['message']['status'] == 200) {
          setState(() {
            obatList = (jsonResponse['response'] as List)
                .map((item) => {
                      'id_obat': int.parse(item['id_obat'].toString()),
                      'nama_obat': item['nama_obat'].toString(),
                      'dosis': item['dosis'].toString(),
                      'satuan': item['satuan'].toString(),
                    })
                .toList();
            _isLoadingData = false;
          });
        } else if (jsonResponse['message']['status'] == 204) {
          setState(() {
            obatList = [];
            _isLoadingData = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Belum ada data obat')),
          );
        } else {
          throw Exception(jsonResponse['message']['message']);
        }
      } else {
        throw Exception('Gagal memuat data obat');
      }
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  Future<void> _tambahJadwal() async {
    if (_formKey.currentState!.validate()) {
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

        var uri = Uri.parse('${base_url}api/JadwalObat/tambah');
        var response = await http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'id_user': userData.idUser.toString(),
            'id_obat': selectedObatId.toString(),
            'hari': selectedDay,
            'waktu':
                '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00',
          },
        );

        var jsonResponse = json.decode(response.body);
        if (jsonResponse['message']['status'] == 200) {
          // Gunakan id_jadwal dari response API sebagai alarm ID agar unik
          // per jadwal (bukan per obat), sehingga obat yang sama bisa punya
          // beberapa jadwal di hari berbeda tanpa saling menimpa.
          final int idJadwal = int.tryParse(
                  jsonResponse['response']?['id_jadwal']?.toString() ?? '') ??
              selectedObatId!;

          final now = DateTime.now();
          int daysUntilSchedule = _dayNumber(selectedDay!) - now.weekday;
          if (daysUntilSchedule < 0) {
            daysUntilSchedule += 7;
          } else if (daysUntilSchedule == 0) {
            final todayTarget = DateTime(now.year, now.month, now.day,
                selectedTime.hour, selectedTime.minute);
            if (!todayTarget.isAfter(now)) daysUntilSchedule = 7;
          }

          final scheduleTime = DateTime(
            now.year,
            now.month,
            now.day + daysUntilSchedule,
            selectedTime.hour,
            selectedTime.minute,
          );

          final selectedObatData =
              obatList.firstWhere((obat) => obat['id_obat'] == selectedObatId);

          await AlarmService.scheduleAlarm(
            id: idJadwal,
            scheduleTime: scheduleTime,
            obatName: selectedObatData['nama_obat'],
            dosis: selectedObatData['dosis'],
            satuan: selectedObatData['satuan'],
            selectedDay: selectedDay!,
          );

          if (!mounted) return;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Row(
                  children: [
                    Icon(Icons.check_circle, color: PrimaryColor, size: 28),
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
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jsonResponse['message']['message'],
                      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Jadwal notifikasi dibuat untuk ${selectedDay}, ${selectedTime.format(context)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
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
          throw Exception(jsonResponse['message']['detail']);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Terjadi kesalahan saat menyimpan jadwal')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
      // appBar: AppBar(
      //   // leading: IconButton(
      //   //   icon: Icon(Icons.arrow_back, color: Colors.white),
      //   //   onPressed: () => Navigator.of(context).pop(),
      //   // ),
      //   // title: Text('Tambah Jadwal', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      //   // backgroundColor: PrimaryColor,
      // ),
      body: _isLoadingData
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
              color: Colors.white,
              child: SafeArea(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20),
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Hari Minum',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  labelStyle: TextStyle(color: Colors.black),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 16),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                value: selectedDay,
                                hint: Text(
                                  'Pilih Hari',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                dropdownColor: Colors.white,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                                isExpanded: true,
                                icon: Icon(Icons.arrow_drop_down,
                                    color: PrimaryColor),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Mohon pilih hari';
                                  }
                                  return null;
                                },
                                items: days.map((String day) {
                                  return DropdownMenuItem<String>(
                                    value: day,
                                    child: Text(
                                      day,
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedDay = newValue;
                                  });
                                },
                              ),
                              SizedBox(height: 20),
                              DropdownButtonFormField<int>(
                                decoration: InputDecoration(
                                  labelText: 'Pilih Obat',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  labelStyle: TextStyle(color: Colors.black),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 16),
                                ),
                                value: selectedObatId,
                                dropdownColor: Colors.white,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                                items: obatList.map((obat) {
                                  return DropdownMenuItem<int>(
                                    value: obat['id_obat'] as int,
                                    child: Text(
                                      '${obat['nama_obat']} - ${obat['dosis']} ${obat['satuan']}',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (int? newValue) {
                                  setState(() {
                                    selectedObatId = newValue;
                                    selectedObat = obatList
                                        .firstWhere((obat) =>
                                            obat['id_obat'] ==
                                            newValue)['nama_obat']
                                        .toString();
                                  });
                                },
                                icon: Icon(Icons.arrow_drop_down,
                                    color: PrimaryColor),
                                isExpanded: true,
                              ),
                              SizedBox(height: 20),
                              InkWell(
                                onTap: () => _selectTime(context),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Waktu/Jam Minum',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    labelStyle: TextStyle(color: Colors.black),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        selectedTime.format(context),
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Icon(
                                        Icons.access_time,
                                        color: PrimaryColor,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 30),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _tambahJadwal,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: PrimaryColor,
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                  ),
                                  child: _isLoading
                                      ? CircularProgressIndicator(
                                          color: Colors.white)
                                      : Text('SIMPAN',
                                          style:
                                              TextStyle(color: Colors.white)),
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
                                '1. Pilih hari untuk minum obat\n'
                                '2. Pilih obat yang akan diminum\n'
                                '3. Atur waktu minum obat\n'
                                '4. Tekan tombol SIMPAN untuk menyimpan jadwal',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black87),
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
                      ),
                      Container(
                        height: 50,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
