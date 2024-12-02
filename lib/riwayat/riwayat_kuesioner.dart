import 'package:flutter/material.dart';
import 'package:monitoringobat/util/colors.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:monitoringobat/util/core.dart';
import 'package:lottie/lottie.dart';

class RiwayatKuesioner extends StatefulWidget {
  const RiwayatKuesioner({Key? key}) : super(key: key);

  @override
  State<RiwayatKuesioner> createState() => _RiwayatKuesionerState();
}

class _RiwayatKuesionerState extends State<RiwayatKuesioner> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> dataRiwayat = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRiwayat();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRiwayat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      
      if (userDataString == null) {
        throw Exception('Data user tidak ditemukan');
      }

      final userData = json.decode(userDataString);
      final userId = userData['id_user'];

      var uri = Uri.parse('${base_url}api/Question/riwayat')
          .replace(queryParameters: {'id_user': userId.toString()});
      
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
            dataRiwayat = List<Map<String, dynamic>>.from(jsonResponse['response']);
            _isLoading = false;
          });
        } else {
          setState(() {
            dataRiwayat = [];
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Gagal memuat data riwayat');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  Widget _buildRiwayatList(String tipe) {
    var filteredData = dataRiwayat.where((item) => item['tipe'] == tipe).toList();
    
    return filteredData.isEmpty
        ? Center(
            child: Text(
              'Belum ada riwayat kuesioner ${tipe == 'sebelum' ? 'sebelum' : 'sesudah'} menggunakan aplikasi',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: filteredData.length,
            itemBuilder: (context, index) {
              var item = filteredData[index];
              return Card(
                margin: EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ExpansionTile(
                  title: Text(
                    'Tanggal: ${DateFormat('dd MMMM yyyy').format(DateTime.parse(item['tanggal']))}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: (item['jawaban'] as List).length,
                      itemBuilder: (context, jawabanIndex) {
                        var jawaban = item['jawaban'][jawabanIndex];
                        return Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pertanyaan ${jawabanIndex + 1}:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                jawaban['pertanyaan'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Jawaban: ${jawaban['jawaban']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              if (jawabanIndex < (item['jawaban'] as List).length - 1)
                                Divider(height: 24),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Riwayat Kuesioner', 
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
          ),
          backgroundColor: PrimaryColor,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Container(
                  height: 80,
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sebelum', textAlign: TextAlign.center),
                      Text('Menggunakan Aplikasi', textAlign: TextAlign.center),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sesudah', textAlign: TextAlign.center),
                      Text('Menggunakan Aplikasi', textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Lottie.asset(
                'assets/lottie/main_loading.json',
                width: 200,
                height: 200,
              ),
            )
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bgmonevminumobatbaru.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRiwayatList('sebelum'),
                  _buildRiwayatList('sesudah'),
                ],
              ),
            ),
    );
  }
}
