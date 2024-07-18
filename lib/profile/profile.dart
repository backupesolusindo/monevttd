import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:monitoringobat/util/colors.dart';
import 'package:page_transition/page_transition.dart';
import 'package:monitoringobat/Login/login_screen.dart';
import 'package:monitoringobat/bloc/nav/bottom_nav.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    print("sharePref");
    print(userDataString);
    if (userDataString != null) {
      final userData = UserData.fromJson(json.decode(userDataString));
      print(userData.nama);

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
    // Hapus token akses dari Shared Preferences
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('access_token');
    prefs.remove('user_data'); // Jika ada data pengguna lain yang perlu dihapus

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

  final scaffoldKey = GlobalKey<ScaffoldState>();
  XFile? _imageFile;
  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });

      // Simpan path gambar yang dipilih
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

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadProfileImage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(selected: 3),
      key: scaffoldKey,
      backgroundColor: BackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                        color: AccentColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        boxShadow: [boxShadowAccent]),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 150),
                          alignment: Alignment.topCenter,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                child: Text(
                                  username,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Readex Pro',
                                      color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.topCenter,
                    margin: EdgeInsets.only(top: 80),
                    child: GestureDetector(
                      onTap: () {
                        print("Tapped on circle image");
                        _getImageFromGallery();
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: _imageFile != null
                            ? Image.file(
                                File(_imageFile!.path),
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.camera_alt,
                                size: 40.0,
                                color: PrimaryColor,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [boxShadow],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                    child: Text(
                      'Data Diri',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Readex Pro',
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [boxShadow],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(
                          'Nama',
                          style:
                              TextStyle(fontSize: 12, fontFamily: 'Readex Pro'),
                        )),
                        Expanded(
                            flex: 2,
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                              child: Text(
                                ": " + Nama,
                                style: TextStyle(
                                    fontFamily: 'Readex Pro', fontSize: 12),
                              ),
                            )),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Text(
                          'Email',
                          style:
                              TextStyle(fontSize: 12, fontFamily: 'Readex Pro'),
                        )),
                        Expanded(
                            flex: 2,
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                              child: Text(
                                ": " + Email,
                                style: TextStyle(
                                    fontFamily: 'Readex Pro', fontSize: 12),
                              ),
                            )),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Text(
                          'No.Handphone',
                          style:
                              TextStyle(fontSize: 12, fontFamily: 'Readex Pro'),
                        )),
                        Expanded(
                            flex: 2,
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                              child: Text(
                                ": " + telp,
                                style: TextStyle(
                                    fontFamily: 'Readex Pro', fontSize: 12),
                              ),
                            )),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Text(
                          'Tanggal Lahir',
                          style:
                              TextStyle(fontSize: 12, fontFamily: 'Readex Pro'),
                        )),
                        Expanded(
                            flex: 2,
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                              child: Text(
                                ": " + tglLahir,
                                style: TextStyle(
                                    fontFamily: 'Readex Pro', fontSize: 12),
                              ),
                            )),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Text(
                          'Berat Badan',
                          style:
                              TextStyle(fontSize: 12, fontFamily: 'Readex Pro'),
                        )),
                        Expanded(
                            flex: 2,
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                              child: Text(
                                ": " + BB + " Kg",
                                style: TextStyle(
                                    fontFamily: 'Readex Pro', fontSize: 12),
                              ),
                            )),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Text(
                          'Tinggi Badan',
                          style:
                              TextStyle(fontSize: 12, fontFamily: 'Readex Pro'),
                        )),
                        Expanded(
                            flex: 2,
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                              child: Text(
                                ": " + TB + " cm",
                                style: TextStyle(
                                    fontFamily: 'Readex Pro', fontSize: 12),
                              ),
                            )),
                      ],
                    ),
                  ],
                )),
            Align(
              alignment: AlignmentDirectional(0.00, -1.00),
              child: Container(
                margin: EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfile(),
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(200, 45),
                    backgroundColor:
                        PrimaryColor, // Atur warna latar belakang tombol
                    // Atur warna teks tombol
                    padding: EdgeInsets.all(16), // Atur padding tombol
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), // Atur sudut tombol
                    ),
                    elevation: 3,
                    textStyle: TextStyle(
                      fontSize: 12, // Atur ukuran teks tombol
                      fontWeight: FontWeight.bold, // Atur ketebalan teks tombol
                      fontFamily: 'Readex Pro',
                    ),
                  ),
                  child: Text('Edit Profile',
                      style: TextStyle(
                          color: Colors
                              .white)), // Teks yang akan ditampilkan pada tombol
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional(0.00, -1.00),
              child: Container(
                margin: EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: () {
                    logoutUser();
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(200, 45),
                    backgroundColor:
                        AccentColor, // Atur warna latar belakang tombol
                    // Atur warna teks tombol
                    padding: EdgeInsets.all(16), // Atur padding tombol
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), // Atur sudut tombol
                    ),
                    elevation: 3,
                    textStyle: TextStyle(
                      fontSize: 12, // Atur ukuran teks tombol
                      fontWeight: FontWeight.bold, // Atur ketebalan teks tombol
                    ),
                  ),
                  child: Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ), // Teks yang akan ditampilkan pada tombol
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
