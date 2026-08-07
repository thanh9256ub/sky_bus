// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
// import 'package:skysoft_bus/screens/roots/add_card_screen.dart';
// import 'package:skysoft_bus/screens/widgets/extend_card_dialog.dart';
// import 'package:skysoft_bus/utils/global.dart';

// class CheckTicketScreen extends StatefulWidget {
//   const CheckTicketScreen({super.key});

//   @override
//   State<CheckTicketScreen> createState() => _CheckTicketScreenState();
// }

// class TicketHistory {
//   final String dateRange;
//   final String route;
//   final String station;
//   final String timestamp;
//   final String code;

//   TicketHistory({
//     required this.dateRange,
//     required this.route,
//     required this.station,
//     required this.timestamp,
//     required this.code,
//   });
// }

// class _CheckTicketScreenState extends State<CheckTicketScreen> {
//   final List<TicketHistory> history = [
//     TicketHistory(
//       dateRange: '16/03/2026 -> 31/05/2026',
//       route: '06: Thái Nguyên - Định Hóa',
//       station: 'Tòa án Tỉnh -> Định Hóa',
//       timestamp: '16/03/2026 11:43:27',
//       code: 'dmsks_echeck1',
//     ),
//     TicketHistory(
//       dateRange: '02/02/2026 -> 28/02/2026',
//       route: '06: Thái Nguyên - Định Hóa',
//       station: 'Tòa án Tỉnh -> Định Hóa',
//       timestamp: '02/02/2026 09:09:01',
//       code: 'dmsks_echeck',
//     ),
//     TicketHistory(
//       dateRange: '20/11/2025 -> 31/12/2025',
//       route: '06: Thái Nguyên - Định Hóa',
//       station: 'Tòa án Tỉnh -> Định Hóa',
//       timestamp: '20/11/2025 08:44:30',
//       code: 'dmsks_echeck',
//     ),
//     TicketHistory(
//       dateRange: '16/03/2026 -> 31/05/2026',
//       route: '06: Thái Nguyên - Định Hóa',
//       station: 'Tòa án Tỉnh -> Định Hóa',
//       timestamp: '16/03/2026 11:43:27',
//       code: 'dmsks_echeck1',
//     ),
//     TicketHistory(
//       dateRange: '02/02/2026 -> 28/02/2026',
//       route: '06: Thái Nguyên - Định Hóa',
//       station: 'Tòa án Tỉnh -> Định Hóa',
//       timestamp: '02/02/2026 09:09:01',
//       code: 'dmsks_echeck',
//     ),
//     TicketHistory(
//       dateRange: '20/11/2025 -> 31/12/2025',
//       route: '06: Thái Nguyên - Định Hóa',
//       station: 'Tòa án Tỉnh -> Định Hóa',
//       timestamp: '20/11/2025 08:44:30',
//       code: 'dmsks_echeck',
//     ),
//   ];

//   void initNFC() async {
//     NFCAvailability availability = await FlutterNfcKit.nfcAvailability;
//     if (availability == NFCAvailability.available) {
//       FlutterNfcKit.tagStream.listen((tag) {
//         log(tag.id);
//         // if (tag.type == NFCTagType.mifare_classic) {
//         //   lookupNfcCard(nfcHexToDecimal(tag.id));
//         // }
//       });
//     }
//   }

//   void showEtdCardDialog() async {
//     await showDialog(
//       context: context,
//       builder: (context) => ExtendCardDialog(),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     initNFC();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: secondaryColor,
//         elevation: 0,
//         centerTitle: true,
//         title: const Text(
//           'Kiểm tra thẻ',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {
//               Navigator.of(
//                 context,
//               ).push(MaterialPageRoute(builder: (context) => AddCardScreen()));
//             },
//             icon: Icon(Icons.add, color: Colors.white),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           _buildCardInfoSection(),
//           Expanded(
//             child: ListView.separated(
//               padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//               itemCount: history.length,
//               separatorBuilder: (context, index) {
//                 return SizedBox(height: 10);
//               },
//               itemBuilder: (context, index) => _buildTicketCard(history[index]),
//             ),
//           ),
//           _buildBottomActions(),
//         ],
//       ),
//     );
//   }

