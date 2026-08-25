import 'package:flutter/material.dart';

class TicketDivider extends StatelessWidget {
  const TicketDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
          ),
        ),

        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final dashCount = (constraints.maxWidth / 10).floor();

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  dashCount,
                  (_) => Container(
                    width: 6,
                    height: 1.5,
                    color: Colors.grey.shade400,
                  ),
                ),
              );
            },
          ),
        ),

        Container(
          width: 12,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
          ),
        ),
      ],
    );
  }
}
