import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:monitoringobat/bloc/nav/bottom_nav.dart';
import 'package:monitoringobat/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monitoringobat/util/colors.dart';

import '../util/core.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String selectedGender = 'Laki-Laki';
  DateTime selectedDate = DateTime.now();

  XFile? _imageFile;
  String Id = '';
  String Nama = '';

  String? _validateNotEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Harus diisi';
    }
    return null; // Data valid
  }

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

  TextEditingController idUserController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController jabatanController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController tanggalLahirController = TextEditingController();
  TextEditingController tinggiBadanController = TextEditingController();
  TextEditingController beratBadanController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController kecamatanController = TextEditingController();
  TextEditingController kabupatenController = TextEditingController();
  TextEditingController provinsiController = TextEditingController();
  TextEditingController jenisKelaminController = TextEditingController();
  TextEditingController noTelpController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController umurController = TextEditingController();

  String clientId = "PKL2023";
  String clientSecret = "PKLSERU";
  String tokenUrl = base_url + "api/Token/token";
  String accessToken = "";

  Future<void> getToken() async {
    try {
      var response = await http.post(
        Uri.parse(tokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'client_credentials',
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> tokenData = jsonDecode(response.body);
        accessToken = tokenData['access_token'];
        print('Token Akses: $accessToken');
      } else {
        print('Gagal mendapatkan token: ${response.statusCode}');
      }
    } catch (e) {
      print('Gagal mendapatkan token: $e');
    }
  }

  void registerUser() async {
    final apiUrl = base_url + 'api/UpdateProfil/UpdateProfil';

    final Map<String, dynamic> data = {
      'id_user': Id,
      'username': usernameController.text,
      'jabatan': jabatanController.text,
      'nama': Nama,
      'tgl_lahir': tanggalLahirController.text,
      'tinggi_badan': tinggiBadanController.text,
      'berat_badan': beratBadanController.text,
      'alamat': alamatController.text,
      'kecamatan': kecamatanController.text,
      'kabupaten': kabupatenController.text,
      'provinsi': provinsiController.text,
      'jekel': jenisKelaminController.text,
      'no_telp': noTelpController.text,
      'email': emailController.text,
      'umur': umurController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(data),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken', // Menggunakan token OAuth2
        },
      );

      if (response.statusCode == 200) {
        // Registrasi berhasil, lakukan sesuatu di sini
        print('Registrasi berhasil');
        print(response.body);
      } else {
        // Registrasi gagal, tampilkan pesan kesalahan atau lakukan sesuatu yang sesuai
        print('Registrasi gagal. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Terjadi kesalahan dalam proses registrasi
      print('Terjadi kesalahan: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    getToken();
    loadUserData();
    loadProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Edit Profile'),
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // bottomNavigationBar: BottomNavBar(selected: 3),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bgmonevminumobatbaru.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  _buildProfileImage(),
                  SizedBox(height: 20),
                  _buildEditForm(),
                  SizedBox(height: 20),
                  _buildSaveButton(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: GestureDetector(
        onTap: _getImageFromGallery,
        child: CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white,
          backgroundImage: _imageFile != null ? FileImage(File(_imageFile!.path)) : null,
          child: _imageFile == null
              ? Icon(Icons.camera_alt, size: 40, color: PrimaryColor)
              : null,
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _buildTextField(usernameController, 'Username'),
          SizedBox(height: 10),
          _buildTextField(emailController, 'Email'),
          SizedBox(height: 10),
          _buildTextField(noTelpController, 'No Telepon'),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildTextField(tinggiBadanController, 'Tinggi (cm)')),
              SizedBox(width: 10),
              Expanded(child: _buildTextField(beratBadanController, 'Berat (kg)')),
            ],
          ),
          // SizedBox(height: 10),
          // _buildDropdownField(),
          SizedBox(height: 10),
          _buildDateField(),
          // SizedBox(height: 10),
          // _buildTextField(jabatanController, 'Jabatan'),
          SizedBox(height: 10),
          _buildTextField(alamatController, 'Alamat'),
          // SizedBox(height: 10),
          // _buildTextField(kecamatanController, 'Kecamatan'),
          // SizedBox(height: 10),
          // _buildTextField(kabupatenController, 'Kabupaten'),
          // SizedBox(height: 10),
          // _buildTextField(provinsiController, 'Provinsi'),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: 'Jenis Kelamin',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      value: selectedGender,
      onChanged: (value) {
        setState(() {
          selectedGender = value!;
        });
      },
      items: ['Laki-Laki', 'Perempuan'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: tanggalLahirController,
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null && pickedDate != selectedDate) {
          setState(() {
            selectedDate = pickedDate;
            tanggalLahirController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
          });
        }
      },
      decoration: InputDecoration(
        hintText: 'Tanggal Lahir',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: registerUser,
        child: Text('Simpan'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: PrimaryColor,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');

    if (userDataString != null) {
      final userData = UserData.fromJson(json.decode(userDataString));
      print(userData.nama);

      setState(() {
        Id = userData.idUser.toString();
        Nama = userData.nama;
      });
    }
  }
}
