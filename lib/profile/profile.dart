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
import 'package:http/http.dart' as http;
import '../util/core.dart';

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
  String alamat = '';
  String Id = '';
  String jekel = '';

  bool isLoading = true;

  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      final token = prefs.getString('access_token');

      if (userDataString != null) {
        final userData = UserData.fromJson(json.decode(userDataString));
        Id = userData.idUser.toString();
        
        // Ambil data dari API
        final response = await http.get(
          Uri.parse('${base_url}api/User/profil?id_user=$Id'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['message']['status'] == 200) {
            final data = responseData['response'];
            setState(() {
              username = data['username'] ?? '';
              tglLahir = data['tgl_lahir'] ?? '';
              BB = data['berat_badan'] ?? '';
              TB = data['tinggi_badan'] ?? '';
              telp = data['no_telp'] ?? '';
              alamat = data['alamat'] ?? '';
              if (data['nama'] != "" && data['nama'] != null) {
                Nama = data['nama'];
              } else {
                Nama = data['username'];
              }
              Email = data['email'] ?? '';
            });
          }
        } else {
          throw Exception('Gagal memuat data profil');
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat memuat data'))
      );
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

  Future<void> fetchUserData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final userDataString = prefs.getString('user_data');
      
      if (userDataString == null || token == null) {
        print('User data or token not found in SharedPreferences');
        return;
      }

      final userData = UserData.fromJson(json.decode(userDataString));
      final userId = userData.idUser.toString();

      print('Fetching user data for ID: $userId');
      print('URL: ${base_url}api/User/get_user_by_id/$userId');
      
      final response = await http.get(
        Uri.parse('${base_url}api/User/get_user_by_id/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['status'] == true && responseData['data'] != null) {
          final data = responseData['data'];
          if (mounted) {
            setState(() {
              username = data['username'] ?? '';
              Nama = data['nama'] ?? data['username'] ?? '';
              Email = data['email'] ?? '';
              tglLahir = data['tgl_lahir'] ?? '';
              BB = data['berat_badan']?.toString() ?? '0';
              TB = data['tinggi_badan']?.toString() ?? '0';
              telp = data['no_telp'] ?? '';
              alamat = data['alamat'] ?? '';
              jekel = data['jekel'] ?? '';
              isLoading = false;
            });
            print('Data berhasil diupdate: $Nama, $Email, $tglLahir, $BB, $TB, $telp, $alamat');
          }
        } else {
          throw Exception(responseData['message'] ?? 'Data tidak valid');
        }
      } else {
        throw Exception('Gagal memuat data profil. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data profil: ${e.toString()}'),
            duration: Duration(seconds: 3),
          )
        );
      }
    }
  }

  Future<void> loadData() async {
    await loadUserData(); // Tetap load dari shared preferences dulu
    await fetchUserData(); // Kemudian update dengan data dari API
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
    fetchUserData();
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
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              // Navigasi ke halaman edit dan tunggu hasilnya
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfile()),
              );
              // Jika kembali dengan hasil true, refresh data
              if (result == true) {
                fetchUserData();
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(selected: 4),
      body: RefreshIndicator(
        onRefresh: fetchUserData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bgmonevminumobatbaru.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: isLoading
                ? Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Lottie.asset('assets/lottie/main_loading.json'),
                          ),
                        ],
                      ),
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
          // _buildInfoRow('Nama', Nama),
          _buildInfoRow('Email', Email),
          _buildInfoRow('Tanggal Lahir', tglLahir),
          _buildInfoRow('Berat Badan', '$BB kg'),
          _buildInfoRow('Tinggi Badan', '$TB cm'),
          _buildInfoRow('No. Telepon', telp),
          _buildInfoRow('Jenis Kelamin', jekel),
          _buildInfoRow('Alamat', alamat),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label, 
              style: TextStyle(fontSize: 14, color: Colors.grey)
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () async {
          // Navigasi ke halaman edit dan tunggu hasilnya
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditProfile()),
          );
          // Jika kembali dengan hasil true, refresh data
          if (result == true) {
            fetchUserData();
          }
        },
        child: Text('Edit Profil', 
          style: TextStyle(
            color: Colors.white, 
            fontSize: 16, 
            fontWeight: FontWeight.bold
          )
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: PrimaryColor,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
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
