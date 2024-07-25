import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:monitoringobat/util/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../bloc/nav/bottom_nav.dart';
import '../model/user.dart';
import '../resources/app_resources.dart';
import '../util/core.dart';
import 'TambahBB.dart';

class BeratBadan extends StatefulWidget {
  const BeratBadan({super.key});

  @override
  State<BeratBadan> createState() => _BeratBadanState();
}

class _BeratBadanState extends State<BeratBadan> {
  bool isLoading = true;
  List<Color> gradientColors = [
    SecondaryColor,
    AccentColor,
  ];
  List<Color> gradientColorsHB = [
    SecondaryColor,
    PrimaryColor,
  ];
  String Id = "";
  DateTime startDate =
      DateTime.now().subtract(const Duration(days: 30)); // 7 hari terakhir
  DateTime endDate = DateTime.now();

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');

    if (userDataString != null) {
      final userData = UserData.fromJson(json.decode(userDataString));
      print(userData.nama);

      setState(() {
        Id = userData.idUser.toString();
        fetchData();
      });
    }
  }

  List<FlSpot> arBeratBadan = [];
  List<FlSpot> arHb = [];
  List LabelData = [];

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    String start = DateFormat('yyyy-MM-dd').format(startDate);
    String end = DateFormat('yyyy-MM-dd').format(endDate);
    if (Id.isEmpty) {
      // Pastikan Id tidak kosong sebelum membuat permintaan http
      return;
    }

    arBeratBadan = [];

    print(Id);
    String fetkal = base_url +
        "api/BeratBadan/getBeratBadan?id_user=$Id&start=$start&end=$end'";
    final response = await http.get(
      Uri.parse(fetkal),
    );

    // print("Response BeratBedan:");
    // print(fetkal);
    // print(response.body);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // print(jsonResponse);
      setState(() {
        isLoading = false;
        var data = jsonResponse['response']['dataGraf'];
        LabelData = jsonResponse['response']['dataLabel'];
        for (var i = 0; i < data.length; i++) {
          if (data[i]['bb'] > 0) {
            arBeratBadan.add(FlSpot(i.toDouble(), double.parse(data[i]['bb'])));
          }
          if (data[i]['hb'] > 0) {
            arHb.add(FlSpot(i.toDouble(), double.parse(data[i]['hb'])));
          }
        }
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load data');
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
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
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
      fetchData();
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BERAT BADAN & HB',
          style: TextStyle(
            color: TextColordark,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selected: 5),
      body: (isLoading)
          ? Center(
              child: Lottie.asset('assets/lottie/main_loading.json'),
            )
          : Container(
              margin: EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 16,
                  ),
                  Text("Grafik Berat Badan dan HB Anda",
                      style: TextStyle(
                        color: TextColordark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      )),
                  Container(
                      padding: EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          boxShadow,
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                        "Start Date: ${DateFormat('yyyy-MM-dd').format(startDate)}"),
                                    TextButton(
                                      onPressed: () =>
                                          _selectStartDate(context),
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                AccentColor),
                                      ),
                                      child: Text("Select Start Date",
                                          style: TextStyle(color: WhiteColor)),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                        "End Date: ${DateFormat('dd-MM-yyyy').format(endDate)}"),
                                    ElevatedButton(
                                      onPressed: () => _selectEndDate(context),
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                AccentColor),
                                      ),
                                      child: const Text("Select End Date",
                                          style: TextStyle(color: WhiteColor)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Text("Grafik Berat Badan Anda",
                              style: TextStyle(
                                color: TextColordark,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              )),
                          AspectRatio(
                            aspectRatio: 2.1,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 0, right: 24, top: 16, bottom: 8),
                              child: LineChart(
                                mainData(),
                              ),
                            ),
                          ),
                          Text("Grafik HB Anda",
                              style: TextStyle(
                                color: TextColordark,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              )),
                          AspectRatio(
                            aspectRatio: 2.5,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 0, right: 24, top: 16, bottom: 8),
                              child: LineChart(
                                HBGrafik(),
                              ),
                            ),
                          ),
                        ],
                      )),
                  SizedBox(
                    height: 24,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TambahBB(),
                          ));
                    },
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          boxShadow,
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.topLeft,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            child: SizedBox(
                              height: 90,
                              child: AspectRatio(
                                aspectRatio: 1.714,
                                child: Image.asset("assets/images/back.png"),
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 110,
                                      right: 16,
                                      top: 29,
                                    ),
                                    child: Text(
                                      "Berapa BB dan HB Kamu Hari Ini ?",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        letterSpacing: 0.0,
                                        color: PrimaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 110,
                                  bottom: 12,
                                  top: 4,
                                  right: 16,
                                ),
                                child: Text(
                                  "Tambah Berat Badan dan HB\nSimpan riwayat berat badan Anda untuk Analisa!",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                    letterSpacing: 0.0,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                              ),
                              // Button tambah darah
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 16),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    TambahBB(),
                                              ));
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  PrimaryColor),
                                        ),
                                        child: Text("Tambah Data",
                                            style:
                                                TextStyle(color: WhiteColor)),
                                      ),
                                    ),
                                  ]),
                            ],
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            child: SizedBox(
                              width: 130,
                              height: 170,
                              child: Image.asset("assets/images/runner.png"),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              )),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 11,
    );
    String label = (!LabelData.isEmpty) ? LabelData[value.toInt()] : "";
    Widget text;
    text = Text(
      label,
      style: style,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      minY: 0,
      maxY: 150,
      lineBarsData: [
        LineChartBarData(
          spots: arBeratBadan,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData HBGrafik() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      minY: 0,
      maxY: 30,
      lineBarsData: [
        LineChartBarData(
          spots: arHb,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColorsHB,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColorsHB
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
