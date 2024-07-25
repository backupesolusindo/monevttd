import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Future<void> showPopup(BuildContext context, String? title, String? content,
    String? lottie) async {
  //default value title
  title = title == null ? 'Berhasil' : title;
  content = content == null ? 'Proses Data Berhasil' : content;
  lottie = lottie == null ? 'assets/lottie/verif_login_tipe1.json' : lottie;
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(lottie!),
              SizedBox(height: 20),
              Text(
                title!,
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(content!),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Close'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
