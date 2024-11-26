import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monitoringobat/util/colors.dart';
import 'package:page_transition/page_transition.dart';
import 'package:monitoringobat/Login/login_screen.dart';
import 'package:monitoringobat/bloc/nav/bottom_nav.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

import 'package:monitoringobat/model/user.dart';
import 'package:monitoringobat/profile/editprofile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String Nama = '';
  String Email = '';
  String tglLahir = '';
  String BB = '';
  String TB = '';
  String telp = '';
  String username = '';

  bool isLoading = true;

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      final userData = UserData.fromJson(json.decode(userDataString));
      setState(() {
        if (userData.nama != "" && userData.nama != null) {
          Nama = userData.nama;
        } else {
          Nama = userData.username;
        }
        Email = userData.email;
        tglLahir = userData.tglLahir;
        BB = userData.beratBadan;
        TB = userData.tinggiBadan;
        telp = userData.noTelp;
        username = userData.username;
      });
    }
  }

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('access_token');
    prefs.remove('user_data');

    Navigator.of(context).pushAndRemoveUntil(
      PageTransition(
        child: LoginScreen(),
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 500),
      ),
      (route) => false,
    );
  }

  XFile? _imageFile;
  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
      _saveImagePath(pickedFile.path);
    }
  }

  Future<void> _saveImagePath(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', imagePath);
  }

  Future<void> loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image');

    if (imagePath != null) {
      setState(() {
        _imageFile = XFile(imagePath);
      });
    }
  }

  Future<void> loadData() async {
    await loadUserData();
    await loadProfileImage();
    // Simulasi loading selama 1 detik
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      bottomNavigationBar: BottomNavBar(selected: 2),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bgmonevminumobatbaru.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Lottie.asset('assets/lottie/main_loading.json'),
                ),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 
                                 MediaQuery.of(context).padding.top - 
                                 MediaQuery.of(context).padding.bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          _buildHeader(),
                          SizedBox(height: 20),
                          _buildProfileInfo(),
                          SizedBox(height: 20),
                          _buildEditButton(),
                          SizedBox(height: 10),
                          _buildLogoutButton(),
                          SizedBox(height: 20), // Add some bottom padding
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          GestureDetector(
            onTap: _getImageFromGallery,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: _imageFile != null ? FileImage(File(_imageFile!.path)) : null,
              child: _imageFile == null
                  ? Icon(Icons.camera_alt, size: 40, color: PrimaryColor)
                  : null,
            ),
          ),
          SizedBox(height: 16),
          Text(
            Nama,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            Email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        children: [
          _buildInfoRow('Username', username),
          _buildInfoRow('Tanggal Lahir', tglLahir),
          _buildInfoRow('Berat Badan', '$BB kg'),
          _buildInfoRow('Tinggi Badan', '$TB cm'),
          _buildInfoRow('No. Telepon', telp),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditProfile()),
          );
        },
        child: Text('Edit Profil'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: PrimaryColor,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: logoutUser,
        child: Text('Logout'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.red,
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
