import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:page_transition/page_transition.dart';
import 'package:monitoringobat/Login/login_screen.dart';

Future<void> logoutUser(BuildContext context) async {
  // Hapus token akses dari Shared Preferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('access_token');
  await prefs.remove('user_data'); // Jika ada data pengguna lain yang perlu dihapus

  // Arahkan pengguna kembali ke halaman login
  Navigator.of(context).pushAndRemoveUntil(
    PageTransition(
      child: LoginScreen(),
      type: PageTransitionType.fade,
      duration: const Duration(milliseconds: 500),
    ),
    (route) => false, // Hapus seluruh riwayat navigasi
  );
}
