import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:monitoringobat/FAQ/listfaq.dart';
import 'package:monitoringobat/Kuisioner/Kuisioner_screen.dart';
import 'package:monitoringobat/PedomanGizi/PdfPedomanGizi.dart';
import 'package:monitoringobat/dashboard/baca_artikel.dart';
import 'package:monitoringobat/util/colors.dart';
import 'package:marquee/marquee.dart';
import 'package:page_transition/page_transition.dart';
import 'package:monitoringobat/Login/components/login_form.dart';
import 'package:monitoringobat/bloc/nav/bottom_nav.dart';
import 'package:monitoringobat/kalori/testingTotalKalori.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:monitoringobat/model/user.dart';
import 'package:monitoringobat/profile/profile.dart';

import 'package:monitoringobat/tambahDarah/tambahDarah.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monitoringobat/dashboard/minum_obat.dart';

import '../util/core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monitoringobat/dashboard/upload_bukti_obat.dart';
import 'package:monitoringobat/model/video_edukasi.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  Map<String, dynamic>? forIMT;
  AnimationController? _animationController;
  Animation<double>? _anim_tb;
  Animation<double>? _anim_bb;
  Animation<double>? _anim_umur;
  Animation<double>? _anim_imt;

  String imtText = '';
  String KeteranganImtText = '';
  bool _isBelumMinum = true;
  List<dynamic> data = [];
  List<dynamic> articles = [];
  List<dynamic> arTambahDarah = [];
  String Nama = '';
  String Email = '';
  var tinggiBadanCm = 0.0;
  var beratBadanKg = 0.0;

  String TB = '';
  String BB = '';
  String Id = '';
  String umur = '0';

  bool isLoaded = false;

  YoutubePlayerController? _playercontroller;
  VideoEdukasi? _currentVideo;
  bool _isVideoLoaded = false;

  final DateTime now = DateTime.now();
  final DateFormat monthYearFormat = DateFormat.yMMMM('ID');
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

  DateTime _selectedDate = DateTime.now();

  bool _isFriday = false;
  bool _hasUploadedPhoto = false;

  List<dynamic> jadwalTerdekat = [];
  bool isLoadingJadwal = true;

  Map<String, List<dynamic>> jadwalPerTanggal = {};

  Future<void> checkUploadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    var userDataString = prefs.getString('user_data');
    var accessToken = prefs.getString('access_token');

    if (userDataString != null) {
      final userData = UserData.fromJson(json.decode(userDataString));
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      try {
        final response = await http.get(
          Uri.parse(
              '${base_url}api/BuktiObat/check_status?id_user=${userData.idUser}&tanggal=$today'),
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            _hasUploadedPhoto = data['has_uploaded'];
          });
        }
      } catch (e) {
        print('Error checking upload status: $e');
      }
    }
  }

  Future<void> fetchJadwalBulanan(int year, int month) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var userDataString = prefs.getString('user_data');
      var accessToken = prefs.getString('access_token');

      if (userDataString != null) {
        final userData = UserData.fromJson(json.decode(userDataString));
        final startDate = DateTime(year, month, 1);
        final endDate = DateTime(year, month + 1, 0);

        final response = await http.get(
          Uri.parse('${base_url}api/JadwalObat/jadwal_bulanan?' +
              'id_user=${userData.idUser}&' +
              'start_date=${DateFormat('yyyy-MM-dd').format(startDate)}&' +
              'end_date=${DateFormat('yyyy-MM-dd').format(endDate)}'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json',
          },
        );

        print('Response jadwal_bulanan: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['response'] != null) {
            setState(() {
              jadwalPerTanggal =
                  Map<String, List<dynamic>>.from(data['response']);
              // Urutkan jadwal per tanggal berdasarkan waktu
              jadwalPerTanggal.forEach((tanggal, jadwalList) {
                jadwalList.sort((a, b) => a['waktu'].compareTo(b['waktu']));
              });
              print('Jadwal bulanan loaded: ${jadwalPerTanggal.length} days');
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching jadwal bulanan: $e');
    }
  }

  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
      updateDays();
      fetchJadwalBulanan(_selectedDate.year, _selectedDate.month);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
      updateDays();
      fetchJadwalBulanan(_selectedDate.year, _selectedDate.month);
    });
  }

  @override
  void initState() {
    super.initState();
    _isFriday = DateTime.now().weekday == DateTime.friday;
    checkUploadStatus();
    setState(() {
      days = _daysInMonth(now.year, now.month);
    });
    fetchVideo();
    loadUserData();
    fetchJadwalTerdekat();
    Timer.periodic(Duration(minutes: 5), (Timer t) => fetchJadwalTerdekat());
    fetchJadwalBulanan(DateTime.now().year, DateTime.now().month);
    _getVideoEdukasi();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _playercontroller?.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');

    if (userDataString != null) {
      final userData = UserData.fromJson(json.decode(userDataString));
      // print(userData.nama);

      setState(() {
        Nama = userData.nama;
        Email = userData.email;
        TB = userData.tinggiBadan;
        BB = userData.beratBadan;
        Id = userData.idUser.toString();
        umur = userData.umur;
        _initializeAsyncOperations();
      });
    }
  }

  void processQueue(Queue<VoidCallback> queue) {
    if (queue.isEmpty) {
      return;
    }

    // Dequeue and run the first task
    VoidCallback task = queue.removeFirst();
    task();

    // Schedule the next task
    Future.delayed(Duration.zero, () => processQueue(queue));
  }

  Future<void> _initializeAsyncOperations() async {
    // Initialize the AnimationController
    _animationController = AnimationController(
      duration: Duration(seconds: 2), // Set the duration of the animation
      vsync: this,
    );

    // Initialize any async operations here
    Queue<VoidCallback> taskQueue = Queue<VoidCallback>();
    // Add tasks to the queue
    taskQueue.add(() => fetchData());
    taskQueue.add(() => fetchDataDarah());
    taskQueue.add(() => fetchData2());
    taskQueue.add(() => fetchData3());
    taskQueue.add(() => finishLoading());
    // Process the queue
    processQueue(taskQueue);
  }

  Future<void> finishLoading() async {
    // delay 2 seconds
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      isLoaded = false;

      // Define the tween to animate from 0 to the target number
      _anim_tb = Tween<double>(begin: 0, end: tinggiBadanCm)
          .animate(_animationController!)
        ..addListener(() {
          setState(() {});
        });
      _anim_bb = Tween<double>(begin: 0, end: beratBadanKg)
          .animate(_animationController!)
        ..addListener(() {
          setState(() {});
        });
      _anim_umur = Tween<double>(begin: 0, end: double.parse(umur))
          .animate(_animationController!)
        ..addListener(() {
          setState(() {});
        });
      // Start the animation
      _animationController!.forward();
    });
  }

  Future<void> fetchDataDarah() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var accessToken = prefs.getString('access_token');
      var id = prefs.getString('id_user');

      final response = await http.get(
        Uri.parse('${base_url}api/get_data_darah/$id'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['data'] != null) {
          setState(() {
            // Handle data
            var dataList = data['data'] as List;
            // Process dataList
          });
        } else {
          print('No data available');
        }
      }
    } catch (e) {
      print('Error fetching darah data: $e');
    }
  }

  Future<void> fetchVideo() async {
    _playercontroller = YoutubePlayerController(
      initialVideoId: 'C0vU-w-vqU0',
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        hideControls: false,
        loop: true,
      ),
    );
    _playercontroller!.addListener(() {
      if (_playercontroller!.value.hasError) {
        print('Error: ${_playercontroller!.value.errorCode}');
      }
    });
  }

  Future<void> fetchData3() async {
    final response = await http.get(
      Uri.parse(base_url + 'api/DataUser/DataUser?id_user=$Id'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      forIMT = data['response'][0];

      tinggiBadanCm = double.parse(forIMT!['tinggi_badan']);
      beratBadanKg = double.parse(forIMT!['berat_badan']);

      //update sharepref berat_badan
      final prefs = await SharedPreferences.getInstance();
      var userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        final userData = UserData.fromJson(json.decode(userDataString));
        userData.beratBadan = beratBadanKg.toString();
        prefs.setString('user_data', json.encode(userData.toJson()));
      }
      setState(() {
        BB = beratBadanKg.toString();
      });

      final tinggiBadanM = tinggiBadanCm / 100;
      final imt = beratBadanKg / (tinggiBadanM * tinggiBadanM);

      imtText = '${imt.toStringAsFixed(2)}';
      double imtDouble = double.parse(imtText);
      if (imtDouble < 17.0) {
        KeteranganImtText = 'KURUS BERAT';
      } else if (imtDouble >= 17.0 && imtDouble <= 18.4) {
        KeteranganImtText = 'KURUS RINGAN';
      } else if (imtDouble >= 18.5 && imtDouble <= 25.0) {
        KeteranganImtText = 'NORMAL';
      } else if (imtDouble >= 25.1 && imtDouble <= 27.0) {
        KeteranganImtText = 'GEMUK RINGAN';
      } else if (imtDouble >= 27.1) {
        KeteranganImtText = 'GEMUK BERAT';
      }
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  Future<void> fetchData2() async {
    final Uri apiUrl = Uri.parse(base_url + 'api/Artikel/getArtikel');
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> responseList = data['response'];
      setState(() {
        articles = responseList;
      });
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse(base_url + 'api/Gambar/getgambar'));
    if (response.statusCode == 200) {
      setState(() {
        data = json.decode(response.body)['response'];
      });
    }
  }

  Future<void> logoutUser() async {
    // Hapus token akses dari Shared Preferences
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('access_token');
    prefs.remove('user_data'); // Jika ada data pengguna lain yang perlu dihapus

    // Arahkan pengguna kembali ke halaman login
    Navigator.of(context).pushAndRemoveUntil(
      PageTransition(
        child: LoginForm(),
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 500),
      ),
      (route) => false, // Hapus seluruh riwayat navigasi
    );
  }

  List<DateTime> _daysInMonth(int year, int month) {
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);

    List<DateTime> days = [];
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      days.add(DateTime(year, month, day));
    }
    return days;
  }

  void updateDays() {
    setState(() {
      days = _daysInMonth(_selectedDate.year, _selectedDate.month);
    });
  }

  Future<void> _takePicture() async {
    if (_hasUploadedPhoto) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Anda sudah mengupload bukti foto hari ini'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadBuktiObat(
              imageFile: File(photo.path),
            ),
          ),
        );

        if (result == true) {
          setState(() {
            _hasUploadedPhoto = true;
          });
          checkUploadStatus();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto: $e')),
      );
    }
  }

  Future<List<dynamic>> getRiwayatUpload(String bulan) async {
    final prefs = await SharedPreferences.getInstance();
    var userDataString = prefs.getString('user_data');
    var accessToken = prefs.getString('access_token');

    if (userDataString != null) {
      final userData = UserData.fromJson(json.decode(userDataString));

      try {
        final response = await http.get(
          Uri.parse(
              '${base_url}api/BuktiObat/riwayat?id_user=${userData.idUser}&bulan=$bulan'),
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return data['data'];
        }
      } catch (e) {
        print('Error getting riwayat: $e');
      }
    }
    return [];
  }

  Future<void> fetchJadwalTerdekat() async {
    setState(() => isLoadingJadwal = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      var userDataString = prefs.getString('user_data');
      var accessToken = prefs.getString('access_token');

      if (userDataString != null) {
        final userData = UserData.fromJson(json.decode(userDataString));

        final response = await http.get(
          Uri.parse(
              '${base_url}api/JadwalObat/jadwal_terdekat?id_user=${userData.idUser}'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json',
          },
        );

        print('Response from jadwal_terdekat: ${response.body}'); // Debug print

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['message']['status'] == 200) {
            setState(() {
              // Gabungkan jadwal user dengan jadwal umum (id 89)
              jadwalTerdekat = data['response'];
              // Urutkan berdasarkan waktu
              jadwalTerdekat.sort((a, b) => a['waktu'].compareTo(b['waktu']));
              isLoadingJadwal = false;
            });
          } else {
            setState(() {
              jadwalTerdekat = [];
              isLoadingJadwal = false;
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching jadwal terdekat: $e');
      setState(() {
        jadwalTerdekat = [];
        isLoadingJadwal = false;
      });
    }
  }

  Future<void> _saveSelectedJadwal(Map<String, dynamic> jadwal) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Debug print untuk melihat data jadwal yang akan disimpan
      print('Data jadwal yang akan disimpan: $jadwal');

      // Simpan id_riwayat secara terpisah
      await prefs.setInt('selected_riwayat_id', jadwal['id_riwayat']);

      // Buat data jadwal lengkap
      final jadwalData = {
        'id_riwayat': jadwal['id_riwayat'],
        'id_jadwal': jadwal['id_jadwal'],
        'tanggal': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'nama_obat': jadwal['nama_obat'],
        'dosis': jadwal['dosis'],
        'satuan': jadwal['satuan'],
        'waktu': jadwal['waktu'],
      };

      // Simpan data jadwal lengkap
      await prefs.setString('selected_jadwal', json.encode(jadwalData));

      // Verifikasi data tersimpan
      final savedRiwayatId = prefs.getInt('selected_riwayat_id');
      final savedJadwal = prefs.getString('selected_jadwal');
      print('ID Riwayat tersimpan: $savedRiwayatId');
      print('Data jadwal tersimpan: $savedJadwal');
    } catch (e) {
      print('Error saat menyimpan jadwal: $e');
      throw e;
    }
  }

  void _showJadwalDetail(String tanggal, List<dynamic> jadwalList) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jadwal Minum Obat - ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.parse(tanggal))}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              ...jadwalList.map((jadwal) {
                return GestureDetector(
                  onTap: () async {
                    try {
                      print('Data jadwal yang akan disimpan: $jadwal');

                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt(
                          'selected_riwayat_id', jadwal['id_riwayat']);

                      // Debug print untuk verifikasi
                      print(
                          'ID Riwayat yang tersimpan: ${prefs.getInt('selected_riwayat_id')}');

                      // Ambil foto
                      // final ImagePicker _picker = ImagePicker();
                      // final XFile? photo = await _picker.pickImage(
                      //   source: ImageSource.camera,
                      //   preferredCameraDevice: CameraDevice.rear,
                      // );

                      // if (photo != null) {
                      //   Navigator.pop(context); // Tutup bottom sheet
                      //   await Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => UploadBuktiObat(
                      //         imageFile: File(photo.path),
                      //       ),
                      //     ),
                      //   );
                      // }
                    } catch (e) {
                      print('Error dalam proses: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Terjadi kesalahan: $e')),
                      );
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(jadwal['nama_obat']),
                              Text(
                                '${jadwal['dosis']} ${jadwal['satuan']} - ${jadwal['waktu']}',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                jadwal['status'],
                                style: TextStyle(
                                  color: jadwal['status'] == 'Terlewat'
                                      ? Colors.red
                                      : jadwal['status'] == 'Sudah diminum'
                                          ? Colors.green
                                          : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getVideoEdukasi() async {
    try {
      setState(() {
        _isVideoLoaded = false;
      });

      final prefs = await SharedPreferences.getInstance();
      var accessToken = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse('${base_url}api/VideoEdukasi/get_active_video'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          // Pastikan id_video dikonversi ke integer
          var videoData = data['data'];
          videoData['id_video'] = int.parse(videoData['id_video'].toString());

          setState(() {
            _currentVideo = VideoEdukasi.fromJson(videoData);
            _initializeYoutubePlayer();
          });
        } else {
          setState(() {
            _currentVideo = null;
            _isVideoLoaded = true;
          });
        }
      } else {
        print('Error response: ${response.body}');
        setState(() {
          _currentVideo = null;
          _isVideoLoaded = true;
        });
      }
    } catch (e) {
      print('Error getting video: $e');
      setState(() {
        _currentVideo = null;
        _isVideoLoaded = true;
      });
    }
  }

  void _initializeYoutubePlayer() {
    if (_currentVideo != null) {
      _playercontroller = YoutubePlayerController(
        initialVideoId: _currentVideo!.youtubeId,
        flags: YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          controlsVisibleAtStart: true,
        ),
      );
      setState(() {
        _isVideoLoaded = true;
      });
    } else {
      setState(() {
        _isVideoLoaded = true;
      });
    }
  }

  Widget _buildVideoSection() {
    if (!_isVideoLoaded) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_currentVideo == null || _playercontroller == null) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.video_library_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'Belum ada video edukasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Video edukasi akan ditampilkan di sini ketika tersedia',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.play_circle_outline,
                  color: Colors.blue,
                  size: 24,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentVideo!.judul,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_currentVideo!.deskripsi.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                _currentVideo!.deskripsi,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
            child: YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _playercontroller!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.blueAccent,
                progressColors: ProgressBarColors(
                  playedColor: Colors.blue,
                  handleColor: Colors.blueAccent,
                ),
                onReady: () {
                  print('Player is ready.');
                },
                onEnded: (data) {
                  _playercontroller?.seekTo(Duration.zero);
                },
              ),
              builder: (context, player) {
                return Column(
                  children: [player],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalItem(Map<String, dynamic> jadwal) {
    String statusText;
    Color statusColor;
    
    // Cek status dan tentukan text dan warna
    switch(jadwal['status'].toString().toLowerCase()) {
      case 'sudah':
        statusText = 'Kamu sudah minum obat ini';
        statusColor = Colors.green;
        break;
      case 'terlewat':
        statusText = 'Terlambat';
        statusColor = Colors.red;
        break;
      default:
        statusText = 'Kamu belum minum obat, tekan untuk minum obat';
        statusColor = Colors.orange;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/capsules.svg',
            width: 20,
            height: 20,
            color: PrimaryColor,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(jadwal['nama_obat'],
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${jadwal['dosis']} ${jadwal['satuan']}',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            jadwal['waktu'],
            style: TextStyle(
              color: PrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      bottomNavigationBar: BottomNavBar(selected: 0),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bgmonevminumobatbaru.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoaded
            ? Container(
                color: Colors.white,
                child: Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    child: Lottie.asset(
                      'assets/lottie/main_loading.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              )
            : ListView(
                children: [
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Profile()),
                                    );
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    margin: EdgeInsets.only(right: 12),
                                    child: SvgPicture.asset(
                                      'assets/icons/user.svg',
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Hi, ' + Nama,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'JADWAL MINUM OBAT',
                                style: TextStyle(
                                  color: PrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 10),
                              isLoadingJadwal
                                  ? Center(
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        child: Lottie.asset(
                                          'assets/lottie/main_loading.json',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    )
                                  : jadwalTerdekat.isEmpty
                                      ? Center(
                                          child: Text(
                                            'Tidak ada jadwal minum obat untuk hari ini',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        )
                                      : Column(
                                          children: [
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/icons/calendar-clock.svg',
                                                  width: 20,
                                                  height: 20,
                                                  color: Colors.grey,
                                                ),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    '${DateFormat('EEEE', 'id_ID').format(DateTime.now())}',
                                                    style: TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            ...jadwalTerdekat
                                                .map(
                                                    (jadwal) => GestureDetector(
                                                          onTap: () async {
                                                            if (jadwal['status']
                                                                    .toString()
                                                                    .toLowerCase() ==
                                                                'sudah') {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                      'Anda sudah minum obat ini'),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .green,
                                                                ),
                                                              );
                                                              return;
                                                            }

                                                            try {
                                                              // Konversi data ke format yang sesuai
                                                              final jadwalData =
                                                                  {
                                                                'id_riwayat': int
                                                                    .parse(jadwal[
                                                                            'id_riwayat']
                                                                        .toString()), // Konversi ke int
                                                                'id_jadwal': int
                                                                    .parse(jadwal[
                                                                            'id_jadwal']
                                                                        .toString()), // Konversi ke int
                                                                'nama_obat': jadwal[
                                                                    'nama_obat'],
                                                                'dosis': jadwal[
                                                                    'dosis'],
                                                                'satuan': jadwal[
                                                                    'satuan'],
                                                                'waktu': jadwal[
                                                                    'waktu'],
                                                                'tanggal': DateFormat(
                                                                        'yyyy-MM-dd')
                                                                    .format(DateTime
                                                                        .now()),
                                                              };

                                                              // Simpan data jadwal ke SharedPreferences
                                                              final prefs =
                                                                  await SharedPreferences
                                                                      .getInstance();
                                                              await prefs.setString(
                                                                  'selected_jadwal',
                                                                  json.encode(
                                                                      jadwalData));
                                                              await prefs.setInt(
                                                                  'selected_riwayat_id',
                                                                  int.parse(jadwal[
                                                                          'id_riwayat']
                                                                      .toString()));

                                                              // Navigate ke halaman MinumObat
                                                              final result =
                                                                  await Navigator
                                                                      .push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          MinumObat(),
                                                                ),
                                                              );

                                                              if (result ==
                                                                  true) {
                                                                await fetchJadwalTerdekat(); // Refresh jadwal setelah minum obat
                                                                await checkUploadStatus();
                                                              }
                                                            } catch (e) {
                                                              print(
                                                                  'Error processing jadwal: $e');
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                      'Terjadi kesalahan: ${e.toString()}'),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          child: _buildJadwalItem(jadwal),
                                                        ))
                                                .toList(),
                                          ],
                                        ),
                              SizedBox(height: 10),
                              // GestureDetector(
                              //   onTap: _takePicture,
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.end,
                              //     children: [
                              //       Column(
                              //         children: [
                              //           SvgPicture.asset(
                              //             'assets/icons/mode-portrait.svg',
                              //             width: 24,
                              //             height: 24,
                              //             color: PrimaryColor,
                              //           ),
                              //           SizedBox(height: 4),
                              //           Text(
                              //             'Buat Foto\nMinum Obat',
                              //             style: TextStyle(
                              //               color: PrimaryColor,
                              //               fontSize: 12,
                              //               fontWeight: FontWeight.bold,
                              //             ),
                              //             textAlign: TextAlign.center,
                              //           ),
                              //         ],
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 24),
                    padding: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: PrimaryColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.chevron_left,
                                          color: Colors.white),
                                      onPressed: _previousMonth,
                                    ),
                                    Text(
                                      DateFormat('MMMM yyyy')
                                          .format(_selectedDate)
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.chevron_right,
                                          color: Colors.white),
                                      onPressed: _nextMonth,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                color: Colors.white,
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 7,
                                    childAspectRatio: 1,
                                  ),
                                  itemCount: 7 +
                                      (6 *
                                          7), // Header hari + maksimum 6 minggu
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (index < 7) {
                                      return Center(
                                        child: Text(
                                          [
                                            'Min',
                                            'Sen',
                                            'Sel',
                                            'Rab',
                                            'Kam',
                                            'Jum',
                                            'Sab'
                                          ][index],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: PrimaryColor,
                                          ),
                                        ),
                                      );
                                    }

                                    final DateTime firstDayOfMonth = DateTime(
                                        _selectedDate.year,
                                        _selectedDate.month,
                                        1);
                                    final int daysBeforeFirstDay =
                                        firstDayOfMonth.weekday % 7;
                                    final int day =
                                        index - 6 - daysBeforeFirstDay;

                                    if (day < 1 ||
                                        day >
                                            DateTime(_selectedDate.year,
                                                    _selectedDate.month + 1, 0)
                                                .day) {
                                      return Container();
                                    }

                                    final String currentDate =
                                        DateFormat('yyyy-MM-dd').format(
                                            DateTime(_selectedDate.year,
                                                _selectedDate.month, day));

                                    final bool isToday =
                                        day == DateTime.now().day &&
                                            _selectedDate.year ==
                                                DateTime.now().year &&
                                            _selectedDate.month ==
                                                DateTime.now().month;
                                    final bool hasJadwal = jadwalPerTanggal
                                        .containsKey(currentDate);
                                    final bool hasTerlewat = hasJadwal &&
                                        jadwalPerTanggal[currentDate]!.any(
                                            (j) =>
                                                j['status']
                                                    .toString()
                                                    .toLowerCase() ==
                                                'terlewat');

                                    return GestureDetector(
                                      onTap: hasJadwal
                                          ? () {
                                              _showJadwalDetail(
                                                  currentDate,
                                                  jadwalPerTanggal[
                                                      currentDate]!);
                                            }
                                          : null,
                                      child: Container(
                                        margin: EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: isToday
                                              ? PrimaryColor
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              day.toString(),
                                              style: TextStyle(
                                                color: isToday
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontWeight: isToday
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            if (hasJadwal)
                                              SvgPicture.asset(
                                                hasTerlewat
                                                    ? 'assets/icons/capsules-terlewat.svg'
                                                    : jadwalPerTanggal[
                                                                currentDate]!
                                                            .any((j) =>
                                                                j['status']
                                                                    .toString()
                                                                    .toLowerCase() ==
                                                                'sudah')
                                                        ? 'assets/icons/capsules-sudah.svg'
                                                        : 'assets/icons/capsules.svg',
                                                width: 12,
                                                height: 12,
                                                color: hasTerlewat
                                                    ? Colors.red
                                                    : jadwalPerTanggal[
                                                                currentDate]!
                                                            .any((j) =>
                                                                j['status']
                                                                    .toString()
                                                                    .toLowerCase() ==
                                                                'sudah')
                                                        ? Colors.green
                                                        : Colors.grey,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'VIDEO EDUKASI : ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildVideoSection(),
                  SizedBox(
                    height: 10,
                  ),
                  // Container(
                  //   padding: EdgeInsets.symmetric(horizontal: 24),
                  //   child: Text(
                  //     'ARTIKEL TERBARU : ',
                  //     style: TextStyle(
                  //       fontSize: 20,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                  // ListView.builder(
                  //   shrinkWrap: true,
                  //   physics: NeverScrollableScrollPhysics(),
                  //   itemCount:
                  //       articles.length, // Jumlah card yang ingin ditampilkan
                  //   scrollDirection:
                  //       Axis.vertical, // Untuk menggeser card ke samping
                  //   itemBuilder: (BuildContext context, int index) {
                  //     // Daftar warna gradient yang berbeda
                  //     List<List<Color>> gradients = [
                  //       [PrimaryColor, Colors.white],
                  //       [SecondaryColor, Colors.white],
                  //       [ThirdColor, Colors.white],
                  //       [PrimaryColor, Colors.white],
                  //       [SecondaryColor, Colors.white],
                  //     ];

                  //     return GestureDetector(
                  //       onTap: () {
                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //             builder: (context) => BacaArtikel(
                  //                 title: articles[index]['judul'],
                  //                 description: articles[index]['konten'],
                  //                 image: articles[index]['gambar_artikel']),
                  //           ),
                  //         );
                  //       },
                  //       child: Container(
                  //           margin: EdgeInsets.symmetric(
                  //               horizontal: 16, vertical: 16),
                  //           width: 250, // Lebar card
                  //           decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(16.0),
                  //             image: DecorationImage(
                  //               image: NetworkImage(
                  //                   articles[index]['gambar_artikel']),
                  //               fit: BoxFit.cover,
                  //             ),
                  //             // boxShadow: [boxShadowPrimary],
                  //           ),
                  //           child: Container(
                  //             padding: EdgeInsets.only(left: 8, right: 8),
                  //             decoration: BoxDecoration(
                  //               borderRadius: BorderRadius.circular(16.0),
                  //               color: Colors.black.withOpacity(0.4),
                  //               boxShadow: [boxShadow],
                  //             ),
                  //             child: Row(
                  //               mainAxisAlignment: MainAxisAlignment.start,
                  //               children: [
                  //                 // Gambar dari asset
                  //                 Expanded(
                  //                   child: Column(
                  //                     mainAxisAlignment:
                  //                         MainAxisAlignment.center,
                  //                     crossAxisAlignment:
                  //                         CrossAxisAlignment.center,
                  //                     children: [
                  //                       Container(
                  //                         alignment: Alignment.center,
                  //                         child: Text(
                  //                           articles[index][
                  //                               'judul'], // Ganti dengan deskripsi yang sesuai
                  //                           style: TextStyle(
                  //                             color:
                  //                                 TextColorLight, // Warna teks pada latar belakang gradient
                  //                             fontSize: 16.0,
                  //                             fontWeight: FontWeight.bold,
                  //                           ),
                  //                           textAlign: TextAlign.center,
                  //                         ),
                  //                       ),
                  //                       // Tambahkan widget lainnya di sini jika diperlukan
                  //                     ],
                  //                   ),
                  //                 ),
                  //                 SizedBox(
                  //                     width:
                  //                         10), // Spasi antara gambar dan judul
                  //                 Container(
                  //                   width: 90, // Lebar gambar
                  //                   height: 90, // Tinggi gambar
                  //                   child: ClipRRect(
                  //                     borderRadius: BorderRadius.circular(24),
                  //                     child: Image.network(
                  //                       articles[index]['gambar_artikel'],
                  //                       fit: BoxFit.cover,
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           )),
                  //     );
                  //   },
                  // ),
                ],
              ),
      ),
    );
  }
}
