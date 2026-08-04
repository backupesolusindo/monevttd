import 'package:flutter/material.dart';
import 'package:monitoringobat/components/constants.dart';
import 'package:monitoringobat/util/colors.dart';

class LoginScreenTopImage extends StatelessWidget {
  const LoginScreenTopImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: defaultPadding),
        // Logo bulat
        Container(
          width: 130,
          height: 130,
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
            padding: const EdgeInsets.all(20),
            child: Image.asset(
              "assets/images/logomonevTTDbaru.png",
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: defaultPadding),

        // Nama aplikasi
        Text(
          "MONEV TTD",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: PrimaryColor,
          ),
        ),
        SizedBox(height: 6),

        // Subtitle
        Text(
          "Selalu tepat waktu minum obat.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: defaultPadding * 2),
      ],
    );
  }
}