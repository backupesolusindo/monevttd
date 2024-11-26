// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monitoringobat/util/colors.dart';

class BottomNavBar extends StatelessWidget {
  final int selected;

  const BottomNavBar({Key? key, required this.selected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -10),
            blurRadius: 35,
            color: Color(0xFFDADADA).withOpacity(0.15),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildNavItem(context, 'Home', Icons.home, 0, '/dashboard'),
          buildNavItem(context, 'Riwayat', Icons.history, 1, '/riwayat'),
          buildNavItem(context, 'Artikel', Icons.book, 2, '/artikel'),
          buildNavItem(context, 'Kuesioner', Icons.scale, 3, '/kuesioner'),
          buildNavItem(context, 'Menu', Icons.menu, 4, '/menu'),
          // buildNavItem(context, 'Profile', Icons.person, 4, '/profile'),
        ],
      ),
    );
  }

  Widget buildNavItem(BuildContext context, String label, IconData icon, int index, String route) {
    final isSelected = selected == index;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          Navigator.pushNamed(context, route);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? PrimaryColor : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? PrimaryColor : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
