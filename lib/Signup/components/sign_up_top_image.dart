import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monitoringobat/components/constants.dart';
import 'package:monitoringobat/util/colors.dart';

class SignUpScreenTopImage extends StatelessWidget {
  const SignUpScreenTopImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: defaultPadding),
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 8),
                blurRadius: 16,
                color: PrimaryColor.withOpacity(0.15),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SvgPicture.asset(
              "assets/icons/user-pen.svg",
              color: PrimaryColor,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: defaultPadding),

        Text(
          "DAFTAR AKUN",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: PrimaryColor,
          ),
        ),
        SizedBox(height: 6),

        Text(
          "Isi profil Anda untuk mulai memantau minum obat.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: defaultPadding),
      ],
    );
  }
}