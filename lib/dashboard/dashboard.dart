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
import 'package:monitoringobat/dashboard/video_player_screen.dart';
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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monitoringobat/dashboard/minum_obat.dart';
import 'package:url_launcher/url_launcher.dart';

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

  String? _extractYoutubeId(String raw) {
    if (raw.isEmpty) return null;

    final idPattern = RegExp(r'^[a-zA-Z0-9_-]{11}$');
    if (idPattern.hasMatch(raw)) return raw;

    final patterns = [
      RegExp(
          r'(?:youtube\.com\/watch\?v=|youtube\.com\/embed\/|youtu\.be\/|youtube\.com\/shorts\/)([a-zA-Z0-9_-]{11})'),
    ];
    for (final p in patterns) {
      final match = p.firstMatch(raw);
      if (match != null) return match.group(1);
    }
    return null;
  }

  String _greetingByTime() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat Pagi';
    if (hour >= 11 && hour < 15) return 'Selamat Siang';
    if (hour >= 15 && hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

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
      _selectedDate =
          DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
      updateDays();
      fetchJadwalBulanan(_selectedDate.year, _selectedDate.month);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedDate =
          DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
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
    loadUserData();
    fetchJadwalTerdekat();
    Timer.periodic(Duration(minutes: 5), (Timer t) => fetchJadwalTerdekat());
    fetchJadwalBulanan(DateTime.now().year, DateTime.now().month);
    _getVideoEdukasi();
  }

  @override
  void dispose() {
    _animationController?.dispose();
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
      final XFile? photo =
          await _picker.pickImage(source: ImageSource.camera);
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

        print(
            'Response from jadwal_terdekat: ${response.body}'); // Debug print

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

  // ==========================================================
  // VIDEO EDUKASI: fetch metadata saja.
  // Pemutaran video dipindah ke VideoPlayerScreen (full-screen),
  // sehingga di sini tidak perlu inisialisasi WebView / cek error
  // sebelum menampilkan thumbnail.
  // ==========================================================
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
            _isVideoLoaded = true;
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

  // ==========================================================
  // WIDGET: VIDEO EDUKASI
  // Selalu menampilkan thumbnail + tombol play. Tidak pernah
  // menampilkan pesan error di kartu ini — jika video gagal
  // dimuat, itu ditangani di dalam VideoPlayerScreen setelah
  // user menekan tombol play.
  // ==========================================================
  Widget _buildVideoSection() {
    if (!_isVideoLoaded) {
      return _videoCardWrapper(
        child: Padding(
          padding: EdgeInsets.all(32),
          child:
              Center(child: CircularProgressIndicator(color: PrimaryColor)),
        ),
      );
    }

    final String? videoId = _currentVideo != null
        ? _extractYoutubeId(_currentVideo!.youtubeId)
        : null;

    // Belum ada video sama sekali, atau id video tidak valid
    if (_currentVideo == null || videoId == null) {
      return _videoCardWrapper(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.video_library_outlined,
                  size: 64, color: Colors.grey[400]),
              SizedBox(height: 12),
              Text(
                'Belum ada video edukasi',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700]),
              ),
              SizedBox(height: 6),
              Text(
                'Video edukasi akan ditampilkan di sini ketika tersedia',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

    return _videoCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(
                    videoId: videoId,
                    title: _currentVideo!.judul,
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(Icons.image_not_supported_outlined,
                            color: Colors.grey.shade400, size: 40),
                      ),
                    ),
                    Container(color: Colors.black.withOpacity(0.25)),
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(Icons.play_arrow_rounded,
                            color: PrimaryColor, size: 40),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_circle_outline,
                                color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text('Putar',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: PrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.play_circle_fill,
                          color: PrimaryColor, size: 20),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _currentVideo!.judul,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            height: 1.3),
                      ),
                    ),
                  ],
                ),
                if (_currentVideo!.deskripsi.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text(
                    _currentVideo!.deskripsi,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey[600], height: 1.4),
                  ),
                ],
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.play_arrow_rounded,
                        size: 14, color: PrimaryColor),
                    SizedBox(width: 4),
                    Text(
                      'Tap untuk memutar video',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: PrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoCardWrapper({required Widget child}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // ==========================================================
  // WIDGET: HEADER / SAMBUTAN
  // ==========================================================
  Widget _buildHeaderGreeting() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PrimaryColor,
            PrimaryColor.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: PrimaryColor.withOpacity(0.25),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile()),
              );
            },
            child: Container(
              width: 56,
              height: 56,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.5)),
              ),
              child: SvgPicture.asset(
                'assets/icons/user.svg',
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greetingByTime(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  Nama.isNotEmpty ? Nama : '...',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                      .format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_none_rounded,
                color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // WIDGET: CARD JADWAL MINUM OBAT
  // ==========================================================
  Widget _buildJadwalCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  'assets/icons/capsules.svg',
                  width: 18,
                  height: 18,
                  color: PrimaryColor,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Jadwal Minum Obat',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  DateFormat('EEEE', 'id_ID').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          isLoadingJadwal
              ? Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    child: Lottie.asset(
                      'assets/lottie/main_loading.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              : jadwalTerdekat.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.event_available_outlined,
                              color: Colors.grey.shade400, size: 36),
                          SizedBox(height: 8),
                          Text(
                            'Tidak ada jadwal minum obat untuk hari ini',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: jadwalTerdekat
                          .map<Widget>(
                            (jadwal) => GestureDetector(
                              onTap: () async {
                                if (jadwal['status']
                                        .toString()
                                        .toLowerCase() ==
                                    'sudah') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Anda sudah minum obat ini'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  return;
                                }

                                try {
                                  final jadwalData = {
                                    'id_riwayat': int.parse(
                                        jadwal['id_riwayat'].toString()),
                                    'id_jadwal': int.parse(
                                        jadwal['id_jadwal'].toString()),
                                    'nama_obat': jadwal['nama_obat'],
                                    'dosis': jadwal['dosis'],
                                    'satuan': jadwal['satuan'],
                                    'waktu': jadwal['waktu'],
                                    'tanggal': DateFormat('yyyy-MM-dd')
                                        .format(DateTime.now()),
                                  };

                                  final prefs = await SharedPreferences
                                      .getInstance();
                                  await prefs.setString('selected_jadwal',
                                      json.encode(jadwalData));
                                  await prefs.setInt(
                                      'selected_riwayat_id',
                                      int.parse(
                                          jadwal['id_riwayat'].toString()));

                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MinumObat(),
                                    ),
                                  );

                                  if (result == true) {
                                    await fetchJadwalTerdekat();
                                    await checkUploadStatus();
                                  }
                                } catch (e) {
                                  print('Error processing jadwal: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Terjadi kesalahan: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              child: _buildJadwalItem(jadwal),
                            ),
                          )
                          .toList(),
                    ),
        ],
      ),
    );
  }

  Widget _buildJadwalItem(Map<String, dynamic> jadwal) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (jadwal['status'].toString().toLowerCase()) {
      case 'sudah':
        statusText = 'Sudah diminum';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'terlewat':
        statusText = 'Terlambat';
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusText = 'Tekan untuk minum obat';
        statusColor = Colors.orange;
        statusIcon = Icons.radio_button_unchecked;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.06),
        border: Border.all(color: statusColor.withOpacity(0.25)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/capsules.svg',
                width: 18,
                height: 18,
                color: PrimaryColor,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jadwal['nama_obat'],
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87),
                ),
                SizedBox(height: 2),
                Text(
                  '${jadwal['dosis']} ${jadwal['satuan']}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 13),
                    SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: PrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              jadwal['waktu'],
              style: TextStyle(
                color: PrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
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
          color: Color(0xFFF5F6FA),
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
                padding: EdgeInsets.zero,
                children: [
                  _buildHeaderGreeting(),
                  SizedBox(height: 20),
                  _buildJadwalCard(),
                  SizedBox(height: 16),
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
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: PrimaryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Video Edukasi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildVideoSection(),
                  SizedBox(height: 24),
                ],
              ),
      ),
    );
  }
}