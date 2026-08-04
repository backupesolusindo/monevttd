import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../util/core.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:monitoringobat/model/user.dart';

// ---------------------------------------------------------------------------
// Callback dipanggil oleh AndroidAlarmManager di isolate TERPISAH.
// Karena isolate baru, semua plugin harus di-initialize ulang dari nol.
// ---------------------------------------------------------------------------
@pragma('vm:entry-point')
Future<void> alarmManagerCallback(int id) async {
  // Wajib initialize plugin di isolate baru
  final notifications = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');
 await notifications.initialize(
  settings: const InitializationSettings(android: androidInit),
);

  // Buat channel agar notifikasi bisa tampil
  await notifications
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

  try {
    final prefs = await SharedPreferences.getInstance();
    final String? medicineData = prefs.getString('medicine_$id');

    if (medicineData == null) return;

    final data = json.decode(medicineData) as Map<String, dynamic>;
    final namaObat = data['nama_obat'] ?? '';
    final dosis = data['dosis'] ?? '';
    final satuan = data['satuan'] ?? '';

    const AndroidNotificationDetails androidDetails =
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

    await notifications.show(
  id: id,
  title: 'Waktunya Minum Obat! 💊',
  body: 'Yuk minum $namaObat ($dosis $satuan) sekarang!',
  notificationDetails: const NotificationDetails(android: androidDetails),
  payload: json.encode({'id_jadwal': id}),
);
  } catch (_) {
    // Tidak bisa log dari isolate terpisah
  }
}

// ---------------------------------------------------------------------------
// Helper: hitung DateTime berikutnya untuk hari & jam tertentu
// ---------------------------------------------------------------------------
DateTime _nextScheduleTime(String dayName, int hour, int minute) {
  const dayMap = {
    'Senin': DateTime.monday,
    'Selasa': DateTime.tuesday,
    'Rabu': DateTime.wednesday,
    'Kamis': DateTime.thursday,
    'Jumat': DateTime.friday,
    'Sabtu': DateTime.saturday,
    'Minggu': DateTime.sunday,
  };

  final now = DateTime.now();
  final targetWeekday = dayMap[dayName] ?? DateTime.monday;
  int daysUntil = targetWeekday - now.weekday;

  if (daysUntil < 0) {
    daysUntil += 7;
  } else if (daysUntil == 0) {
    final todayTarget = DateTime(now.year, now.month, now.day, hour, minute);
    if (!todayTarget.isAfter(now)) {
      daysUntil = 7; // Waktu hari ini sudah lewat, jadwalkan minggu depan
    }
  }

  return DateTime(now.year, now.month, now.day + daysUntil, hour, minute);
}

