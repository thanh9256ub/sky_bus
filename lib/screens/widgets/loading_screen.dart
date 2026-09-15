import 'package:flutter/material.dart';
import 'package:skysoft_bus/utils/global.dart';

class LoadingOverlay extends StatelessWidget {
  final bool visible;
  final Widget child;
  final String textLoad;
  const LoadingOverlay({
    super.key,
    required this.visible,
    required this.child,
    this.textLoad = "Đang tải",
  });

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: visible,
      child: Stack(
        children: [
          child,
          Visibility(
            visible: visible,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
              ),
              child:
                  // Center(
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [CircularProgressIndicator(color: secondaryColor)],
                  //   ),
                  // ),
                  loadingWidget(textLoad),
            ),
          ),
        ],
      ),
    );
  }
}

Widget loadingWidget(String textLoad) {
  return Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: secondaryColor),
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(textLoad, style: const TextStyle(fontSize: 18)),
        ),
      ],
    ),
  );
}
