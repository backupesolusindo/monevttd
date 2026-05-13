import 'package:flutter/material.dart';
import 'package:monitoringobat/util/colors.dart';
import 'package:monitoringobat/util/core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:monitoringobat/model/user.dart';
import 'package:lottie/lottie.dart';
import 'package:monitoringobat/jadwal/edit_jadwal.dart';
import 'package:monitoringobat/util/alarm_service.dart';

class KelolaJadwal extends StatefulWidget {
  @override
  _KelolaJadwalState createState() => _KelolaJadwalState();
}

class _KelolaJadwalState extends State<KelolaJadwal> {
  List<Map<String, dynamic>> jadwalList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadJadwal();
  }

  Future<void> loadJadwal() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      var userDataString = prefs.getString('user_data');
      var accessToken = prefs.getString('access_token');

      if (userDataString == null) throw Exception('Data user tidak ditemukan');

      final userData = UserData.fromJson(json.decode(userDataString));

      var response = await http.get(
        Uri.parse(
            '${base_url}api/JadwalObat/list_jadwal?id_user=${userData.idUser}'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['message']['status'] == 200) {
          setState(() {
            jadwalList = List<Map<String, dynamic>>.from(data['response']);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat jadwal: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteJadwal(dynamic idJadwal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var accessToken = prefs.getString('access_token');

      String jadwalId = idJadwal.toString();

      var response = await http.delete(
        Uri.parse('${base_url}api/JadwalObat/hapus_jadwal/$jadwalId'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['message']['status'] == 200) {
          // Batalkan alarm untuk jadwal yang dihapus
          final int idJadwal = int.tryParse(jadwalId) ?? 0;
          if (idJadwal > 0) await AlarmService.cancelAlarm(idJadwal);

          await loadJadwal(); // Refresh list
          if (!mounted) return;
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
        throw Exception('Gagal menghapus jadwal');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus jadwal: ${e.toString()}'),
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
          : jadwalList.isEmpty
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
                        'Belum ada jadwal minum obat',
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
                  itemCount: jadwalList.length,
                  itemBuilder: (context, index) {
                    final jadwal = jadwalList[index];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[200]!),
                      ),
                      margin: EdgeInsets.only(bottom: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            '${jadwal['nama_obat']} - ${jadwal['dosis']} ${jadwal['satuan']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 12),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: PrimaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 16, color: PrimaryColor),
                                    SizedBox(width: 8),
                                    Text(
                                      jadwal['hari'],
                                      style: TextStyle(
                                        color: PrimaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.access_time,
                                      size: 16, color: Colors.grey[600]),
                                  SizedBox(width: 8),
                                  Text(
                                    jadwal['waktu'],
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            icon:
                                Icon(Icons.more_vert, color: Colors.grey[600]),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: PrimaryColor,
                            elevation: 3,
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Colors.white),
                                    SizedBox(width: 12),
                                    Text(
                                      'Edit',
                                      style: TextStyle(
                                        color: Colors.white,
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
                                    Icon(Icons.delete, color: Colors.white),
                                    SizedBox(width: 12),
                                    Text(
                                      'Hapus',
                                      style: TextStyle(
                                        color: Colors.white,
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
                                      'Apakah Anda yakin ingin menghapus jadwal ini?',
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
                                          var idJadwal = jadwal['id_jadwal'];
                                          if (idJadwal != null) {
                                            deleteJadwal(idJadwal);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'ID Jadwal tidak valid'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
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
                                    builder: (context) =>
                                        EditJadwal(jadwal: jadwal),
                                  ),
                                );

                                if (result == true) {
                                  loadJadwal(); // Refresh list setelah edit
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
