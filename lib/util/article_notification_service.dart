import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'dart:math';

class ArticleNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static final List<Map<String, String>> articleMessages = [
    {
      'title': 'Tips Mengatasi Anemia! 💪',
      'body': 'Baca artikel terbaru tentang cara mengatasi anemia secara efektif'
    },
    {
      'title': 'Fakta Menarik Tentang Zat Besi! 🔬',
      'body': 'Ketahui pentingnya zat besi untuk tubuh Anda'
    },
    {
      'title': 'Update Artikel Kesehatan! 📚',
      'body': 'Ada artikel baru tentang penambah darah. Yuk baca sekarang!'
    }
  ];

  static Future<void> scheduleWeeklyArticleReminder() async {
    try {
      final now = DateTime.now();
      var scheduledDate = _nextFriday(now, hour: 10);
      
      const int ARTICLE_REMINDER_ID = 999;

      await AndroidAlarmManager.periodic(
        const Duration(days: 7),
        ARTICLE_REMINDER_ID,
        articleReminderCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
        startAt: scheduledDate,
      );
    } catch (e) {
      print('Error dalam penjadwalan artikel: $e');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> articleReminderCallback(int id) async {
    final random = Random();
    final message = articleMessages[random.nextInt(articleMessages.length)];

    await showArticleNotification(
      title: message['title']!,
      body: message['body']!,
    );
  }

  static Future<void> showArticleNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'article_reminder',
      'Article Reminders',
      channelDescription: 'Notifikasi pengingat artikel kesehatan',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const NotificationDetails platformDetails = 
        NotificationDetails(android: androidDetails);

    await _notifications.show(
      999,
      title,
      body,
      platformDetails,
    );
  }

  static DateTime _nextFriday(DateTime from, {required int hour}) {
    DateTime date = DateTime(from.year, from.month, from.day, hour);
    while (date.weekday != DateTime.friday || date.isBefore(from)) {
      date = date.add(const Duration(days: 1));
    }
    return DateTime(date.year, date.month, date.day, hour);
  }
} 