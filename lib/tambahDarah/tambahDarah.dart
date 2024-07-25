import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';

import 'package:monitoringobat/bloc/nav/bottom_nav.dart';
import 'package:http/http.dart' as http;
import 'package:monitoringobat/components/popup.dart';
import 'package:monitoringobat/util/colors.dart';
import 'package:monitoringobat/util/core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../model/user.dart';
import '../components/popup.dart';

class InputDarah extends StatefulWidget {
  @override
  _InputDarahState createState() => _InputDarahState();
}

class _InputDarahState extends State<InputDarah> {
  bool isLoading = true;
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String clientId = "PKL2023";
  String clientSecret = "PKLSERU";
  String tokenUrl = base_url + "api/Token/token";
  String accessToken = "";
  String txtNama = "";
  List<dynamic> arTambahDarah = [];

  final DateTime now = DateTime.now();
  final DateFormat monthYearFormat = DateFormat.yMMMM('ID');
  final DateFormat tanggal = DateFormat.yMMMMd('ID');
  List<DateTime> days = [];
  final List<String> weekdays = [
    "Sen",
    "Sel",
    "Rab",
    "Kam",
    "Jum",
    "Sab",
    "Min"
  ];

  List<DateTime> _daysInMonth(int year, int month) {
    List<DateTime> days = [];
    DateTime firstDayOfMonth = DateTime(year, month, 1);
    DateTime lastDayOfMonth = DateTime(year, month + 1, 0);

    for (int i = 0; i < firstDayOfMonth.weekday - 1; i++) {
      days.add(DateTime(0, 0, 0)); // Fill with empty values for the first week
    }

    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      days.add(DateTime(year, month, day));
    }

