import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../util/core.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
Future<void> alarmManagerCallback(int id) async {
  print('=== ALARM CALLBACK DIPANGGIL ===');
  print('ID: $id');
  
  // Tambahkan try-catch untuk menangani error
  try {
    final prefs = await SharedPreferences.getInstance();
    final String? medicineData = prefs.getString('medicine_$id');
    
    if (medicineData != null) {
      final data = json.decode(medicineData);
      final now = DateTime.now();
      
      // Tambahkan log waktu
      print('Waktu sekarang: ${now.toString()}');
      print('Data obat: $data');

      await AlarmService.showMedicineNotification(
        id: id,
        title: "Waktunya Minum Obat! 💊",
        body: "Yuk minum ${data['nama_obat']} (${data['dosis']} ${data['satuan']}) sekarang!",
        payload: json.encode({
          'id_jadwal': id,
        }),
      );
    }
  } catch (e) {
    print('Error dalam alarm callback: $e');
  }
}

String _getDayName(int weekday) {
  switch (weekday) {
    case DateTime.monday: return 'Senin';
    case DateTime.tuesday: return 'Selasa';
    case DateTime.wednesday: return 'Rabu';
    case DateTime.thursday: return 'Kamis';
    case DateTime.friday: return 'Jumat';
    case DateTime.saturday: return 'Sabtu';
    case DateTime.sunday: return 'Minggu';
    default: return '';
  }
}

class AlarmService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
      
  static Future<void> initialize() async {
    if (await Permission.scheduleExactAlarm.status.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
    
    await AndroidAlarmManager.initialize();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );
    
    // Buat channel notifikasi dengan importance tinggi
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'medicine_reminder',
          'Medicine Reminders',
          description: 'Notifikasi pengingat minum obat',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        ));
  }

  static void _handleNotificationResponse(NotificationResponse response) {
    // Tambahkan logika penanganan notifikasi di sini jika diperlukan
    print('Notifikasi diklik: ${response.payload}');
  }

  static Future<void> scheduleAlarm({
    required int id,
    required DateTime scheduleTime,
    required String obatName,
    required String dosis,
    required String satuan,
    required String selectedDay,
  }) async {
    try {
      // Cek dan minta permission jika belum
      if (await Permission.scheduleExactAlarm.isDenied) {
        final status = await Permission.scheduleExactAlarm.request();
        if (status.isDenied) {
          print('Izin exact alarm ditolak');
          return;
        }
      }

      // Tambahkan pengecekan waktu yang lebih ketat
      if (scheduleTime.isBefore(DateTime.now())) {
        print('Waktu jadwal sudah lewat, menyesuaikan ke minggu depan');
        scheduleTime = scheduleTime.add(Duration(days: 7));
      }

      print('=== MULAI SCHEDULING ALARM ===');
      print('ID: $id');
      print('Waktu Target: ${scheduleTime.toString()}');
      print('Hari: $selectedDay');
      print('Obat: $obatName');
      print('Dosis: $dosis $satuan');

      // Simpan data obat dengan informasi hari
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('medicine_$id', json.encode({
        'nama_obat': obatName,
        'dosis': dosis,
        'satuan': satuan,
        'schedule_time': scheduleTime.toIso8601String(),
        'selected_day': selectedDay,
      }));

      // Notifikasi konfirmasi
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'schedule_confirmation',
        'Schedule Confirmations',
        channelDescription: 'Konfirmasi penjadwalan obat',
        importance: Importance.low,
        priority: Priority.low,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      );

      await _notifications.show(
        id + 1000,
        "Pengingat Obat Dijadwalkan",
        "Anda akan diingatkan untuk minum $obatName ($dosis $satuan) setiap hari $selectedDay pukul ${scheduleTime.hour.toString().padLeft(2, '0')}:${scheduleTime.minute.toString().padLeft(2, '0')}",
        NotificationDetails(android: androidPlatformChannelSpecifics),
      );

      // Jadwalkan alarm mingguan dengan exact: true dan wakeup: true
      bool success = await AndroidAlarmManager.periodic(
        const Duration(days: 7),
        id,
        alarmManagerCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
        startAt: scheduleTime,
      );

      if (!success) {
        throw Exception('Gagal menjadwalkan alarm');
      }

      print('Hasil scheduling: ${success ? "Berhasil" : "Gagal"}');
    } catch (e) {
      print('Error dalam scheduling alarm: $e');
      print(e.toString());
    }
  }

  @pragma('vm:entry-point')
  static Future<void> showMedicineNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    print('=== MENAMPILKAN NOTIFIKASI ===');
    print('Title: $title');
    print('Body: $body');

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'medicine_reminder',
        'Medicine Reminders',
        channelDescription: 'Notifikasi pengingat minum obat',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        fullScreenIntent: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _notifications.show(
        id,
        title,
        body,
        platformChannelSpecifics,
      );
      
      print('Notifikasi berhasil ditampilkan');
    } catch (e) {
      print('Error dalam menampilkan notifikasi: $e');
    }
  }
} 