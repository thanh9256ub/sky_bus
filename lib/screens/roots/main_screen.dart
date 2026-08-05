import 'package:flutter/material.dart';

import '../../models/tab_item.dart';
import '../../utils/global.dart';
import '../../utils/page_router.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  List<TabItem> tabs = [];
  void changePage(int index) {
    if (selectedIndex == index) return;
    setState(() {
      selectedIndex = index;
    });
    pageViewController.jumpToPage(index);
  }

  @override
  void initState() {
    super.initState();
    tabs = pages.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: pageViewController,
        onPageChanged: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        children: tabs.map((e) => e.page).toList(),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade400)),
          ),
          child: BottomNavigationBar(
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            backgroundColor: Colors.white,
            currentIndex: selectedIndex,
            onTap: changePage,
            items: List.generate(tabs.length, (index) {
              final item = tabs[index];
              return BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              );
            }),
          ),
        ),
      ),
    );
  }
}
