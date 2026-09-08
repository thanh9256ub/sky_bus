import 'package:flutter/material.dart';
import 'package:skysoft_bus/screens/home/home_screen.dart';
import 'package:skysoft_bus/screens/profile/profile_screen.dart';
import 'package:skysoft_bus/screens/ticket/ticket_list_screen.dart';
import 'package:skysoft_bus/utils/global.dart';

import '../models/tab_item.dart';
import 'fields.dart';

Map<String, TabItem> pages = {
  HOME_TAB: TabItem(
    icon: Icons.explore,
    label: 'Trang chủ',
    module: "",
    page: HomeScreen(),
  ),
  if (loginResponse.fullName.isNotEmpty)
    TICKET_TAB: TabItem(
      icon: Icons.local_activity,
      label: 'Vé',
      module: "",
      page: TicketListScreen(),
    ),
  PROFILE_TAB: TabItem(
    icon: Icons.account_circle_outlined,
    label: 'Tài khoản',
    module: "",
    page: ProfileScreen(),
  ),
};
