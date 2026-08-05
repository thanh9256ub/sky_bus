import 'package:flutter/material.dart';
import 'package:skysoft_bus/screens/roots/home_screen.dart';
import 'package:skysoft_bus/screens/roots/profile_screen.dart';

import '../models/tab_item.dart';
import 'fields.dart';

Map<String, TabItem> pages = {
  HOME_TAB: TabItem(
    icon: Icons.explore,
    label: 'Trang chủ',
    module: "",
    page: HomeScreen(),
  ),
  PROFILE_TAB: TabItem(
    icon: Icons.account_circle_outlined,
    label: 'Tài khoản',
    module: "",
    page: ProfileScreen(),
  ),
};
