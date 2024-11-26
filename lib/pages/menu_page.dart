import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monitoringobat/jadwal/tambah_jadwal.dart';
import 'package:monitoringobat/obat/tambah_obat.dart';
import 'package:monitoringobat/riwayat/riwayat_kuesioner.dart';
import 'package:monitoringobat/util/colors.dart';
import 'package:monitoringobat/kuesioner/kuesioner.dart';
import 'package:monitoringobat/riwayat/riwayat_bb_hb.dart';
import 'package:monitoringobat/profile/profile.dart';
import 'package:monitoringobat/artikel/artikel.dart';
import 'package:monitoringobat/bloc/nav/bottom_nav.dart';
import 'package:monitoringobat/artikel/artikel_detail.dart';
import 'package:monitoringobat/jadwal/jadwal_page.dart';
import 'package:monitoringobat/obat/obat_page.dart';


class MenuPage extends StatelessWidget {
  final List<Map<String, String>> infoAnemia = [
    {
        'judul': 'Definisi Anemia',
        'konten': 'Anemia adalah suatu kondisi tubuh dimana kadar hemoglobin (Hb) dalam darah lebih rendah dari normal (WHO, 2011). Remaja putri menderita anemia bila kadar hemoglobin darah menunjukkan nilai kurang dari 12 g/dL.\n\n'
            'Hemoglobin adalah salah satu komponen dalam sel darah merah/eritrosit yang berfungsi untuk mengikat oksigen dan menghantarkannya ke seluruh sel jaringan tubuh.',
        'icon': 'assets/icons/knowledge.svg',
        'gambar': 'assets/images/anemia_definisi.jpg',
      },
      {
        'judul': 'Defisiensi Zat Besi',
        'konten': 'Defisiensi zat besi terjadi karena rendahnya asupan zat gizi baik hewani maupun nabati yang merupakan sumber zat besi. Zat besi berperan penting untuk pembuatan hemoglobin sebagai komponen dari sel darah merah/eritrosit.',
        'icon': 'assets/icons/type.svg',
        'gambar': 'assets/images/anemia_zat_besi.jpg',
      },
      {
        'judul': 'Klasifikasi Anemia',
        'konten': 'Anemia dapat dikategorikan menjadi beberapa jenis berdasarkan penyebabnya, antara lain:\n\n'
            '1. Anemia defisiensi zat besi\n'
            '2. Anemia defisiensi vitamin B12\n'
            '3. Anemia defisiensi asam folat\n'
            '4. Anemia aplastik',
        'icon': 'assets/icons/type.svg',
        'gambar': 'assets/images/anemia_klasifikasi.png',
      },
      {
        'judul': 'Penyebab Anemia',
        'konten': 'Anemia dapat terjadi karena beberapa faktor, antara lain:\n\n'
            '1. Defisiensi zat besi\n'
            '2. Defisiensi asam folat\n'
            '3. Defisiensi vitamin B12\n'
            '4. Defisiensi protein\n\n'
            'Secara langsung, anemia terutama disebabkan karena produksi atau kualitas sel darah merah yang kurang dan kehilangan darah baik secara akut atau menahun.',
        'icon': 'assets/icons/cause.svg',
        'gambar': 'assets/images/anemia_penyebab.jpg',
      },
      {
        'judul': 'Gejala Anemia',
        'konten': 'Gejala umum anemia meliputi:\n\n'
            '1. 5 L (Lesu, Letih, Lemah, Lelah, Lalai)\n'
            '2. Sakit kepala dan pusing ("kepala muter")\n'
            '3. Mata berkunang-kunang\n'
            '4. Mudah mengantuk\n'
            '5. Cepat capai serta sulit konsentrasi\n'
            '6. Pucat pada muka, kelopak mata, bibir, kulit, kuku dan telapak tangan',
        'icon': 'assets/icons/symptom.svg',
        'gambar': 'assets/images/anemia_gejala.jpg',
      },
      {
        'judul': 'Dampak Anemia',
        'konten': 'Anemia dapat menyebabkan berbagai dampak buruk pada remaja putri diantaranya:\n\n'
            '1. Menurunkan daya tahan tubuh sehingga penderita anemia mudah terkena penyakit infeksi\n'
            '2. Menurunnya kebugaran dan ketangkasan berpikir karena kurangnya oksigen ke sel otot dan sel otak\n'
            '3. Menurunnya prestasi belajar dan produktivitas kerja/kinerja\n'
            '4. Meningkatkan risiko Pertumbuhan Janin Terhambat (PJT), prematur, BBLR, dan gangguan tumbuh kembang anak diantaranya stunting dan gangguan neurokognitif\n'
            '5. Perdarahan sebelum dan saat melahirkan yang dapat mengancam keselamatan ibu dan bayinya\n'
            '6. Bayi lahir dengan cadangan zat besi (Fe) yang rendah akan berlanjut menderita anemia pada bayi dan usia dini\n'
            '7. Meningkatnya risiko kesakitan dan kematian neonatal dan bayi',
        'icon': 'assets/icons/treatment.svg',
        'gambar': 'assets/images/anemia_perawatan.jpg',
      },
      {
        'judul': 'Pencegahan Anemia',
        'konten': 'Pencegahan anemia dapat dilakukan dengan cara:\n\n'
            '1. Meningkatkan asupan makanan sumber zat besi\n'
            '2. Penambahan bahan makanan dengan zat besi\n'
            '3. Suplementasi zat besi\n\n'
            'Selain itu, penting juga untuk menghindari minuman yang menghambat penyerapan zat besi dan melakukan pemeriksaan kesehatan rutin.',
        'icon': 'assets/icons/prevention.svg',
        'gambar': 'assets/images/anemia_pencegahan.jpg',
      },
      {
        'judul': 'Suplementasi Zat Besi',
        'konten': 'Cara minum suplementasi zat besi yang benar adalah:\n\n'
            '1. Diminum tiap 1 minggu sekali setiap hari Jum\'at sebelum tidur malam\n'
            '2. Untuk meningkatkan penyerapan suplementasi besi, konsumsi bersama sumber vitamin C (jeruk, mangga dan pepaya) dan sumber protein hewani (daging, hati dan ikan)\n'
            '3. Hindari minum bersamaan dengan teh/kopi, tablet kalsium dan obat sakit maag\n\n'
            'Selalu ikuti instruksi dari dokter atau ahli gizi mengenai dosis dan frekuensi yang tepat untuk kondisi Anda.',
        'icon': 'assets/icons/treatment.svg',
        'gambar': 'assets/images/anemia_suplemen.jpg',
      }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MENU', 
          style: TextStyle(
            color: Colors.white, 
            fontSize: 20, 
            fontWeight: FontWeight.bold
          )
        ),
        backgroundColor: PrimaryColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile()),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(selected: 4),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bgmonevminumobatbaru.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMenuSection(context),
                    _buildInfoAnemiaSection(context),
                  ],
                ),
              ),
            ),
            Container(
              height: 50,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMenuItem(
            context,
            'Jadwal Minum Obat',
            'Atur jadwal minum obat Anda',
            Icons.access_time,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JadwalPage()),
              );
            },
          ),
          SizedBox(height: 12),
          _buildMenuItem(
            context,
            'Data Obat',
            'Kelola data obat Anda',
            Icons.medical_services,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ObatPage()),
              );
            },
          ),
          SizedBox(height: 12),
          _buildMenuItem(
            context,
            'Riwayat Kuesioner',
            'Lihat riwayat kuesioner Anda',
            Icons.question_answer,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RiwayatKuesioner()),
              );
            },
          ),
          SizedBox(height: 12),
          _buildMenuItem(
            context,
            'Riwayat BB, TB dan Hb',
            'Lihat riwayat BB, TB dan Hb Anda',
            Icons.monitor_weight,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RiwayatBBHB()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoAnemiaSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Info Anemia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: PrimaryColor, // Menggunakan PrimaryColor
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 120, // Menambah tinggi container untuk mengakomodasi 2 baris text
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: infoAnemia.length,
              itemBuilder: (context, index) {
                final item = infoAnemia[index];
                return Container(
                  width: 85, // Sedikit diperlebar untuk mengakomodasi 2 baris
                  margin: EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArtikelDetail(
                            judul: item['judul']!,
                            konten: item['konten']!,
                            gambar: item['gambar']!,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: PrimaryColor, // Menggunakan PrimaryColor
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 40, // Tinggi tetap untuk 2 baris
                          child: Text(
                            item['judul']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                              height: 1.2, // Mengatur jarak antar baris
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back_ios, color: Colors.grey, size: 16),
              Text(
                'Geser untuk melihat lebih banyak',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, 
    String title, 
    String subtitle, 
    IconData icon, 
    VoidCallback onTap
  ) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
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
                child: Icon(icon, size: 24, color: PrimaryColor),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: PrimaryColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
