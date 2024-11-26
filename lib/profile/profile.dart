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
import 'package:photo_view/photo_view.dart';
import 'package:monitoringobat/utils/auth_utils.dart';

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
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Profile'),
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBar: BottomNavBar(selected: 4),
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
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Foto Profil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: PrimaryColor,
                    ),
                  ),
                ),
                Divider(height: 1, color: Colors.grey[300]),
                _buildOptionTile(
                  icon: Icons.photo_library,
                  title: 'Pilih dari Galeri',
                  onTap: () {
                    Navigator.pop(context);
                    _getImageFromGallery();
                  },
                ),
                if (_imageFile != null) ...[
                  _buildOptionTile(
                    icon: Icons.delete,
                    title: 'Hapus Foto',
                    onTap: () {
                      Navigator.pop(context);
                      _deleteProfileImage();
                    },
                  ),
                  _buildOptionTile(
                    icon: Icons.visibility,
                    title: 'Lihat Foto',
                    onTap: () {
                      Navigator.pop(context);
                      _viewProfileImage();
                    },
                  ),
                ],
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: PrimaryColor),
      title: Text(
        title,
        style: TextStyle(color: Colors.black87),
      ),
      onTap: onTap,
    );
  }

  Future<void> _deleteProfileImage() async {
    setState(() {
      _imageFile = null;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_image');
  }

  void _viewProfileImage() {
    if (_imageFile != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Foto Profil'),
            titleTextStyle: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            backgroundColor: PrimaryColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Container(
            child: PhotoView(
              imageProvider: FileImage(File(_imageFile!.path)),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
          ),
        ),
      ));
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          GestureDetector(
            onTap: _showImageOptions,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage:
                  _imageFile != null ? FileImage(File(_imageFile!.path)) : null,
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
          Text(value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
        child: Text('Edit Profil', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: PrimaryColor,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          _showLogoutConfirmationDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.exit_to_app),
            SizedBox(width: 8),
            Text('Log Out', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Logout', style: TextStyle(color: PrimaryColor)),
          content: Text('Apakah Anda yakin ingin keluar?', style: TextStyle(color: Colors.black)),
          actions: <Widget>[
            TextButton(
              child: Text('Batal', style: TextStyle(color: PrimaryColor)),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
            ElevatedButton(
              child: Text('Ya, Logout', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                _logout(); // Panggil fungsi logout
              },
            ),
          ],
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }

  void _logout() {
    logoutUser();
  }
}
