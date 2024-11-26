import 'package:flutter/material.dart';
import 'package:monitoringobat/bloc/nav/bottom_nav.dart';
import 'package:monitoringobat/laporan/laporan_bb_tb_hb_page.dart';
import 'package:monitoringobat/util/colors.dart';
import 'package:monitoringobat/kuesioner/kuesioner.dart';
import 'package:monitoringobat/riwayat/riwayat_bb_hb.dart';

class KuesionerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kuesioner & Laporan', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: PrimaryColor,
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: BottomNavBar(selected: 3),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bgmonevminumobatbaru.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMenuItem(
                        context,
                        'Kuesioner',
                        'Isi kuesioner tentang kebiasaan minum obat',
                        Icons.question_answer,
                        () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Pilih Jenis Kuesioner'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.assignment_outlined, color: PrimaryColor),
                                      title: Text('Kuesioner Sebelum Menggunakan Aplikasi'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Kuesioner(tipe: 'sebelum')
                                          )
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.assignment_turned_in, color: PrimaryColor),
                                      title: Text('Kuesioner Sesudah Menggunakan Aplikasi'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Kuesioner(tipe: 'sesudah')
                                          )
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      _buildMenuItem(
                        context,
                        'BB, TB & Hb',
                        'Catat berat badan, tinggi badan, dan hemoglobin',
                        Icons.assessment,
                        () => Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => LaporanBBTBHBPage()
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon, 
                  size: 32, 
                  color: PrimaryColor
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.black
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14, 
                        color: Colors.grey[600]
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios, 
                color: PrimaryColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