    return days;
  }

  Future<void> getToken() async {
    try {
      var response = await http.post(
        Uri.parse(tokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'client_credentials',
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> tokenData = jsonDecode(response.body);
        accessToken = tokenData['access_token'];
        print('Token Akses: $accessToken');
      } else {
        print('Gagal mendapatkan token: ${response.statusCode}');
      }
    } catch (e) {
      print('Gagal mendapatkan token: $e');
    }
  }

  // Simulated database (replace with your actual database implementation)
  List _database = [];
  String ID = '';
  bool _isBelumMinum = true;

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');

    if (userDataString != null) {
      final userData = UserData.fromJson(json.decode(userDataString));
      print(userData.nama);

      setState(() {
        ID = userData.idUser.toString();
        fetchDataDarah();
      });
    }
  }

  Future<void> _saveDataToDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');

    if (userDataString != null) {
      print(userDataString);
      final userData = UserData.fromJson(json.decode(userDataString));
      print(userData.nama);

      setState(() {
        ID = userData.idUser.toString();
      });
    }
    print(ID);
    await getToken(); // Panggil getToken() untuk mendapatkan token akses

    final url = Uri.parse(base_url + 'api/Darah/darah');

    // Create a Map for the data to be sent
    final data = {
      "tanggal": currentDate,
      "id_user": ID,
      "status": 'sudah',
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
      body: data, // Konversi objek data ke dalam bentuk JSON
    );
    print('Res: ${response.statusCode}, ${response.body}');
    if (response.statusCode == 200) {
      fetchDataDarah();
      showPopup(context, "Berhasil",
          "Anda Sudah minum tablet tambah darah hari ini", null);
    } else {
      // Handle error here, e.g., show an error message to the user
      print('Error: ${response.statusCode}, ${response.body}');
    }
  }

  Future<void> fetchDataDarah() async {
    setState(() {
      isLoading = true;
    });
    final Uri uri =
        Uri.parse(base_url + 'api/Darah/tambahdarahall?id_user=$ID');
    final response = await http.get(uri);

    // print(response.body);

    arTambahDarah.clear();

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final responseList = jsonData['data'];

      int no = 0;
      setState(() {
        isLoading = false;
        var datenow = DateTime.now();
        var angkatgl = datenow.day.toString();
        var angkabln = datenow.month.toString();
        if (datenow.day < 10) {
          angkatgl = "0" + angkatgl.toString();
        }
        if (datenow.month < 10) {
          angkabln = "0" + angkabln.toString();
        }
        var tanggal = datenow.year.toString() + "-" + angkabln + "-" + angkatgl;
        responseList.forEach((element) {
          arTambahDarah.add(element['tanggal']);
        });
        if (arTambahDarah.contains(tanggal)) {
          _isBelumMinum = false;
        }
        print("Belum Minum" + tanggal.toString());
      });
    } else {
      print(response.body);
    }
    print(arTambahDarah);
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
    setState(() {
      days = _daysInMonth(now.year, now.month);
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      bottomNavigationBar: const BottomNavBar(selected: 4),
      backgroundColor: BackgroundColor,
      body: (isLoading)
          ? Center(
              child: Lottie.asset('assets/lottie/main_loading.json'),
            )
          : Stack(
              children: [
                SafeArea(
                  child: Container(
                    width: size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Tambah Darah Hari Ini',
                                      style: TextStyle(
                                        color: TextColordark,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(),
                                    ),
                                    Image.asset(
                                      'assets/images/calendar.png',
                                      width: 30.0,
                                      height: 30.0,
                                    ),
                                  ],
                                ),
                                // Tambahkan komponen UI lainnya di sini
                                SizedBox(
                                  height:
                                      20, // Tambahkan jarak antara teks dan Container
                                ),
                                if (!_isBelumMinum)
                                  Container(
                                    padding: EdgeInsets.all(
                                        16.0), // Padding pada Container
                                    decoration: BoxDecoration(
                                      color: Colors
                                          .white, // Warna latar belakang Container
                                      borderRadius: BorderRadius.circular(
                                          10.0), // Radius sudut sebesar 10
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(
                                              0.5), // Warna shadow abu-abu
                                          spreadRadius:
                                              5, // Seberapa jauh shadow menyebar
                                          blurRadius:
                                              7, // Tingkat keburaman shadow
                                          offset: Offset(0, 3), // Posisi shadow
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tanggal : ' + tanggal.format(now),
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          txtNama,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.deepOrange,
                                          ),
                                        ),
                                        Text(
                                          'Anda sudah minum tablet tambah darah hari ini',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (_isBelumMinum)
                                  Container(
                                    padding: EdgeInsets.all(
                                        16.0), // Padding pada Container
                                    decoration: BoxDecoration(
                                      color: Colors
                                          .white, // Warna latar belakang Container
                                      borderRadius: BorderRadius.circular(
                                          10.0), // Radius sudut sebesar 10
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(
                                              0.5), // Warna shadow abu-abu
                                          spreadRadius:
                                              5, // Seberapa jauh shadow menyebar
                                          blurRadius:
                                              7, // Tingkat keburaman shadow
                                          offset: Offset(0, 3), // Posisi shadow
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tanggal : ' + tanggal.format(now),
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          txtNama,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.deepOrange,
                                          ),
                                        ),
                                        Text(
                                          'Apakah anda sudah minum tablet tambah darah?',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                // Aksi saat tombol "Sudah" ditekan
                                                _saveDataToDatabase();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AccentColor,
                                              ),
                                              child: Text('SUDAH MINUM',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                SizedBox(
                                  height:
                                      32, // Tambahkan jarak antara teks dan Container
                                ),
                                Text("KALENDER TTD :",
                                    style: TextStyle(
                                        color: PrimaryColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                Center(
                                  child: Text(
                                    monthYearFormat.format(now).toUpperCase(),
                                    style: TextStyle(
                                      color: PrimaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    width: size.width * 0.9,
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 7, // 7 days in a week
                                      ),
                                      itemCount: weekdays.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Center(
                                          child: Text(
                                            weekdays[index],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    width: size.width * 0.9,
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 7, // 7 days in a week
                                      ),
                                      itemCount: days.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final DateTime day = days[index];
                                        final bool isToday = day.day == now.day;
                                        final bool isSelected =
                                            day.day == now.day;
                                        Color color_terpilih = WhiteColor;
                                        BoxShadow shadow_terpilih = boxShadow;

                                        if (isToday) {
                                          color_terpilih = AccentColor;
                                          shadow_terpilih = boxShadowAccent;
                                        }

                                        for (var i = 0;
                                            i < arTambahDarah.length;
                                            i++) {
                                          var tgl = arTambahDarah[i].toString();
                                          var tgl2 = tgl.split("-");
                                          var tgl3 = int.parse(tgl2[2])
                                                  .toString() +
                                              "-" +
                                              int.parse(tgl2[1]).toString() +
                                              "-" +
                                              int.parse(tgl2[0]).toString();
                                          var tgl_now = day.day.toString() +
                                              "-" +
                                              day.month.toString() +
                                              "-" +
                                              day.year.toString();
                                          if (tgl3 == tgl_now) {
                                            color_terpilih = PrimaryColor;
                                            shadow_terpilih = boxShadowPrimary;
                                          }
                                          // print(tgl3 + "==" + tgl_now);
                                        }

                                        return Container(
                                          margin: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: color_terpilih,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            boxShadow: [shadow_terpilih],
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                day.day.toString(),
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}
