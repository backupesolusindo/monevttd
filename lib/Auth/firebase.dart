import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    try {
      print('\n=================== CHECKING FIREBASE ===================');
      // Get FCM token
      final fcmToken = await _firebaseMessaging.getToken();
      print('FCM TOKEN: $fcmToken');
      print('=====================================================\n');

      // Request permission
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print('Permission status: ${settings.authorizationStatus}');

    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }
}