// ---------------------------------------------------------------------------
// AlarmService
// ---------------------------------------------------------------------------
class AlarmService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // -------------------------------------------------------------------------
  // Inisialisasi — panggil sekali saat app start (main.dart)
  // -------------------------------------------------------------------------
  static Future<void> initialize() async {
    if (_initialized) return;

    if (await Permission.scheduleExactAlarm.status.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    await AndroidAlarmManager.initialize();

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    await _notifications.initialize(
      settings:  InitializationSettings(android: androidInit),
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    // Buat notification channel dengan importance MAX
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

    // Channel konfirmasi penjadwalan (low importance)
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'schedule_confirmation',
          'Schedule Confirmations',
          description: 'Konfirmasi penjadwalan obat',
          importance: Importance.low,
        ));

    _initialized = true;
  }

  static void _handleNotificationResponse(NotificationResponse response) {
    // Tangani tap notifikasi jika diperlukan
  }

  // -------------------------------------------------------------------------
  // Jadwalkan satu alarm berdasarkan id_jadwal dari API
  // -------------------------------------------------------------------------
  static Future<bool> scheduleAlarm({
    required int id, // gunakan id_jadwal dari API
    required DateTime scheduleTime,
    required String obatName,
    required String dosis,
    required String satuan,
    required String selectedDay,
  }) async {
    if (await Permission.scheduleExactAlarm.isDenied) {
      final status = await Permission.scheduleExactAlarm.request();
      if (status.isDenied) return false;
    }

    // Pastikan waktu belum lewat
    if (scheduleTime.isBefore(DateTime.now())) {
      scheduleTime = scheduleTime.add(const Duration(days: 7));
    }

    // Simpan data obat ke SharedPreferences agar bisa dibaca di callback
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'medicine_$id',
      json.encode({
        'nama_obat': obatName,
        'dosis': dosis,
        'satuan': satuan,
        'schedule_time': scheduleTime.toIso8601String(),
        'selected_day': selectedDay,
      }),
    );

    // Jadwalkan alarm mingguan
    final bool success = await AndroidAlarmManager.periodic(
      const Duration(days: 7),
      id,
      alarmManagerCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      startAt: scheduleTime,
    );

    if (success) {
      // Tampilkan notifikasi konfirmasi
      const AndroidNotificationDetails confirmDetails =
          AndroidNotificationDetails(
        'schedule_confirmation',
        'Schedule Confirmations',
        channelDescription: 'Konfirmasi penjadwalan obat',
        importance: Importance.low,
        priority: Priority.low,
        showWhen: false,
        icon: '@mipmap/ic_launcher',
      );

      await _notifications.show(
        id : id + 10000, // ID berbeda agar tidak bentrok dengan alarm notifikasi
        title: 'Pengingat Obat Dijadwalkan ✅',
        body: 'Akan diingatkan minum $obatName ($dosis $satuan) setiap $selectedDay '
            'pukul ${scheduleTime.hour.toString().padLeft(2, '0')}:'
            '${scheduleTime.minute.toString().padLeft(2, '0')}',
        notificationDetails:  NotificationDetails(android: confirmDetails),
      );
    }

    return success;
  }

  // -------------------------------------------------------------------------
  // Batalkan alarm berdasarkan id_jadwal
  // -------------------------------------------------------------------------
  static Future<void> cancelAlarm(int id) async {
    await AndroidAlarmManager.cancel(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('medicine_$id');
  }

  // -------------------------------------------------------------------------
  // Sinkronisasi semua alarm dari API.
  // Dipanggil setelah login berhasil, setelah tambah/edit/hapus jadwal,
  // dan saat app resume (jika user sudah login).
  // -------------------------------------------------------------------------
  static Future<void> syncAlarmsFromApi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      final accessToken = prefs.getString('access_token');

      // Belum login — tidak ada yang bisa di-sync
      if (userDataString == null || accessToken == null) return;

      final userData = UserData.fromJson(json.decode(userDataString));

      final response = await http.get(
        Uri.parse(
            '${base_url}api/JadwalObat/list_jadwal?id_user=${userData.idUser}'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return;

      final data = json.decode(response.body);
      if (data['message']['status'] != 200) return;

      final List<dynamic> jadwalList = data['response'];

      // Batalkan semua alarm lama yang tersimpan di SharedPreferences
      final allKeys = Set<String>.from(prefs.getKeys());
      for (final key in allKeys) {
        if (key.startsWith('medicine_')) {
          final idStr = key.replaceFirst('medicine_', '');
          final oldId = int.tryParse(idStr);
          if (oldId != null) {
            await AndroidAlarmManager.cancel(oldId);
          }
          await prefs.remove(key);
        }
      }

      // Jadwalkan ulang semua alarm dari API
      for (final jadwal in jadwalList) {
        final int idJadwal = int.tryParse(jadwal['id_jadwal'].toString()) ?? 0;
        if (idJadwal == 0) continue;

        final String hari = jadwal['hari'].toString();
        final String waktu =
            jadwal['waktu'].toString(); // "HH:mm:ss" atau "HH:mm"
        final String namaObat = jadwal['nama_obat'].toString();
        final String dosis = jadwal['dosis'].toString();
        final String satuan = jadwal['satuan'].toString();

        // Parse jam dan menit
        final parts = waktu.split(':');
        final int hour = int.tryParse(parts[0]) ?? 0;
        final int minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

        final scheduleTime = _nextScheduleTime(hari, hour, minute);

        // Simpan data ke SharedPreferences
        await prefs.setString(
          'medicine_$idJadwal',
          json.encode({
            'nama_obat': namaObat,
            'dosis': dosis,
            'satuan': satuan,
            'schedule_time': scheduleTime.toIso8601String(),
            'selected_day': hari,
          }),
        );

        // Daftarkan alarm periodik mingguan
        await AndroidAlarmManager.periodic(
          const Duration(days: 7),
          idJadwal,
          alarmManagerCallback,
          exact: true,
          wakeup: true,
          rescheduleOnReboot: true,
          startAt: scheduleTime,
        );
      }
    } catch (_) {
      // Gagal sync tidak boleh crash app
    }
  }
}
