import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:skysoft_bus/screens/roots/splash_screen.dart';
import 'package:skysoft_bus/utils/global.dart';

import '../../models/tab_item.dart';
import '../../utils/page_router.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  List<TabItem> tabs = [];
  late PageController pageController = PageController();

  final Connectivity connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? connectivitySub;
  bool isNoInternetDialogShowing = false;
  bool wasOffline = false;

  void changePage(int index) {
    if (selectedIndex == index) return;
    setState(() {
      selectedIndex = index;
    });
    pageController.jumpToPage(index);
  }

  Future<void> checkInitialConnectivity() async {
    final result = await connectivity.checkConnectivity();
    _handleConnectivityChange(result);
  }

  void _handleConnectivityChange(List<ConnectivityResult> result) {
    final bool hasConnection =
        !result.contains(ConnectivityResult.none) && result.isNotEmpty;

    if (!hasConnection) {
      wasOffline = true;
      _showNoInternetDialog();
    } else {
      _dismissNoInternetDialog();

      if (wasOffline) {
        wasOffline = false;
        _reloadApp();
      }
    }
  }

  Future<void> _reloadApp() async {
    if (loginResponse.fullName.isEmpty) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => SplashScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showNoInternetDialog() {
    if (isNoInternetDialogShowing || !mounted) return;
    isNoInternetDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.redAccent),
                SizedBox(width: 10),
                Text("Đang kết nối..."),
              ],
            ),
            content: const Text(
              "Vui lòng kiểm tra kết nối Wi-Fi hoặc dữ liệu di động của bạn và thử lại.",
            ),
          ),
        );
      },
    );
  }

  void _dismissNoInternetDialog() {
    if (!isNoInternetDialogShowing || !mounted) return;
    isNoInternetDialogShowing = false;
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void initState() {
    super.initState();
    tabs = getPages().values.toList();
    checkInitialConnectivity();
    connectivitySub = connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
    );
  }

  @override
  void dispose() {
    connectivitySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const navBarHeight = 60.0;
    const navBarMargin = 10.0;
    final totalNavSpace = navBarHeight + navBarMargin * 2;

    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: Stack(
        children: [
          MediaQuery(
            data: mediaQuery.copyWith(
              padding: mediaQuery.padding.copyWith(
                bottom: mediaQuery.padding.bottom + totalNavSpace,
              ),
            ),
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              onPageChanged: (index) {
                setState(() => selectedIndex = index);
              },
              children: tabs.map((e) => e.page).toList(),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.all(navBarMargin),
                child: Container(
                  height: navBarHeight,
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: List.generate(tabs.length, (index) {
                      final item = tabs[index];
                      final isSelected = index == selectedIndex;
                      return Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => changePage(index),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? secondaryColor.withValues(alpha: 0.1)
                                    : Colors.white60,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 22,
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.grey.shade500,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.label,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
