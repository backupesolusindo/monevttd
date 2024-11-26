import 'package:flutter/material.dart';
import 'package:monitoringobat/util/colors.dart';
import 'tambah_jadwal.dart';
import 'kelola_jadwal.dart';

class JadwalPage extends StatelessWidget {
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
            'Jadwal Minum Obat',
            style: TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          backgroundColor: PrimaryColor,
          elevation: 0, // Menghilangkan shadow
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
            labelColor: Colors.white, // Menambahkan warna untuk label yang aktif
            unselectedLabelColor: Colors.white70, // Menambahkan warna untuk label tidak aktif
            tabs: [
              Tab(
                icon: Icon(Icons.add_circle_outline, color: Colors.white),
                text: 'Tambah Jadwal',
                iconMargin: EdgeInsets.only(bottom: 4),
              ),
              Tab(
                icon: Icon(Icons.schedule, color: Colors.white),
                text: 'Kelola Jadwal',
                iconMargin: EdgeInsets.only(bottom: 4),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TambahJadwal(),
            KelolaJadwal(),
          ],
        ),
      ),
    );
  }
} 