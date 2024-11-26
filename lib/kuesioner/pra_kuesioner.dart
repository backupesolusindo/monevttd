import 'package:flutter/material.dart';
import 'package:monitoringobat/util/colors.dart';

class PraKuesioner extends StatefulWidget {
  @override
  _PraKuesionerState createState() => _PraKuesionerState();
}

class _PraKuesionerState extends State<PraKuesioner> {
  List<Map<String, dynamic>> pertanyaan = [
    {
      'pertanyaan': 'Apakah anda pusing?',
      'jawaban': ['Sangat Sering', 'Sering', 'Kadang-Kadang', 'Tidak Pernah']
    },
    // Tambahkan pertanyaan lain di sini
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Pra Kuesioner', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: PrimaryColor,
      ),
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Stack(
            children: [
              ListView.builder(
                itemCount: pertanyaan.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Text(
                              '${index + 1}. ${pertanyaan[index]['pertanyaan']}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            ...pertanyaan[index]['jawaban'].map<Widget>((jawaban) {
                              return RadioListTile<String>(
                                title: Text(jawaban, style: TextStyle(color: Colors.black, fontSize: 15)),
                                value: jawaban,
                                groupValue: null, // Implementasikan logika untuk menyimpan jawaban
                                onChanged: (value) {
                                  // Implementasikan logika untuk mengubah jawaban
                                },
                                activeColor: PrimaryColor,
                                contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                dense: true,
                              );
                            }).toList(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  icon: Icon(Icons.delete, color: Colors.red, size: 20),
                                  label: Text('Hapus', style: TextStyle(color: Colors.red, fontSize: 14)),
                                  onPressed: () {
                                    setState(() {
                                      pertanyaan.removeAt(index);
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    side: BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  child: Icon(Icons.add, color: Colors.white),
                  backgroundColor: PrimaryColor,
                  onPressed: () {
                    _showTambahPertanyaanDialog();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTambahPertanyaanDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newPertanyaan = '';
        return AlertDialog(
          title: Text('Tambah Pertanyaan Kuesioner', style: TextStyle(color: Colors.black)),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Pertanyaan Kuesioner',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    onChanged: (value) {
                      newPertanyaan = value;
                    },
                  ),
                  SizedBox(height: 16),
                  Text('Jawaban:', style: TextStyle(color: Colors.black)),
                  SizedBox(height: 8),
                  ...['Sangat Sering', 'Sering', 'Kadang-Kadang', 'Tidak Pernah'].map((jawaban) {
                    return ListTile(
                      title: Text(jawaban, style: TextStyle(color: Colors.black, fontSize: 14)),
                      leading: Icon(Icons.radio_button_unchecked, color: PrimaryColor),
                      contentPadding: EdgeInsets.symmetric(horizontal: 0),
                      dense: true,
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Batal', style: TextStyle(color: PrimaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Simpan', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: PrimaryColor,
              ),
              onPressed: () {
                if (newPertanyaan.isNotEmpty) {
                  setState(() {
                    pertanyaan.add({
                      'pertanyaan': newPertanyaan,
                      'jawaban': ['Sangat Sering', 'Sering', 'Kadang-Kadang', 'Tidak Pernah']
                    });
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
          backgroundColor: Colors.white,
          elevation: 24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}
