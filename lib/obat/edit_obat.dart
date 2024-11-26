import 'package:flutter/material.dart';
import 'package:monitoringobat/util/colors.dart';
import 'package:monitoringobat/util/core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditObat extends StatefulWidget {
  final Map<String, dynamic> obat;
  
  EditObat({required this.obat});
  
  @override
  _EditObatState createState() => _EditObatState();
}

class _EditObatState extends State<EditObat> {
  final _formKey = GlobalKey<FormState>();
  final _namaObatController = TextEditingController();
  final _dosisController = TextEditingController();
  String? selectedUnit;
  List<String> units = ['Tablet', 'Pack'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaObatController.text = widget.obat['nama_obat'];
    _dosisController.text = widget.obat['dosis'].toString();
    selectedUnit = widget.obat['satuan'];
  }

  Future<void> _updateObat() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final prefs = await SharedPreferences.getInstance();
        var accessToken = prefs.getString('access_token');

        if (accessToken == null) {
          throw Exception('Token tidak ditemukan');
        }

        double dosis = double.parse(_dosisController.text);
        if (dosis <= 0) {
          throw Exception('Dosis harus lebih dari 0');
        }

        var response = await http.put(
          Uri.parse('${base_url}api/Obat/edit_obat'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'id_obat': widget.obat['id_obat'].toString(),
            'nama_obat': _namaObatController.text.trim(),
            'dosis': dosis.toString(),
            'satuan': selectedUnit,
          },
        );

        var jsonResponse = json.decode(response.body);
        
        if (jsonResponse['message']['status'] == 200) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(jsonResponse['message']['message']),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception(jsonResponse['message']['message']);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Edit Obat',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: PrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _namaObatController,
                decoration: InputDecoration(
                  labelText: 'Nama Obat',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelStyle: TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon isi nama obat';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _dosisController,
                      decoration: InputDecoration(
                        labelText: 'Dosis Obat',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        labelStyle: TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mohon isi dosis obat';
                        }
                        try {
                          double dosis = double.parse(value);
                          if (dosis <= 0) {
                            return 'Dosis harus lebih dari 0';
                          }
                        } catch (e) {
                          return 'Masukkan angka yang valid';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Satuan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        labelStyle: TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      value: selectedUnit,
                      dropdownColor: Colors.white,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      items: units.map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(
                            unit,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedUnit = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Pilih satuan';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateObat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PrimaryColor,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'SIMPAN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaObatController.dispose();
    _dosisController.dispose();
    super.dispose();
  }
} 