//   Widget _buildCardInfoSection() {
//     return Container(
//       margin: EdgeInsets.all(10),
//       padding: EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         color: secondaryColor,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.blue.withValues(alpha: 0.25),
//             blurRadius: 12,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Stack(
//             children: [
//               Container(
//                 width: 100,
//                 height: 120,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Icon(Icons.wifi),
//                 ),
//               ),
//               Positioned(
//                 bottom: 4,
//                 right: 4,
//                 child: InkWell(
//                   onTap: () {},
//                   child: Container(
//                     padding: EdgeInsets.all(6),
//                     decoration: BoxDecoration(
//                       color: Color(0xFF2F80ED),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.camera_alt,
//                       size: 16,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 8),
//                 _infoRow(
//                   "Tên",
//                   "Chu Hoàng Tuấn",
//                   GestureDetector(
//                     onTap: () {},
//                     child: Icon(Icons.edit, size: 16, color: Colors.white),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 _infoRow("Mã thẻ", "0528ec88000104e0", SizedBox()),
//                 SizedBox(height: 10),
//                 _infoRow(
//                   "Điện thoại",
//                   "******5959",
//                   GestureDetector(
//                     onTap: () {},
//                     child: Icon(Icons.call, size: 16, color: Colors.white),
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 Text(
//                   "Thẻ miễn phí chính sách",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Icon(Icons.circle, color: Colors.green.shade300),
//         ],
//       ),
//     );
//   }

//   Widget _buildTicketCard(TicketHistory item) {
//     return Container(
//       padding: EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade200,
//             blurRadius: 4,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.credit_card, size: 18, color: Colors.black54),
//               SizedBox(width: 6),
//               Text(
//                 item.dateRange,
//                 style: TextStyle(fontSize: 13, color: Colors.black87),
//               ),
//               Spacer(),
//               Icon(Icons.copy_outlined, size: 18, color: Colors.black45),
//             ],
//           ),
//           SizedBox(height: 6),
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   item.route,
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//                 ),
//               ),
//               Icon(Icons.lock_open, size: 18, color: Colors.green),
//             ],
//           ),
//           SizedBox(height: 10),
//           Text(
//             item.station,
//             style: TextStyle(fontSize: 13, color: Colors.black54),
//           ),
//           SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 item.timestamp,
//                 style: TextStyle(fontSize: 12, color: Colors.black45),
//               ),
//               Text(
//                 item.code,
//                 style: TextStyle(fontSize: 12, color: Colors.black45),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomActions() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       color: Colors.white,
//       child: Row(
//         children: [
//           _actionButton('Khóa thẻ', Icons.lock_outline, onPressed: () {}),
//           SizedBox(width: 8),
//           _actionButton('Chỉnh sửa', Icons.edit_outlined, onPressed: () {}),
//           SizedBox(width: 8),
//           _actionButton(
//             'Gia hạn thẻ',
//             Icons.autorenew,
//             onPressed: showEtdCardDialog,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _actionButton(
//     String label,
//     IconData icon, {
//     required Function() onPressed,
//   }) {
//     return Expanded(
//       child: ElevatedButton.icon(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: secondaryColor,
//           padding: EdgeInsets.symmetric(vertical: 10),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         ),
//         label: Text(
//           label,
//           style: TextStyle(fontSize: 12, color: Colors.white),
//           overflow: TextOverflow.ellipsis,
//         ),
//         onPressed: onPressed,
//         icon: Icon(icon, size: 16, color: Colors.white),
//       ),
//     );
//   }

//   Widget _infoRow(String title, String value, Widget widget) {
//     return Row(
//       children: [
//         Text("$title:", style: TextStyle(color: Colors.white, fontSize: 12)),
//         SizedBox(width: 5),
//         Text(
//           value,
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//             fontSize: 12,
//           ),
//           overflow: TextOverflow.ellipsis,
//         ),
//         SizedBox(width: 5),
//         widget,
//       ],
//     );
//   }
// }
