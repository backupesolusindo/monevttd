import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monitoringobat/util/colors.dart';
import 'package:monitoringobat/bloc/nav/bottom_nav.dart';
import 'package:monitoringobat/artikel/artikel_detail.dart';
import 'package:lottie/lottie.dart';

class Artikel extends StatefulWidget {
  const Artikel({Key? key}) : super(key: key);

  @override
  _ArtikelState createState() => _ArtikelState();
}

class _ArtikelState extends State<Artikel> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> artikelList = [
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
        'judul': 'Cara Minum Suplementasi Zat Besi',
        'konten': 'Cara minum suplementasi zat besi yang benar adalah:\n\n'
            '1. Diminum tiap 1 minggu sekali setiap hari Jum\'at sebelum tidur malam\n'
            '2. Untuk meningkatkan penyerapan suplementasi besi, konsumsi bersama sumber vitamin C (jeruk, mangga dan pepaya) dan sumber protein hewani (daging, hati dan ikan)\n'
            '3. Hindari minum bersamaan dengan teh/kopi, tablet kalsium dan obat sakit maag\n\n'
            'Selalu ikuti instruksi dari dokter atau ahli gizi mengenai dosis dan frekuensi yang tepat untuk kondisi Anda.',
        'icon': 'assets/icons/treatment.svg',
        'gambar': 'assets/images/anemia_suplemen.jpg',
      }
    ];

    return Scaffold(
      bottomNavigationBar: BottomNavBar(selected: 2),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bgmonevminumobatbaru.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Lottie.asset('assets/lottie/main_loading.json'),
                ),
              )
            : SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Artikel Anemia',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: artikelList.length,
                        itemBuilder: (context, index) {
                          return _buildArtikelItem(
                            artikelList[index]['judul']!,
                            artikelList[index]['konten']!,
                            artikelList[index]['icon']!,
                            artikelList[index]['gambar']!,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildArtikelItem(String title, String content, String iconPath, String imagePath) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArtikelDetail(
                judul: title,
                konten: content,
                gambar: imagePath,
              ),
            ),
          );
        },
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: SvgPicture.asset(
                iconPath,
                width: 30,
                height: 30,
                color: PrimaryColor,
              ),
              title: Text(
                title,
                style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              trailing: Icon(Icons.chevron_right, color: PrimaryColor, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}
