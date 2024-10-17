import 'package:flutter/material.dart';
import 'package:monitoringobat/components/constants.dart';
import 'package:monitoringobat/components/responsive.dart';
import 'package:email_validator/email_validator.dart';

import '../../components/background.dart';
import 'components/sign_up_top_image.dart';
import 'components/signup_form.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg_registerbaru.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SignUpForm(
          validatePassword: (value) {
            if (value == null || value.isEmpty) {
              return 'Password harus diisi';
            }
            if (value.length < 8) {
              return 'Password harus minimal 8 karakter';
            }
            if (!value.contains(RegExp(r'[A-Z]'))) {
              return 'Password harus mengandung minimal 1 huruf besar';
            }
            if (!value.contains(RegExp(r'[0-9]'))) {
              return 'Password harus mengandung minimal 1 angka';
            }
            return null;
          },
          validateEmail: (value) {
            if (value == null || value.isEmpty) {
              return 'Email harus diisi';
            }
            if (!EmailValidator.validate(value)) {
              return 'Masukkan email yang valid';
            }
            return null;
          },
          validatePhone: (value) {
            if (value == null || value.isEmpty) {
              return 'Nomor telepon harus diisi';
            }
            if (!value.startsWith('8')) {
              return 'Nomor telepon harus dimulai dengan 8';
            }
            if (!RegExp(r'^[0-9]{9,}$').hasMatch(value)) {
              return 'Nomor telepon tidak valid';
            }
            return null;
          },
        ),
      ),
    );
  }
}

class MobileSignupScreen extends StatelessWidget {
  const MobileSignupScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SignUpScreenTopImage(),
        SignUpForm(
          validatePassword: (value) {
            // Sama seperti di atas
          },
          validateEmail: (value) {
            // Sama seperti di atas
          },
          validatePhone: (value) {
            // Sama seperti di atas
          },
        ),
      ],
    );
  }
}
