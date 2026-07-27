import 'package:flutter/material.dart';
import 'package:skysoft_bus/screens/roots/check_ticket_screen.dart';
import 'package:skysoft_bus/screens/roots/home_screen.dart';
import 'package:skysoft_bus/screens/roots/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool hasLocation = false;
  String address = "";
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    CheckTicketScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade400)),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            backgroundColor: Colors.white,
            currentIndex: _selectedIndex,
            onTap: (value) {
              setState(() {
                _selectedIndex = value;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.confirmation_number_outlined),
                label: 'Thẻ tháng',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_outlined),
                label: 'Tài khoản',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
