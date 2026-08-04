import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:monitoringobat/Auth/firebase.dart';
import 'package:monitoringobat/BeratBadan/BeratBadan.dart';
import 'package:monitoringobat/Login/login_screen.dart';
import 'package:monitoringobat/bloc/nav/nav_bloc.dart';
import 'package:monitoringobat/dashboard/dashboard.dart';
import 'package:monitoringobat/kalori/kalori.dart';

import 'package:monitoringobat/model/provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:monitoringobat/tambahDarah/tambahDarah.dart';
import 'package:monitoringobat/util/colors.dart';

import 'package:page_transition/page_transition.dart';

import 'package:monitoringobat/profile/profile.dart';
import 'package:monitoringobat/riwayat/riwayat.dart';
import 'package:provider/provider.dart';
import 'package:monitoringobat/menu/menu_page.dart';
import 'package:monitoringobat/Kuisioner/kuesioner_page.dart';
import 'package:monitoringobat/artikel/artikel.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:monitoringobat/util/notification_service.dart';
import 'package:http/http.dart' as http;
// import 'package:monitoringobat/util/constant.dart';
import '../util/core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:monitoringobat/util/alarm_service.dart';
import 'dart:io';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:monitoringobat/util/article_notification_service.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 200,
          height: 200,
          child: Lottie.asset(
            'assets/lottie/main_loading.json',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

Future<void> _requestPermissions() async {
  print('=== MEMINTA IZIN APLIKASI ===');

  if (Platform.isAndroid) {
    try {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      print('Android SDK Version: ${deviceInfo.version.sdkInt}');

      // Daftar izin yang akan diminta
      final permissions = <Permission>[];

      // Izin notifikasi untuk Android 13+
      if (deviceInfo.version.sdkInt >= 33) {
        permissions.add(Permission.notification);
      }

      // Izin battery optimization
      if (await Permission.ignoreBatteryOptimizations.status.isDenied) {
        final batteryStatus =
            await Permission.ignoreBatteryOptimizations.request();
        print(
            'Izin battery optimization: ${batteryStatus.isGranted ? "Diberikan" : "Ditolak"}');
      }

      // Izin system alert window
      if (await Permission.systemAlertWindow.status.isDenied) {
        final alertStatus = await Permission.systemAlertWindow.request();
        print(
            'Izin system alert window: ${alertStatus.isGranted ? "Diberikan" : "Ditolak"}');
      }

      // Izin exact alarm untuk Android 12+
      if (deviceInfo.version.sdkInt >= 31) {
        if (await Permission.scheduleExactAlarm.status.isDenied) {
          final granted = await Permission.scheduleExactAlarm.request();
          print(
              'Izin exact alarm: ${granted.isGranted ? "Diberikan" : "Ditolak"}');
        }
      }

      // Request semua izin yang terkumpul
      if (permissions.isNotEmpty) {
        final statuses = await permissions.request();
        statuses.forEach((permission, status) {
          print(
              'Izin ${permission.toString()}: ${status.isGranted ? "Diberikan" : "Ditolak"}');
        });
      }
    } catch (e, stackTrace) {
      print('Error dalam meminta izin: $e');
      print('Stack trace: $stackTrace');
    }
  } else {
    print('Bukan perangkat Android, melewati permintaan izin');
  }

  print('=== SELESAI MEMINTA IZIN ===');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('=== INISIALISASI APLIKASI ===');

  if (Platform.isAndroid) {
    await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    print('Notification Permission Requested');
  }

  await _requestPermissions();
  print('Additional Permissions Requested');

  await Firebase.initializeApp();
  print('Firebase Initialized');

  await AndroidAlarmManager.initialize();

  await NotificationService.initialize();

  // Initialize AlarmService (buat channel notifikasi obat)
  await AlarmService.initialize();

  // syncAlarmsFromApi dipanggil setelah login berhasil, bukan di sini
  // karena saat cold start user_data belum tentu tersedia

  await ArticleNotificationService.scheduleWeeklyArticleReminder();
  print('Article Notifications Scheduled');

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      try {
        if (response.payload != null) {
          final payloadData = json.decode(response.payload!);

          if (response.actionId == 'drink') {
            // Update status menjadi 'sudah'
            final updateResponse = await http.post(
              Uri.parse('${base_url}api/JadwalObat/upload_bukti'),
              body: {
                'id_riwayat': payloadData['id_riwayat'].toString(),
                'id_jadwal': payloadData['id_jadwal'].toString(),
                'tanggal': DateTime.now().toString().split(' ')[0],
                'status': 'sudah',
              },
            );

            if (updateResponse.statusCode == 200) {
              print('Status berhasil diupdate: sudah minum');
            } else {
              print('Gagal update status: ${updateResponse.statusCode}');
            }
          } else if (response.actionId == 'snooze') {
            // Jadwalkan ulang 5 menit kemudian
            final prefs = await SharedPreferences.getInstance();
            final String? medicineData =
                prefs.getString('medicine_${payloadData['id_jadwal']}');

            if (medicineData != null) {
              final data = json.decode(medicineData);
              await AlarmService.scheduleAlarm(
                id: payloadData['id_jadwal'],
                scheduleTime: DateTime.now().add(Duration(minutes: 5)),
                obatName: data['nama_obat'],
                dosis: data['dosis'],
                satuan: data['satuan'],
                selectedDay: data['selected_day'],
              );
              print('Alarm dijadwalkan ulang untuk 5 menit kemudian');
            }
          }
        }
      } catch (e) {
        print('Error handling notification action: $e');
      }
    },
  );

  if (Platform.isAndroid) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'medicine_reminder',
          'Medicine Reminders',
          description: 'Notifikasi pengingat minum obat',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ));
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  try {
    await NotificationService.initialize();
    print('Additional Notification Service Initialized');
  } catch (e) {
    print('Error initializing Additional Notification Service: $e');
  }

  await initializeDateFormatting('id_ID', null).then((_) {
    print('Date Formatting Initialized');
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => UserProvider()),
          BlocProvider(create: (context) => NavBloc()),
        ],
        child: const MyApp(),
      ),
    );
  });

  print('=== INISIALISASI SELESAI ===');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setupFCM();
  }

  Future<void> setupFCM() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        final userDataString = prefs.getString('user_data');

        if (userDataString != null) {
          final userData = json.decode(userDataString);

          final response = await http.post(
            Uri.parse('${base_url}api/Notification/update_token'),
            body: {
              'fcm_token': token,
              'id_user': userData['id_user'].toString(),
            },
          );

          if (response.statusCode == 200) {
            print('Token updated successfully: $token');
          } else {
            print('Failed to update token: ${response.statusCode}');
          }
        }
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        try {
          final prefs = await SharedPreferences.getInstance();
          final userDataString = prefs.getString('user_data');

          if (userDataString != null) {
            final userData = json.decode(userDataString);
            final response = await http.post(
              Uri.parse('${base_url}api/Notification/update_token'),
              body: {
                'fcm_token': newToken,
                'id_user': userData['id_user'].toString(),
              },
            );

            if (response.statusCode == 200) {
              print('Token refreshed and updated successfully: $newToken');
            } else {
              print('Failed to update refreshed token: ${response.statusCode}');
            }
          }
        } catch (e) {
          print('Error in token refresh handler: $e');
        }
      });
    } catch (e) {
      print('Error in setupFCM: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      _clearUserData();
    }
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_data');
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: Future.delayed(Duration(seconds: 3), () => checkLoginStatus()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data as Widget;
          } else {
            return SplashScreen();
          }
        },
      ),
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/dashboard':
            page = const Dashboard();
            break;
          case '/kalori':
            page = Kalori();
            break;
          case '/riwayat':
            page = const Riwayat();
            break;
          case '/profile':
            page = const Profile();
            break;
          case '/artikel':
            page = const Artikel();
            break;
          case '/ttd':
            page = InputDarah();
            break;
          case '/beratbadan':
            page = BeratBadan();
            break;
          case '/menu':
            page = MenuPage();
            break;
          case '/kuesioner':
            page = KuesionerPage();
            break;
          default:
            return null;
        }

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return Stack(
              children: [
                FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                if (animation.status == AnimationStatus.reverse)
                  FadeTransition(
                    opacity:
                        Tween<double>(begin: 1.0, end: 0.0).animate(animation),
                    child: Container(
                      color: Colors.white,
                      child: Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          child: Lottie.asset(
                            'assets/lottie/main_loading.json',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    );
  }

  Future<Widget> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');
    if (token != null) {
      return const Dashboard();
    } else {
      return const LoginScreen();
    }
  }
}
