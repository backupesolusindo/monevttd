// signup_form.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:monitoringobat/util/colors.dart';
import '../../components/constants.dart';
import '../../Login/components/login_form.dart';
import '../../util/core.dart';
import 'sign_up_top_image.dart';

class SignUpForm extends StatefulWidget {
  final String? Function(String?) validatePassword;
  final String? Function(String?) validateEmail;
  final String? Function(String?) validatePhone;

  const SignUpForm({
    Key? key,
    required this.validatePassword,
    required this.validateEmail,
    required this.validatePhone,
  }) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  String selectedGender = 'Perempuan'; // Default jenis kelamin
  DateTime selectedDate = DateTime.now(); // Default tanggal lahir

  String? _validateNotEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Harus diisi';
    }
    return null; // Data valid
  }

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController jabatanController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController tanggalLahirController = TextEditingController();
  TextEditingController tinggiBadanController = TextEditingController();
  TextEditingController beratBadanController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController jenisKelaminController = TextEditingController();
  TextEditingController noTelpController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController umurController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String clientId = "PKL2023";
  String clientSecret = "PKLSERU";
  String tokenUrl = base_url + "api/Token/token";
  String accessToken = "";
  TextEditingController confirmPasswordController = TextEditingController();
  bool _passwordMatch = true;

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
    if (!_passwordMatch) {
      Fluttertoast.showToast(
          msg: 'Password tidak cocok. Silakan periksa kembali.',
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG);
      return;
    }

    final apiUrl = base_url + 'api/Register/Register';

    final Map<String, dynamic> data = {
      'username': usernameController.text,
      'password': passwordController.text,
      'nama': namaController.text,
      'tgl_lahir': tanggalLahirController.text,
      'tinggi_badan': tinggiBadanController.text,
      'berat_badan': beratBadanController.text,
      'alamat': alamatController.text,
      'jekel': selectedGender,
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
          'Authorization': 'Bearer $accessToken',
        },
      );

      // Debug print
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: 'Pendaftaran Berhasil',
            backgroundColor: Colors.green,
            toastLength: Toast.LENGTH_LONG);
        Navigator.pop(context);
      } else if (response.statusCode == 502) {
        Fluttertoast.showToast(
            msg: 'Email sudah terdaftar. Silakan gunakan email lain.',
            backgroundColor: Colors.red,
            toastLength: Toast.LENGTH_LONG);
        return; // Tambahkan return untuk menghentikan proses
      } else if (response.statusCode == 501) {
        Fluttertoast.showToast(
            msg: 'Username sudah terdaftar. Silakan gunakan username lain.',
            backgroundColor: Colors.red,
            toastLength: Toast.LENGTH_LONG);
        return; // Tambahkan return untuk menghentikan proses
      } else {
        Fluttertoast.showToast(
            msg: 'Pendaftaran Gagal. Silakan coba lagi.',
            backgroundColor: Colors.red,
            toastLength: Toast.LENGTH_LONG);
        return; // Tambahkan return untuk menghentikan proses
      }
    } catch (error) {
      print('Terjadi kesalahan: $error');
      Fluttertoast.showToast(
          msg: 'Terjadi kesalahan. Silakan coba lagi.',
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG);
    }
  }

  @override
  void initState() {
    super.initState();
    getToken();
  }

  // ==== STYLE: disamakan dengan _pillInputDecoration pada LoginForm ====
  InputDecoration _buildInputDecoration(
    String hintText, {
    IconData? icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      prefixIcon: icon != null ? Icon(icon, color: PrimaryColor) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: PrimaryColor, width: 1.5),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Kelamin',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            Expanded(
              flex: 4,
              child: RadioListTile<String>(
                title: Text('Laki-laki',
                    style: TextStyle(color: Colors.grey.shade800)),
                value: 'Laki-Laki',
                groupValue: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value!;
                  });
                },
                activeColor: PrimaryColor,
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
              ),
            ),
            Expanded(
              flex: 5,
              child: RadioListTile<String>(
                title: Text('Perempuan',
                    style: TextStyle(color: Colors.grey.shade800)),
                value: 'Perempuan',
                groupValue: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value!;
                  });
                },
                activeColor: PrimaryColor,
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // ==== STYLE: kartu putih membulat, sama seperti MobileLoginScreen ====
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SignUpScreenTopImage(),
            SizedBox(height: 16),

            TextFormField(
              controller: namaController,
              cursorColor: PrimaryColor,
              decoration: _buildInputDecoration('Nama Lengkap',
                  icon: Icons.badge_outlined),
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: usernameController,
              cursorColor: PrimaryColor,
              decoration: _buildInputDecoration('Username',
                  icon: Icons.person_outline),
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: passwordController,
              cursorColor: PrimaryColor,
              decoration: _buildInputDecoration(
                'Password',
                icon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              obscureText: _obscurePassword,
              validator: widget.validatePassword,
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: confirmPasswordController,
              cursorColor: PrimaryColor,
              decoration: _buildInputDecoration(
                'Konfirmasi Password',
                icon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ).copyWith(
                errorText: _passwordMatch ? null : 'Password tidak cocok',
              ),
              obscureText: _obscureConfirmPassword,
              onChanged: (value) {
                setState(() {
                  _passwordMatch = value == passwordController.text;
                });
              },
            ),
            SizedBox(height: 16),

            _buildGenderSelection(),
            SizedBox(height: 16),

            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              cursorColor: PrimaryColor,
              decoration: _buildInputDecoration('Email',
                  icon: Icons.email_outlined),
              validator: widget.validateEmail,
            ),
            SizedBox(height: 16),

            TextFormField(
              keyboardType: TextInputType.number,
              controller: noTelpController,
              cursorColor: PrimaryColor,
              decoration: _buildInputDecoration('No Telepon',
                  icon: Icons.phone_outlined),
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: tanggalLahirController,
              cursorColor: PrimaryColor,
              decoration: _buildInputDecoration(
                'Tanggal Lahir',
                icon: Icons.cake_outlined,
                suffixIcon:
                    Icon(Icons.calendar_today, color: Colors.grey.shade600),
              ),
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
                    tanggalLahirController.text =
                        DateFormat('yyyy-MM-dd').format(selectedDate);
                  });
                }
              },
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: alamatController,
              cursorColor: PrimaryColor,
              decoration: _buildInputDecoration('Alamat',
                  icon: Icons.home_outlined),
            ),
            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: tinggiBadanController,
                    keyboardType: TextInputType.number,
                    cursorColor: PrimaryColor,
                    decoration: _buildInputDecoration('TB (cm)',
                        icon: Icons.height),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: beratBadanController,
                    keyboardType: TextInputType.number,
                    cursorColor: PrimaryColor,
                    decoration: _buildInputDecoration('BB (kg)',
                        icon: Icons.monitor_weight_outlined),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // ==== STYLE: tombol gradient, sama seperti tombol Login ====
            Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [
                    PrimaryColor,
                    PrimaryColor.withOpacity(0.7),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: PrimaryColor.withOpacity(0.35),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  registerUser();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "SIMPAN",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 16),

            // ==== STYLE: link bawah, sama seperti "Belum punya akun?" ====
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sudah punya akun? ",
                    style:
                        TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Login di sini",
                      style: TextStyle(
                        color: PrimaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}