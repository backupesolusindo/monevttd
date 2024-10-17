import 'package:flutter/material.dart';
import 'package:monitoringobat/components/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monitoringobat/util/colors.dart';

class LoginScreenTopImage extends StatelessWidget {
  const LoginScreenTopImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: defaultPadding * 2),
        Center(
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 8),
                  blurRadius: 10,
                  color: WhiteColor.withOpacity(0.23),
                ),
              ],
            ),
            child: Column(children: [
              Image.asset("assets/images/logoTTD.png", width: 100, height: 100),
              SizedBox(height: mediumPadding),
              Text("MONEV TTD",
                  style: TextStyle(
                      color: PrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ]),
          ),
        ),
        SizedBox(height: defaultPadding),
        Text(
          "LOGIN USER",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: defaultPadding * 4),
      ],
    );
  }
}
