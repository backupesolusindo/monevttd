import 'package:flutter/material.dart';
import 'package:monitoringobat/util/colors.dart';
import 'tambah_obat.dart';
import 'kelola_obat.dart';

class ObatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Data Obat',
            style: TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          backgroundColor: PrimaryColor,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(
                icon: Icon(Icons.add_circle_outline, color: Colors.white),
                text: 'Tambah Obat',
                iconMargin: EdgeInsets.only(bottom: 4),
              ),
              Tab(
                icon: Icon(Icons.medication, color: Colors.white),
                text: 'Kelola Obat',
                iconMargin: EdgeInsets.only(bottom: 4),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TambahObat(),
            KelolaObat(),
          ],
        ),
      ),
    );
  }
} 