// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monitoringobat/util/colors.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key, this.selected = 0}) : super(key: key);

  final int selected;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selected;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/riwayat');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/notifikasi');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/menu');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, ''),
              _buildNavItem(1, Icons.history, ''),
              _buildNavItem(2, Icons.notifications, ''),
              _buildNavItem(3, Icons.menu, ''),
            ],
          ),
          Positioned(
            top: -30,
            left: MediaQuery.of(context).size.width / 4 * _selectedIndex,
            child: _buildSelectedItem(_selectedIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(height: isSelected ? 30 : 0),
              if (!isSelected) Icon(icon, color: Colors.grey),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? PrimaryColor : Colors.grey,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedItem(int index) {
    List<IconData> icons = [
      Icons.home_rounded,
      Icons.history,
      Icons.notifications,
      Icons.menu,
    ];
    return Container(
      width: MediaQuery.of(context).size.width / 4,
      child: Center(
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: PrimaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icons[index],
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}
