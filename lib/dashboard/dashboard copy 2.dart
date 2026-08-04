// import 'dart:async';
// import 'dart:collection';
// import 'dart:convert';
// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:intl/intl.dart';
// import 'package:lottie/lottie.dart';
// import 'package:monitoringobat/FAQ/listfaq.dart';
// import 'package:monitoringobat/Kuisioner/Kuisioner_screen.dart';
// import 'package:monitoringobat/PedomanGizi/PdfPedomanGizi.dart';
// import 'package:monitoringobat/dashboard/baca_artikel.dart';
// import 'package:monitoringobat/util/colors.dart';
// import 'package:marquee/marquee.dart';
// import 'package:page_transition/page_transition.dart';
// import 'package:monitoringobat/Login/components/login_form.dart';
// import 'package:monitoringobat/bloc/nav/bottom_nav.dart';
// import 'package:monitoringobat/kalori/testingTotalKalori.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:monitoringobat/model/user.dart';

// import 'package:monitoringobat/tambahDarah/tambahDarah.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// import '../util/core.dart';

// class Dashboard extends StatefulWidget {
//   const Dashboard({Key? key}) : super(key: key);

//   @override
//   State<Dashboard> createState() => _DashboardState();
// }

// class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
//   Map<String, dynamic>? forIMT;
//   late AnimationController _animation_controller;
//   late Animation<double> _anim_tb;
//   late Animation<double> _anim_bb;
//   late Animation<double> _anim_umur;
//   late Animation<double> _anim_imt;

//   String imtText = '';
//   String KeteranganImtText = '';
//   bool _isBelumMinum = true;
//   List<dynamic> data = [];
//   List<dynamic> articles = [];
//   List<dynamic> arTambahDarah = [];
//   String Nama = '';
//   String Email = '';
//   var tinggiBadanCm = 0.0;
//   var beratBadanKg = 0.0;

//   String TB = '';
//   String BB = '';
//   String Id = '';
//   String umur = '0';

//   bool isLoaded = false;

//   late YoutubePlayerController _playercontroller;

//   final DateTime now = DateTime.now();
//   final DateFormat monthYearFormat = DateFormat.yMMMM('ID');
//   List<DateTime> days = [];
//   final List<String> weekdays = [
//     "Sen",
//     "Sel",
//     "Rab",
//     "Kam",
//     "Jum",
//     "Sab",
//     "Min"
//   ];

//   @override
//   void initState() {
//     super.initState();
//     setState(() {
//       days = _daysInMonth(now.year, now.month);
//     });
//     fetchVideo();
//     loadUserData();
//   }

//   @override
//   void dispose() {
//     _playercontroller.dispose();
//     super.dispose();
//   }

//   Future<void> loadUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userDataString = prefs.getString('user_data');

//     if (userDataString != null) {
//       final userData = UserData.fromJson(json.decode(userDataString));
//       // print(userData.nama);

//       setState(() {
//         Nama = userData.nama;
//         Email = userData.email;
//         TB = userData.tinggiBadan;
//         BB = userData.beratBadan;
//         Id = userData.idUser.toString();
//         umur = userData.umur;
//         _initializeAsyncOperations();
//       });
//     }
//   }

//   void processQueue(Queue<VoidCallback> queue) {
//     if (queue.isEmpty) {
//       return;
//     }

//     // Dequeue and run the first task
//     VoidCallback task = queue.removeFirst();
//     task();

//     // Schedule the next task
//     Future.delayed(Duration.zero, () => processQueue(queue));
//   }

//   Future<void> _initializeAsyncOperations() async {
//     // Initialize the AnimationController
//     _animation_controller = AnimationController(
//       duration: Duration(seconds: 2), // Set the duration of the animation
//       vsync: this,
//     );

//     // Initialize any async operations here
//     Queue<VoidCallback> taskQueue = Queue<VoidCallback>();
//     // Add tasks to the queue
//     taskQueue.add(() => fetchData());
//     taskQueue.add(() => fetchDataDarah());
//     taskQueue.add(() => fetchData2());
//     taskQueue.add(() => fetchData3());
//     taskQueue.add(() => finishLoading());
//     // Process the queue
//     processQueue(taskQueue);
//   }

//   Future<void> finishLoading() async {
//     // delay 2 seconds
//     await Future.delayed(Duration(seconds: 1));
//     setState(() {
//       isLoaded = false;

