import 'package:flutter/material.dart';
import 'package:skysoft_bus/screens/profile/profile_screen.dart';
import 'package:skysoft_bus/screens/ticket/ticket_list_screen.dart';
import 'package:skysoft_bus/utils/global.dart';

import '../models/tab_item.dart';
import '../screens/home/home_screen_v2.dart';
import 'fields.dart';

Map<String, TabItem> getPages() {
  return {
    HOME_TAB: TabItem(
      icon: Icons.explore,
      label: 'Trang chủ',
      module: "",
      page: HomeScreenV2(),
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
}
