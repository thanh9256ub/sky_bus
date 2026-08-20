import 'package:flutter/material.dart';

import '../../utils/global.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.21,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [secondaryColor, secondaryColor.withValues(alpha: 0.5)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white24,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white24,
              ),
            ),
          ),
          Positioned(
            top: 24,
            right: 30,
            child: Transform.rotate(
              angle: -0.2,
              child: Icon(
                Icons.directions_bus_rounded,
                size: 30,
                color: Colors.white24,
              ),
            ),
          ),
          Positioned(
            top: -30,
            left: 30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white24,
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 80,
            child: Transform.rotate(
              angle: -0.2,
              child: Icon(
                Icons.directions_car_filled,
                size: 30,
                color: Colors.white24,
              ),
            ),
          ),
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Xin chào",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          Positioned(
            top: 110,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                loginResponse.fullName,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          Positioned(
            bottom: -45,
            right: 10,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white24,
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            right: 50,
            child: Icon(
              Icons.airport_shuttle_sharp,
              size: 24,
              color: Colors.white24,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Icon(Icons.route_rounded, size: 24, color: Colors.white24),
          ),
        ],
      ),
    );
  }
}
