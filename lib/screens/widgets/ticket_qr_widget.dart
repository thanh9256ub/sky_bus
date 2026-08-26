import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketQrWidget extends StatefulWidget {
  final String token;

  const TicketQrWidget({super.key, required this.token});

  @override
  State<TicketQrWidget> createState() => _TicketQrWidgetState();
}

class _TicketQrWidgetState extends State<TicketQrWidget> {
  late final QrImageView qrImage;

  @override
  void initState() {
    super.initState();

    qrImage = QrImageView(data: widget.token, version: QrVersions.auto);
  }

  @override
  Widget build(BuildContext context) {
    return qrImage;
  }
}
