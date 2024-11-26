import 'package:flutter/material.dart';
import 'package:monitoringobat/util/colors.dart';
import 'package:monitoringobat/util/core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:monitoringobat/model/user.dart';
import 'package:lottie/lottie.dart';
import 'package:monitoringobat/obat/edit_obat.dart';

class KelolaObat extends StatefulWidget {
  @override
  _KelolaObatState createState() => _KelolaObatState();
}

class _KelolaObatState extends State<KelolaObat> {
  List<Map<String, dynamic>> obatList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadObat();
  }

  Future<void> loadObat() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      var userDataString = prefs.getString('user_data');
      var accessToken = prefs.getString('access_token');

      if (userDataString == null) throw Exception('Data user tidak ditemukan');

      final userData = UserData.fromJson(json.decode(userDataString));
      
      var response = await http.get(
        Uri.parse('${base_url}api/Obat/list_obat?id_user=${userData.idUser}'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['message']['status'] == 200) {
          setState(() {
            obatList = List<Map<String, dynamic>>.from(data['response']);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data obat: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteObat(dynamic idObat) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var accessToken = prefs.getString('access_token');

      String obatId = idObat.toString();

      var response = await http.delete(
        Uri.parse('${base_url}api/Obat/hapus_obat/$obatId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['message']['status'] == 200) {
          await loadObat();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(jsonResponse['message']['message']),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception(jsonResponse['message']['message']);
        }
      } else {
        throw Exception('Gagal menghapus data obat');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus data obat: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: isLoading 
        ? Center(
            child: Lottie.asset(
              'assets/lottie/main_loading.json',
              width: 200,
              height: 200,
            ),
          )
        : obatList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lottie.asset(
                  //   'assets/lottie/empty.json',
                  //   width: 200,
                  //   height: 200,
                  // ),
                  Text(
                    'Belum ada data obat',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: obatList.length,
              itemBuilder: (context, index) {
                final obat = obatList[index];
                return Card(
                  elevation: 1,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  margin: EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        obat['nama_obat'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            '${obat['dosis']} ${obat['satuan']}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.white,
                        elevation: 3,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: PrimaryColor),
                                SizedBox(width: 12),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red[400]),
                                SizedBox(width: 12),
                                Text(
                                  'Hapus',
                                  style: TextStyle(
                                    color: Colors.red[400],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) async {
                          if (value == 'delete') {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: Text(
                                  'Konfirmasi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                content: Text(
                                  'Apakah Anda yakin ingin menghapus obat ini?',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text(
                                      'Batal',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                    child: Text(
                                      'Hapus',
                                      style: TextStyle(
                                        color: Colors.red[400],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      var idObat = obat['id_obat'];
                                      if (idObat != null) {
                                        deleteObat(idObat);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          } else if (value == 'edit') {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditObat(obat: obat),
                              ),
                            );
                            
                            if (result == true) {
                              loadObat();
                            }
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
} 