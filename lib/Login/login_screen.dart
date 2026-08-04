import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:monitoringobat/components/responsive.dart';
import '../../components/background.dart';
import 'components/login_form.dart';
import 'components/login_screen_top_image.dart';

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Container(
          width: 200,
          height: 200,
          child: Lottie.asset(
            'assets/lottie/main_loading.json',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  Widget LoadingWidget() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Lottie.asset(
          'assets/lottie/loading.json',
          width: 200,
          height: 200,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: isLoading
          ? LoadingWidget()
          : Container(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Responsive(
                  mobile: const MobileLoginScreen(),
                  desktop: Row(
                    children: [
                      const Expanded(
                        child: LoginScreenTopImage(),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              width: 450,
                              child: LoginForm(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bgmonevminumobatbaru.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
    );
  }
}

class MobileLoginScreen extends StatelessWidget {
  const MobileLoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Kartu putih membulat, seperti pada referensi desain
          Container(
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
              children: const [
                LoginScreenTopImage(),
                LoginForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}