//       // Define the tween to animate from 0 to the target number
//       _anim_tb = Tween<double>(begin: 0, end: tinggiBadanCm)
//           .animate(_animation_controller)
//         ..addListener(() {
//           setState(() {});
//         });
//       _anim_bb = Tween<double>(begin: 0, end: beratBadanKg)
//           .animate(_animation_controller)
//         ..addListener(() {
//           setState(() {});
//         });
//       _anim_umur = Tween<double>(begin: 0, end: double.parse(umur))
//           .animate(_animation_controller)
//         ..addListener(() {
//           setState(() {});
//         });
//       // Start the animation
//       _animation_controller.forward();
//     });
//   }

//   Future<void> fetchDataDarah() async {
//     print("id :" + Id);
//     final Uri uri =
//         Uri.parse(base_url + 'api/Darah/tambahdarahall?id_user=$Id');
//     final response = await http.get(uri);

//     print(response.body);

//     arTambahDarah.clear();

//     if (response.statusCode == 200) {
//       final jsonData = json.decode(response.body);
//       final responseList = jsonData['data'];

//       int no = 0;
//       setState(() {
//         var datenow = DateTime.now();
//         var angkatgl = datenow.day.toString();
//         var angkabln = datenow.month.toString();
//         if (datenow.day < 10) {
//           angkatgl = "0" + angkatgl.toString();
//         }
//         if (datenow.month < 10) {
//           angkabln = "0" + angkabln.toString();
//         }
//         var tanggal = datenow.year.toString() + "-" + angkabln + "-" + angkatgl;
//         responseList.forEach((element) {
//           arTambahDarah.add(element['tanggal']);
//         });
//         if (arTambahDarah.contains(tanggal)) {
//           _isBelumMinum = false;
//         }
//         print("Belum Minum" + tanggal.toString());
//       });
//     } else {
//       print(response.body);
//     }
//     print(arTambahDarah);
//   }

//   Future<void> fetchVideo() async {
//     _playercontroller = YoutubePlayerController(
//       initialVideoId: 'C0vU-w-vqU0',
//       flags: YoutubePlayerFlags(
//         autoPlay: false,
//         mute: false,
//         hideControls: false,
//         loop: true,
//       ),
//     );
//     _playercontroller.addListener(() {
//       if (_playercontroller.value.hasError) {
//         print('Error: ${_playercontroller.value.errorCode}');
//       }
//     });
//   }

//   Future<void> fetchData3() async {
//     final response = await http.get(
//       Uri.parse(base_url + 'api/DataUser/DataUser?id_user=$Id'),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       forIMT = data['response'][0];

//       tinggiBadanCm = double.parse(forIMT!['tinggi_badan']);
//       beratBadanKg = double.parse(forIMT!['berat_badan']);

//       //update sharepref berat_badan
//       final prefs = await SharedPreferences.getInstance();
//       var userDataString = prefs.getString('user_data');
//       if (userDataString != null) {
//         final userData = UserData.fromJson(json.decode(userDataString));
//         userData.beratBadan = beratBadanKg.toString();
//         prefs.setString('user_data', json.encode(userData.toJson()));
//       }
//       setState(() {
//         BB = beratBadanKg.toString();
//       });

//       final tinggiBadanM = tinggiBadanCm / 100;
//       final imt = beratBadanKg / (tinggiBadanM * tinggiBadanM);

//       imtText = '${imt.toStringAsFixed(2)}';
//       double imtDouble = double.parse(imtText);
//       if (imtDouble < 17.0) {
//         KeteranganImtText = 'KURUS BERAT';
//       } else if (imtDouble >= 17.0 && imtDouble <= 18.4) {
//         KeteranganImtText = 'KURUS RINGAN';
//       } else if (imtDouble >= 18.5 && imtDouble <= 25.0) {
//         KeteranganImtText = 'NORMAL';
//       } else if (imtDouble >= 25.1 && imtDouble <= 27.0) {
//         KeteranganImtText = 'GEMUK RINGAN';
//       } else if (imtDouble >= 27.1) {
//         KeteranganImtText = 'GEMUK BERAT';
//       }
//     } else {
//       throw Exception('Failed to load data from API');
//     }
//   }

//   Future<void> fetchData2() async {
//     final Uri apiUrl = Uri.parse(base_url + 'api/Artikel/getArtikel');
//     final response = await http.get(apiUrl);

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       final List<dynamic> responseList = data['response'];
//       setState(() {
//         articles = responseList;
//       });
//     } else {
//       throw Exception('Failed to load data from API');
//     }
//   }

