import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:monitoringobat/bloc/nav/bottom_nav.dart';
import 'package:monitoringobat/util/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:monitoringobat/model/user.dart';
import 'dart:math';
import 'package:monitoringobat/util/core.dart';
import 'package:lottie/lottie.dart';

class RiwayatBBHB extends StatefulWidget {
  const RiwayatBBHB({Key? key}) : super(key: key);

  @override
  State<RiwayatBBHB> createState() => _RiwayatBBHBState();
}

class _RiwayatBBHBState extends State<RiwayatBBHB> {
  List<dynamic> dataRiwayat = [];
  List<dynamic> resGraf = [];
  Map<String, dynamic> dataMax = {};
  String idUser = '';
  DateTime startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime endDate = DateTime.now();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        final userData = UserData.fromJson(json.decode(userDataString));
        setState(() {
          idUser = userData.idUser.toString();
        });
        await fetchData();
      }
    } catch (e) {
      print('Error loading user data: $e');
      showErrorMessage('Gagal memuat data pengguna');
    }
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      String start = DateFormat('yyyy-MM-dd').format(startDate);
      String end = DateFormat('yyyy-MM-dd').format(endDate);
      
      final Uri uri = Uri.parse('${base_url}api/LaporanBBTBHB/riwayat?id_user=$idUser&start=$start&end=$end');
      
      final response = await http.get(uri);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['message']['status'] == 200) {
          setState(() {
            dataRiwayat = jsonData['response'];
            
            // Format data untuk grafik
            resGraf = dataRiwayat.map((item) {
              return {
                "tanggal": DateFormat('dd-MMM').format(DateTime.parse(item['tanggal'])),
                "bb": double.parse(item['berat_badan'].toString()),
                "tb": double.parse(item['tinggi_badan'].toString()),
                "hb": double.parse(item['hemoglobin'].toString()),
              };
            }).toList();

            // Mencari nilai maksimum
            double maxBB = 0, maxTB = 0, maxHB = 0;
            for (var item in dataRiwayat) {
              maxBB = max(maxBB, double.parse(item['berat_badan'].toString()));
              maxTB = max(maxTB, double.parse(item['tinggi_badan'].toString()));
              maxHB = max(maxHB, double.parse(item['hemoglobin'].toString()));
            }
            
            dataMax = {
              "bb": maxBB,
              "tb": maxTB,
              "hb": maxHB,
            };
          });
        } else if (jsonData['message']['status'] == 204) {
          setState(() {
            dataRiwayat = [];
            resGraf = [];
            dataMax = {"bb": 0, "tb": 0, "hb": 0};
          });
          showErrorMessage('Belum ada data riwayat');
        }
      } else {
        throw Exception('Gagal memuat data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      showErrorMessage('Gagal memuat data riwayat');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2000),
      lastDate: endDate,
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
      fetchData();
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: startDate,
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
      fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat BB, TB dan Hb', 
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
        ),
        backgroundColor: PrimaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bgmonevminumobatbaru.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoading
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
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateRangePicker(),
                    SizedBox(height: 20),
                    if (dataRiwayat.isNotEmpty) _buildChart(),
                    SizedBox(height: 20),
                    _buildRiwayatList(),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _selectStartDate(context),
            child: Text('Dari: ${DateFormat('dd/MM/yyyy').format(startDate)}'),
            style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 10),backgroundColor: Colors.white, foregroundColor: PrimaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _selectEndDate(context),
            child: Text('Sampai: ${DateFormat('dd/MM/yyyy').format(endDate)}'),
            style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 10),backgroundColor: Colors.white, foregroundColor: PrimaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    List<FlSpot> bbSpots = [];
    List<FlSpot> hbSpots = [];
    List<FlSpot> tbSpots = [];

    for (int i = 0; i < resGraf.length; i++) {
      bbSpots.add(FlSpot(i.toDouble(), (resGraf[i]['bb'] as num).toDouble()));
      hbSpots.add(FlSpot(i.toDouble(), (resGraf[i]['hb'] as num).toDouble()));
      tbSpots.add(FlSpot(i.toDouble(), (resGraf[i]['tb'] as num).toDouble()));
    }

    // Menentukan nilai minimum dan maksimum untuk sumbu Y
    double minY = 0; // Mulai dari 0
    double maxY = [dataMax['bb'], dataMax['hb'], dataMax['tb']]
        .reduce((curr, next) => curr > next ? curr : next)
        .toDouble();
    maxY = (maxY / 10).ceil() * 10.0; // Pembulatan ke atas ke kelipatan 10

    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'Grafik BB, TB & Hb',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 10,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: 9),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < resGraf.length && index % 2 == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              resGraf[index]['tanggal'],
                              style: TextStyle(fontSize: 9),
                            ),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: bbSpots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: hbSpots,
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: tbSpots,
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                minX: 0,
                maxX: resGraf.length.toDouble() - 1,
                minY: minY,
                maxY: maxY,
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('BB', Colors.blue),
              SizedBox(width: 16),
              _buildLegendItem('TB', Colors.green),
              SizedBox(width: 16),
              _buildLegendItem('HB', Colors.red),
              
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildRiwayatList() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Riwayat BB, TB & Hb',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          dataRiwayat.isEmpty
              ? Text('Tidak ada data riwayat', style: TextStyle(fontSize: 12, color: Colors.black))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: dataRiwayat.length,
                  itemBuilder: (context, index) {
                    var item = dataRiwayat[index];
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tanggal: ${item['tanggal']}',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Berat Badan:',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  Text(
                                    '${item['berat_badan']} kg',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tinggi Badan:',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  Text(
                                    '${item['tinggi_badan']} cm',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Hemoglobin:',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  Text(
                                    '${item['hemoglobin']} g/dL',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
