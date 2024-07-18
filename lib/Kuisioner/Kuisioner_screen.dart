import 'dart:convert';
import 'dart:ffi';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:monitoringobat/bloc/nav/bottom_nav.dart';
import 'package:monitoringobat/kalori/kalori.dart';
import 'package:monitoringobat/model/user.dart';
import 'package:monitoringobat/util/colors.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/core.dart';

class Kuisioner extends StatefulWidget {
  Kuisioner({Key? key});

  @override
  State<Kuisioner> createState() => _KuisionerState();
}

class _KuisionerState extends State<Kuisioner> {
  String clientId = "PKL2023";
  String clientSecret = "PKLSERU";
  String tokenUrl = base_url + "api/Token/token";
  String apiUrl = base_url + "api/BeratBadan/Kuisioner";
  String accessToken = "";
  bool isSearching = false;
  int cardValue = 0;
  String Id = '';

  int selectIndex = 0;
  List<int> id_pertanyaan = [1, 2, 3];
  List<String> pertanyaan = ["aasdasdasd", "basdasdasd", "casdasdasd"];
  List<int> jawaban = [0, 0, 0];
  bool isForward = true;
  bool isKirim = false;
  bool isLoading = true;

  void navigate(bool forward) {
    setState(() {
      isForward = forward;
      selectIndex += forward ? 1 : -1;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeAsyncOperations();
  }

  Future<void> _initializeAsyncOperations() async {
    await Future.wait([
      loadUserData(),
      getToken(),
      SelesaiLoading(),
    ]);
  }

  Future<void> SelesaiLoading() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');

    if (userDataString != null) {
      final userData = UserData.fromJson(json.decode(userDataString));
      print(userData.nama);

      setState(() {
        Id = userData.idUser.toString();
      });
    }
  }

  Future<void> getToken() async {
    try {
      // Buat permintaan untuk mendapatkan token menggunakan client_credentials
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
        // Handle error, misalnya, menampilkan pesan kesalahan
        print('Gagal mendapatkan token: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exception, misalnya, menampilkan pesan kesalahan
      print('Gagal mendapatkan token: $e');
    }
  }

  Future<void> kirimData() async {
    // log
    print('ID User: $Id');
    print('id_pertanyaan: $id_pertanyaan');
    print('Jawaban: $jawaban');

    // jika ada yang belum dijawab ke form belum jawab
    jawaban.forEach((element) {
      if (element == 0) {
        String popup =
            'Pertanyaan ke-${jawaban.indexOf(element) + 1} belum dijawab';
        setState(() {
          selectIndex = jawaban.indexOf(element);
        });
        Fluttertoast.showToast(
          msg: popup,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: WarningColor,
          textColor: Colors.white,
        );
      }
    });

    if (jawaban.contains(0)) {
      print("send");
      try {
        var response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'id_user': Id,
          }),
        );

        print('Response Simpan Data');
        print(response.body);
        if (response.statusCode == 200) {
          Fluttertoast.showToast(
            msg: 'Berhasil Kirim Data',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          Navigator.pop(context);
        } else {
          print('Gagal mengirim data: ${response.statusCode}');
        }
      } catch (e) {
        print('Gagal mengirim data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('KUISIONER', style: TextStyle(color: Colors.white)),
          backgroundColor: PrimaryColor,
        ),
        body: (isLoading)
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (selectIndex > 0)
                        IconButton(
                            onPressed: () {
                              setState(() {
                                navigate(false);
                              });
                            },
                            icon: Icon(Icons.arrow_back),
                            color: Colors.white,
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(PrimaryColor),
                                shape:
                                    MaterialStateProperty.all(CircleBorder()))),
                      Expanded(
                          child: Center(
                        child: Text(
                            (selectIndex + 1).toString() +
                                " s/d " +
                                id_pertanyaan.length.toString(),
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      )),
                      (selectIndex < id_pertanyaan.length - 1)
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  navigate(true);
                                });
                              },
                              icon: Icon(Icons.arrow_forward),
                              color: Colors.white,
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(PrimaryColor),
                                  shape: MaterialStateProperty.all(
                                      CircleBorder())))
                          : TextButton(
                              onPressed: () {
                                kirimData();
                              },
                              child: Text(
                                "SELESAI",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10)),
                                  backgroundColor:
                                      MaterialStateProperty.all(PrimaryColor),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)))),
                            )
                    ],
                  ),
                  // dengan animasi perubahan pertanyaan
                  AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        final offsetAnimation = isForward
                            ? Tween<Offset>(
                                    begin: Offset(1.5, 0), end: Offset(0, 0))
                                .animate(animation)
                            : Tween<Offset>(
                                    begin: Offset(1, 0), end: Offset(0, 0))
                                .animate(animation);
                        return SlideTransition(
                            position: offsetAnimation, child: child);
                      },
                      child: Container(
                        key: ValueKey<int>(selectIndex),
                        margin: EdgeInsets.all(20),
                        child: Column(children: [
                          Text("No. " + id_pertanyaan[selectIndex].toString(),
                              style: TextStyle(fontSize: 20)),
                          Text(pertanyaan[selectIndex],
                              style: TextStyle(fontSize: 20)),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Radio(
                                  value: 1,
                                  groupValue: jawaban[selectIndex],
                                  activeColor: PrimaryColor,
                                  onChanged: (value) {
                                    setState(() {
                                      jawaban[selectIndex] = value as int;
                                    });
                                  }),
                              Text('Sangat Sering'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Radio(
                                  value: 2,
                                  groupValue: jawaban[selectIndex],
                                  activeColor: PrimaryColor,
                                  onChanged: (value) {
                                    setState(() {
                                      jawaban[selectIndex] = value as int;
                                    });
                                  }),
                              Text('Sering'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Radio(
                                  value: 3,
                                  groupValue: jawaban[selectIndex],
                                  activeColor: PrimaryColor,
                                  onChanged: (value) {
                                    setState(() {
                                      jawaban[selectIndex] = value as int;
                                    });
                                  }),
                              Text('Kadang - Kadang'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Radio(
                                  value: 4,
                                  groupValue: jawaban[selectIndex],
                                  activeColor: PrimaryColor,
                                  onChanged: (value) {
                                    setState(() {
                                      jawaban[selectIndex] = value as int;
                                    });
                                  }),
                              Text('Tidak Pernah'),
                            ],
                          ),
                        ]),
                      ))
                ],
              ));
  }
}