//   Future<void> fetchData() async {
//     final response =
//         await http.get(Uri.parse(base_url + 'api/Gambar/getgambar'));
//     if (response.statusCode == 200) {
//       setState(() {
//         data = json.decode(response.body)['response'];
//       });
//     }
//   }

//   Future<void> logoutUser() async {
//     // Hapus token akses dari Shared Preferences
//     final prefs = await SharedPreferences.getInstance();
//     prefs.remove('access_token');
//     prefs.remove('user_data'); // Jika ada data pengguna lain yang perlu dihapus

//     // Arahkan pengguna kembali ke halaman login
//     Navigator.of(context).pushAndRemoveUntil(
//       PageTransition(
//         child: LoginForm(),
//         type: PageTransitionType.fade,
//         duration: const Duration(milliseconds: 500),
//       ),
//       (route) => false, // Hapus seluruh riwayat navigasi
//     );
//   }

//   List<DateTime> _daysInMonth(int year, int month) {
//     List<DateTime> days = [];
//     DateTime firstDayOfMonth = DateTime(year, month, 1);
//     DateTime lastDayOfMonth = DateTime(year, month + 1, 0);

//     for (int i = 0; i < firstDayOfMonth.weekday - 1; i++) {
//       days.add(DateTime(0, 0, 0)); // Fill with empty values for the first week
//     }

//     for (int day = 1; day <= lastDayOfMonth.day; day++) {
//       days.add(DateTime(year, month, day));
//     }

//     return days;
//   }

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;

