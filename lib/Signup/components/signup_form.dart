import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Tambahkan import ini

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:monitoringobat/util/colors.dart';
import '../../components/constants.dart';
import '../../Login/components/login_form.dart';
import '../../util/core.dart';
import 'package:email_validator/email_validator.dart';

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
  TextEditingController kecamatanController = TextEditingController();
  TextEditingController kabupatenController = TextEditingController();
  TextEditingController provinsiController = TextEditingController();
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
      'kecamatan': kecamatanController.text,
      'kabupaten': kabupatenController.text,
      'provinsi': provinsiController.text,
      'jekel': selectedGender, // Menggunakan selectedGender di sini
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
        Fluttertoast.showToast(
            msg: 'Pendaftaran Berhasil',
            backgroundColor: Colors.green,
            toastLength: Toast.LENGTH_LONG);
        Navigator.pop(context);
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
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(color: Colors.blue, width: 2.0),
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
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            Expanded(
              flex: 4,
              child: RadioListTile<String>(
                title: Text('Laki-laki', style: TextStyle(color: Colors.white)),
                value: 'Laki-Laki',
                groupValue: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value!;
                  });
                },
                activeColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 0),
              ),
            ),
            
            Expanded(
              flex: 5,
              child: RadioListTile<String>(
                title: Text('Perempuan', style: TextStyle(color: Colors.white)),
                value: 'Perempuan',
                groupValue: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value!;
                  });
                },
                activeColor: Colors.white,
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
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(height: 40.0),
              SvgPicture.asset(
                "assets/icons/user-pen.svg",
                height: 100,
                width: 100,
                color: Colors.white, // Sesuaikan warna jika diperlukan
              ),
              SizedBox(height: 20.0),
              Text(
                'Isi Profil Anda',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Calibri',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: namaController,
                      decoration: _buildInputDecoration('Nama Lengkap'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: usernameController,
                      decoration: _buildInputDecoration('Username'),
                    ),
                  ),
                  // Expanded(
                  //   child: TextFormField(
                  //     controller: namaController,
                  //     decoration: InputDecoration(hintText: 'Username'),
                  //   ),
                  // )
                ],
              ),
              SizedBox(height: 10),
              Column(
                children: [
                  TextFormField(
                    controller: passwordController,
                    decoration: _buildInputDecoration('Password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText:
                        _obscurePassword, // Ini adalah kunci untuk mengubah tampilan teks
                    validator: widget.validatePassword,
                  ),
                ],
              ),
              SizedBox(height: 10),
              Column(
                children: [
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration:
                        _buildInputDecoration('Konfirmasi Password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      errorText: _passwordMatch ? null : 'Password tidak cocok',
                    ),
                    obscureText:
                        _obscureConfirmPassword, // Ini adalah kunci untuk mengubah tampilan teks
                    onChanged: (value) {
                      setState(() {
                        _passwordMatch = value == passwordController.text;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              _buildGenderSelection(),
              SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: emailController,
                      decoration: _buildInputDecoration('Email'),
                      validator: widget.validateEmail,
                    ),
                  ),
                  // SizedBox(width: 10),
                  // Expanded(
                  //   child: TextFormField(
                  //     keyboardType: TextInputType.number,
                  //     controller: noTelpController,
                  //     decoration: _buildInputDecoration('No Telepon'),
                  //   ),
                  // ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: noTelpController,
                      decoration: _buildInputDecoration('No Telepon'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Row(
              //   children: [
              //     Expanded(
              //       child: TextFormField(
              //         keyboardType: TextInputType.number,
              //         controller: tinggiBadanController,
              //         decoration: InputDecoration(hintText: 'Tinggi (cm)'),
              //       ),
              //     ),
              //     SizedBox(width: 10),
              //     Expanded(
              //       child: TextFormField(
              //         keyboardType: TextInputType.number,
              //         controller: beratBadanController,
              //         decoration: InputDecoration(hintText: 'Berat (kg)'),
              //       ),
              //     ),
              //   ],
              // ),
              // SizedBox(height: 10),
              // Row(
              //   children: [
              //     Expanded(
              //       child: InputDecorator(
              //         decoration: _buildInputDecoration('Jenis Kelamin'),
              //         child: DropdownButtonHideUnderline(
              //           child: DropdownButton<String>(
              //             value: selectedGender,
              //             onChanged: (value) {
              //               setState(() {
              //                 selectedGender = value!;
              //               });
              //             },
              //             items: ['Perempuan', 'Laki-Laki'].map((String value) {
              //               return DropdownMenuItem<String>(
              //                 value: value,
              //                 child: Text(value),
              //               );
              //             }).toList(),
              //           ),
              //         ),
              //       ),
              //     ),
              //     SizedBox(width: 10),
              //     // Expanded(
              //     //   child: TextFormField(
              //     //     controller: tanggalLahirController,
              //     //     decoration: _buildInputDecoration('Tanggal Lahir').copyWith(
              //     //       suffixIcon: Icon(Icons.calendar_today),
              //     //     ),
              //     //     onTap: () async {
              //     //       final DateTime? pickedDate = await showDatePicker(
              //     //         context: context,
              //     //         initialDate: selectedDate,
              //     //         firstDate: DateTime(1900),
              //     //         lastDate: DateTime.now(),
              //     //       );
              //     //       if (pickedDate != null &&
              //     //           pickedDate != selectedDate) {
              //     //         setState(() {
              //     //           selectedDate = pickedDate;
              //     //           tanggalLahirController.text =
              //     //               DateFormat('yyyy-MM-dd')
              //     //                   .format(selectedDate);
              //     //         });
              //     //       }
              //     //     },
              //     //   ),
              //     // ),
              //   ],
              // ),
              // SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: tanggalLahirController,
                      decoration:
                          _buildInputDecoration('Tanggal Lahir').copyWith(
                        suffixIcon: Icon(Icons.calendar_today),),
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null &&
                              pickedDate != selectedDate) {
                            setState(() {
                              selectedDate = pickedDate;
                              tanggalLahirController.text =
                                  DateFormat('yyyy-MM-dd').format(selectedDate);
                            });
                          }
                        },
                      ),
                    ),
                  // ),
                ],
              ),
              SizedBox(height: 10),
              // Row(
              //   children: [
              //     Expanded(
              //       child: TextFormField(
              //         controller: umurController,
              //         keyboardType: TextInputType.number,
              //         decoration: InputDecoration(hintText: 'Umur'),
              //       ),
              //     ),
              //   ],
              // ),
              // SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: alamatController,
                      decoration: _buildInputDecoration('Alamat'),
                    ),
                  ),
                  SizedBox(width: 10),
                  // Expanded(
                  //   child: TextFormField(
                  //     controller: kecamatanController,
                  //     decoration: InputDecoration(hintText: 'Kecamatan'),
                  //   ),
                  // ),
                ],
              ),
              SizedBox(height: 10),
              // Row(
              //   children: [
              //     Expanded(
              //       child: TextFormField(
              //         controller: kabupatenController,
              //         decoration: InputDecoration(hintText: 'Kabupaten'),
              //       ),
              //     ),
              //     SizedBox(width: 10),
              //     Expanded(
              //       child: TextFormField(
              //         controller: provinsiController,
              //         decoration: InputDecoration(hintText: 'Provinsi'),
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    registerUser();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: WhiteColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: 100,
                      vertical: defaultPadding,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "SIMPAN",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: PrimaryColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Sudah punya akun? Login di sini',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
