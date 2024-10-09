import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class BacaArtikel extends StatefulWidget {
  final String title;
  final String description;
  final String image;

  const BacaArtikel(
      {Key? key,
      required this.title,
      required this.description,
      required this.image})
      : super(key: key);

  @override
  State<BacaArtikel> createState() => _BacaArtikelState();
}

class _BacaArtikelState extends State<BacaArtikel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.image),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      colors: [
                        Colors.black.withOpacity(.6),
                        Colors.black.withOpacity(.1),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Baca Artikel',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )),
            SizedBox(height: 16),
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Html(
                    data: widget.description,
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