//     return Scaffold(
//       bottomNavigationBar: BottomNavBar(selected: 0),
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/images/bgmonevminumobatbaru.png'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: isLoaded
//           ? Center(
//               child: Lottie.asset('assets/lottie/main_loading.json'),
//             )
//           : ListView(
//               children: [
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Container(
//                   decoration: BoxDecoration(
//                     image: DecorationImage(
//                       image:
//                           AssetImage('assets/images/bgmonevminumobatbaru.png'),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   // height: 200.0,
//                   width: double.infinity,
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Container(
//                             margin: EdgeInsets.only(left: 24),
//                             child: Text(
//                               'Hi, ' + Nama + Id,
//                               style: TextStyle(
//                                 color: TextColordark,
//                                 fontSize: 32,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
//                   child: Container(
//                     height: 150,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Expanded(
//                           flex: 1,
//                           child: Container(
//                             margin: EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 8),
//                             decoration: BoxDecoration(
//                                 color: AccentColor,
//                                 borderRadius: BorderRadius.circular(15.0),
//                                 boxShadow: [boxShadowAccent]),
//                             child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.person,
//                                     color: TextColorLight,
//                                     size: 40,
//                                   ),
//                                   Text(
//                                     _anim_umur.value.toStringAsFixed(0) +
//                                         ' Tahun',
//                                     style: TextStyle(
//                                       color: TextColorLight,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                   Text(
//                                     'Umur\n',
//                                     style: TextStyle(
//                                       color: TextColorLight,
//                                       fontSize: 14,
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ]),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 1,
//                           child: Container(
//                             margin: EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 8),
//                             decoration: BoxDecoration(
//                                 color: AccentColor,
//                                 borderRadius: BorderRadius.circular(15.0),
//                                 boxShadow: [boxShadowAccent]),
//                             child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.height,
//                                     color: TextColorLight,
//                                     size: 40,
//                                   ),
//                                   Text(
//                                     _anim_tb.value.toStringAsFixed(0) + 'cm',
//                                     style: TextStyle(
//                                       color: TextColorLight,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                   Text(
//                                     'Tinggi Badan',
//                                     style: TextStyle(
//                                       color: TextColorLight,
//                                       fontSize: 14,
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ]),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
//                   child: Container(
//                     height: 150,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Expanded(
//                           flex: 1,
//                           child: Container(
//                             margin: EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 8),
//                             decoration: BoxDecoration(
//                                 color: AccentColor,
//                                 borderRadius: BorderRadius.circular(15.0),
//                                 boxShadow: [boxShadowAccent]),
//                             child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.monitor_weight_rounded,
//                                     color: TextColorLight,
//                                     size: 40,
//                                   ),
//                                   Text(
//                                     _anim_bb.value.toStringAsFixed(0) + 'kg',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                   Text(
//                                     'Berat Badan',
//                                     style: TextStyle(
//                                       color: TextColorLight,
//                                       fontSize: 14,
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ]),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 1,
//                           child: Container(
//                             margin: EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 8),
//                             decoration: BoxDecoration(
//                                 color: AccentColor,
//                                 borderRadius: BorderRadius.circular(15.0),
//                                 boxShadow: [boxShadowAccent]),
//                             child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.fitness_center_rounded,
//                                     color: TextColorLight,
//                                     size: 40,
//                                   ),
//                                   forIMT == null
//                                       ? CircularProgressIndicator()
//                                       : Text(
//                                           imtText,
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                   Text(
//                                     KeteranganImtText,
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                   Text(
//                                     'IMT\n',
//                                     style: TextStyle(
//                                       color: TextColorLight,
//                                       fontSize: 14,
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ]),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//                 GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => Kuisioner(),
//                         ),
//                       );
//                     },
//                     child: Container(
//                       margin: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 0, vertical: 10),
//                       decoration: BoxDecoration(
//                           color: PrimaryColor,
//                           borderRadius: BorderRadius.circular(15.0),
//                           boxShadow: [boxShadowPrimary]),
//                       child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.quiz_sharp,
//                               color: TextColorLight,
//                               size: 30,
//                             ),
//                             SizedBox(
//                               width: 10,
//                             ),
//                             Text(
//                               'ISI KUISIONER',
//                               style: TextStyle(
//                                 color: TextColorLight,
//                                 fontSize: 14,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ]),
//                     )),
//                 SizedBox(
//                   height: 16,
//                 ),
//                 Container(
//                     // height: 140,
//                     margin: EdgeInsets.symmetric(horizontal: 24),
//                     padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("KALENDER TTD :",
//                             style: TextStyle(
//                                 fontSize: 20, fontWeight: FontWeight.bold)),
//                         //nama bulan dan tahun
//                         if (_isBelumMinum)
//                           Container(
//                             height: 20,
//                             margin: EdgeInsets.symmetric(vertical: 4),
//                             child: Marquee(
//                               text:
//                                   'Anda belum minum obat hari ini, jangan lupa minum obat ya!',
//                               style: TextStyle(
//                                 color: PrimaryColor,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               scrollAxis: Axis.horizontal,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               blankSpace: 20.0,
//                               velocity: 100.0,
//                               pauseAfterRound: Duration(seconds: 1),
//                               startPadding: 10.0,
//                               accelerationDuration: Duration(seconds: 1),
//                               accelerationCurve: Curves.linear,
//                               decelerationDuration: Duration(milliseconds: 500),
//                               decelerationCurve: Curves.easeOut,
//                             ),
//                           ),
//                         Center(
//                           child: Text(
//                             monthYearFormat.format(now).toUpperCase(),
//                             style: TextStyle(
//                               color: PrimaryColor,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         Center(
//                           child: Container(
//                             width: size.width * 0.9,
//                             child: GridView.builder(
//                               shrinkWrap: true,
//                               physics: NeverScrollableScrollPhysics(),
//                               gridDelegate:
//                                   SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 7, // 7 days in a week
//                               ),
//                               itemCount: weekdays.length,
//                               itemBuilder: (BuildContext context, int index) {
//                                 return Center(
//                                   child: Text(
//                                     weekdays[index],
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                         Center(
//                           child: Container(
//                             width: size.width * 0.9,
//                             child: GridView.builder(
//                               shrinkWrap: true,
//                               physics: NeverScrollableScrollPhysics(),
//                               gridDelegate:
//                                   SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 7, // 7 days in a week
//                               ),
//                               itemCount: days.length,
//                               itemBuilder: (BuildContext context, int index) {
//                                 final DateTime day = days[index];
//                                 final bool isToday = day.day == now.day;
//                                 final bool isSelected = day.day == now.day;
//                                 Color color_terpilih = WhiteColor;
//                                 BoxShadow shadow_terpilih = boxShadow;

//                                 if (isToday) {
//                                   color_terpilih = AccentColor;
//                                   shadow_terpilih = boxShadowAccent;
//                                 }

//                                 for (var i = 0; i < arTambahDarah.length; i++) {
//                                   var tgl = arTambahDarah[i].toString();
//                                   var tgl2 = tgl.split("-");
//                                   var tgl3 = int.parse(tgl2[2]).toString() +
//                                       "-" +
//                                       int.parse(tgl2[1]).toString() +
//                                       "-" +
//                                       int.parse(tgl2[0]).toString();
//                                   var tgl_now = day.day.toString() +
//                                       "-" +
//                                       day.month.toString() +
//                                       "-" +
//                                       day.year.toString();
//                                   if (tgl3 == tgl_now) {
//                                     color_terpilih = PrimaryColor;
//                                     shadow_terpilih = boxShadowPrimary;
//                                   }
//                                   // print(tgl3 + "==" + tgl_now);
//                                 }

//                                 return Container(
//                                   margin: EdgeInsets.all(4),
//                                   decoration: BoxDecoration(
//                                     color: color_terpilih,
//                                     borderRadius: BorderRadius.circular(16),
//                                     boxShadow: [shadow_terpilih],
//                                   ),
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Text(
//                                         day.day.toString(),
//                                         style: TextStyle(
//                                           color: isSelected
//                                               ? Colors.white
//                                               : Colors.black,
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         )
//                       ],
//                     )),
//                 SizedBox(
//                   height: 16,
//                 ),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 24),
//                   child: Text(
//                     'VIDEO EDUKASI : ',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 Container(
//                     margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                     padding: EdgeInsets.all(4),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16.0),
//                       boxShadow: [boxShadow],
//                     ),
//                     child: YoutubePlayerBuilder(
//                       // YoutubePlayerBuilder
//                       player: YoutubePlayer(
//                         controller: _playercontroller,
//                         showVideoProgressIndicator: true,
//                         progressIndicatorColor: Colors.blueAccent,
//                         topActions: <Widget>[
//                           const SizedBox(width: 8.0),
//                           Expanded(
//                             child: Text(
//                               _playercontroller.metadata.title,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 18.0,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                               maxLines: 1,
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(
//                               Icons.settings,
//                               color: Colors.white,
//                               size: 25.0,
//                             ),
//                             onPressed: () {
//                               print('Settings Tapped!');
//                               _playercontroller.play();
//                             },
//                           ),
//                         ],
//                         onReady: () {
//                           print('Player is ready.');
//                         },
//                       ),
//                       builder: (context, player) {
//                         return Column(
//                           children: [
//                             // some widgets
//                             player,
//                             //some other widgets
//                           ],
//                         );
//                       },
//                     )),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 24),
//                   child: Text(
//                     'ARTIKER TERBARU : ',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   itemCount:
//                       articles.length, // Jumlah card yang ingin ditampilkan
//                   scrollDirection:
//                       Axis.vertical, // Untuk menggeser card ke samping
//                   itemBuilder: (BuildContext context, int index) {
//                     // Daftar warna gradient yang berbeda
//                     List<List<Color>> gradients = [
//                       [PrimaryColor, Colors.white],
//                       [SecondaryColor, Colors.white],
//                       [ThirdColor, Colors.white],
//                       [PrimaryColor, Colors.white],
//                       [SecondaryColor, Colors.white],
//                     ];

//                     return GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => BacaArtikel(
//                                 title: articles[index]['judul'],
//                                 description: articles[index]['konten'],
//                                 image: articles[index]['gambar_artikel']),
//                           ),
//                         );
//                       },
//                       child: Container(
//                           margin: EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 16),
//                           width: 250, // Lebar card
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(16.0),
//                             image: DecorationImage(
//                               image: NetworkImage(
//                                   articles[index]['gambar_artikel']),
//                               fit: BoxFit.cover,
//                             ),
//                             // boxShadow: [boxShadowPrimary],
//                           ),
//                           child: Container(
//                             padding: EdgeInsets.only(left: 8, right: 8),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(16.0),
//                               color: Colors.black.withOpacity(0.4),
//                               boxShadow: [boxShadow],
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               children: [
//                                 // Gambar dari asset
//                                 Expanded(
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.center,
//                                     children: [
//                                       Container(
//                                         alignment: Alignment.center,
//                                         child: Text(
//                                           articles[index][
//                                               'judul'], // Ganti dengan deskripsi yang sesuai
//                                           style: TextStyle(
//                                             color:
//                                                 TextColorLight, // Warna teks pada latar belakang gradient
//                                             fontSize: 16.0,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                       // Tambahkan widget lainnya di sini jika diperlukan
//                                     ],
//                                   ),
//                                 ),
//                                 SizedBox(
//                                     width: 10), // Spasi antara gambar dan judul
//                                 Container(
//                                   width: 90, // Lebar gambar
//                                   height: 90, // Tinggi gambar
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(24),
//                                     child: Image.network(
//                                       articles[index]['gambar_artikel'],
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           )),
//                     );
//                   },
//                 ),
//               ],
//             ), ),
//     ); 
//   }
// }
