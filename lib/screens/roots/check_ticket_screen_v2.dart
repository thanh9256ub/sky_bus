// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
// import 'package:nfc_manager/nfc_manager.dart';

// import '../../models/ticket_model.dart';
// import '../../utils/date_utils.dart';
// import '../../utils/string_utils.dart';

// class CheckTicketScreenV2 extends StatefulWidget {
//   const CheckTicketScreenV2({super.key});

//   @override
//   State<CheckTicketScreenV2> createState() => _CheckTicketScreenV2State();
// }

// class _CheckTicketScreenV2State extends State<CheckTicketScreenV2> {
//   late BusCard busCard = BusCard("");
//   final ScrollController _controller = ScrollController();
//   bool isRequesting = false;
//   void initNFC() async {
//     NFCAvailability availability = await FlutterNfcKit.nfcAvailability;
//     if (availability == NFCAvailability.available) {
//       FlutterNfcKit.tagStream.listen((tag) {
//         if (tag.type == NFCTagType.mifare_classic) {
//           lookupNfcCard(nfcHexToDecimal(tag.id));
//         }
//       });
//     }
//   }
//   void lookupNfcCard(String cardID) async {
//     if (isRequesting) {
//       return;
//     }
//     setState(() {
//       isRequesting = true;
//     });
//     CheckInTicketResponse response =
//         await service.lookupNfcCard(selectedFacility, cardID);
//     setState(() {
//       isRequesting = false;
//     });
//     if (response.errorMessage.isEmpty) {
      
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//           'Kiểm tra thẻ',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//         ),
//       ),
//       body: Container(
//         color: Colors.white,
//         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//         child: Column(
//           children: [
//             Container(
//               width: double.infinity,
//               padding: EdgeInsets.fromLTRB(16, 16, 16, 20),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade200,
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.shade200,
//                     blurStyle: BlurStyle.outer,
//                     blurRadius: 1,
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Stack(
//                     alignment: Alignment.bottomRight,
//                     children: [
//                       Container(
//                         width: 92,
//                         height: 92,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: const [
//                             Icon(Icons.wifi, size: 32, color: Colors.black87),
//                             SizedBox(height: 4),
//                             Text(
//                               'NFC',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                                 letterSpacing: 1,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         margin: const EdgeInsets.all(4),
//                         padding: const EdgeInsets.all(4),
//                         decoration: const BoxDecoration(
//                           color: Colors.black26,
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(
//                           Icons.camera_alt,
//                           size: 16,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Mã số thẻ',
//                           style: TextStyle(color: Colors.white70, fontSize: 13),
//                         ),
//                         Row(
//                           children: const [
//                             Text(
//                               '0528ec88000104e0',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 15,
//                               ),
//                             ),
//                             SizedBox(width: 6),
//                             Icon(Icons.edit, size: 14, color: Colors.white70),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                         const Text(
//                           'Tên',
//                           style: TextStyle(color: Colors.white70, fontSize: 13),
//                         ),
//                         const Text(
//                           'CHU HOÀNG TUẤN',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 15,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         const Text(
//                           'Điện thoại',
//                           style: TextStyle(color: Colors.white70, fontSize: 13),
//                         ),
//                         Row(
//                           children: const [
//                             Text(
//                               '******5959',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             SizedBox(width: 6),
//                             Icon(Icons.phone, size: 14, color: Colors.white70),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         const Text(
//                           'Thẻ miễn phí chính sách',
//                           style: TextStyle(
//                             color: Colors.orangeAccent,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 13,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(child: _buildList())
//           ],
//         ),
//       ),
//     );
//   }
//   Widget _buildList(BusCard busCard) {
//   List<RechargeItem> filteredList = busCard.rechargeItems;
//   return ListView.builder(
//     controller: _controller,
//     itemCount: filteredList.length,
//     itemBuilder: (BuildContext context, int index) {
//       RechargeItem item = filteredList[index];
//       final matrix= item.matrixes[index];
//       return Container(
//         decoration: BoxDecoration(
//           border: Border(bottom: BorderSide(width: 1.0, color: Colors.grey.shade100)),
//         ),
//         child: ListTile(
//           minLeadingWidth: 10,
//           leading: Icon(Icons.credit_card),
//           title:Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey,
//             blurRadius: 4,
//             offset:  Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 "${item.fromDate!.formatDate} -> ${item.toDate!.formatDate}",
//                 style: const TextStyle(fontSize: 13, color: Colors.black87),
//               ),
//               const Spacer(),
//               const Icon(Icons.copy_outlined, size: 18, color: Colors.black45),
//             ],
//           ),
//           const SizedBox(height: 6),
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   matrix.lineName,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                   ),
//                 ),
//               ),
//                Icon(Icons.lock_open, size: 18, color: Colors.green),
//             ],
//           ),
//           const SizedBox(height: 2),
//           Text(
//             "${matrix.fromPlaceName} -> ${matrix.toPlaceName}",
//             style: const TextStyle(fontSize: 13, color: Colors.black54),
//           ),
//           const SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                item.createDate == null
//         ? ""
//         : item.createDate!.formatDateTime,
//                 style: const TextStyle(fontSize: 12, color: Colors.black45),
//               ),
//               Text(
//                item.creator,
//                 style: const TextStyle(fontSize: 12, color: Colors.black45),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ),
//         ),
//       );
//     },
//   );
// }
// }


