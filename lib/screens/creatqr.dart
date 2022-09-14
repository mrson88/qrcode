// import 'dart:typed_data';
// import 'dart:ui';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:barcode_widget/barcode_widget.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
//
// class CreateScreen extends StatefulWidget {
//   @override
//   _CreateScreenState createState() => _CreateScreenState();
// }
//
// class _CreateScreenState extends State<CreateScreen> {
//   String qrString = "Add Data";
//   GlobalKey globalKey = GlobalKey();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Create QR Code"),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           // qr code
//           BarcodeWidget(
//             color: Colors.blue,
//             data: qrString,
//             height: 250,
//             width: 250,
//             barcode: Barcode.qrCode(),
//           ),
//           // link
//           Container(
//             width: MediaQuery.of(context).size.width * .8,
//             child: TextField(
//               onChanged: (val) {
//                 setState(() {
//                   qrString = val;
//                 });
//               },
//               decoration: InputDecoration(
//                 hintText: "Enter you data here",
//                 border: OutlineInputBorder(
//                   borderSide: BorderSide(
//                     color: Colors.blue,
//                     width: 2,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             width: MediaQuery.of(context).size.width,
//           ),
//           ElevatedButton(
//               onPressed: () async {
//                 await _captureAndSharePng();
//               },
//               child: Text('Save'))
//         ],
//       ),
//     );
//   }
//
//   Future<void> _captureAndSharePng() async {
//     try {
//       RenderRepaintBoundary? boundary = globalKey.currentContext
//           ?.findRenderObject() as RenderRepaintBoundary?;
//       var image = await boundary!.toImage();
//       ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
//       Uint8List pngBytes = byteData!.buffer.asUint8List();
//
//       final tempDir = await getTemporaryDirectory();
//       String file_name = '${tempDir.path}/image.png';
//       final file = await File(file_name).create();
//       await file.writeAsBytes(pngBytes);
//
//       final channel = const MethodChannel('channel:me.alfian.share/share');
//       channel.invokeMethod('shareFile', 'image.png');
//       print('file da duoc luu tai: $file_name');
//     } catch (e) {
//       print(e.toString());
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

class QrCode extends StatefulWidget {
  const QrCode({Key? key}) : super(key: key);

  @override
  State<QrCode> createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode> {
  final _screenshotController = ScreenshotController();
  Future<Image>? image;
  String qrString = "Add Data";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create QR Code"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (image != null)
            Center(
                child: Screenshot(
                    controller: _screenshotController,
                    child: _buildQRImage(qrString))),
          ElevatedButton(
              onPressed: () async {
                await _captureAndSaveQRCode();
              },
              child: const Text("Capture qr code")),
          Container(
            width: MediaQuery.of(context).size.width * .8,
            child: TextField(
              onChanged: (val) {
                setState(() {
                  qrString = val;
                });
              },
              decoration: InputDecoration(
                hintText: "Enter you data here",
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRImage(String data) {
    return QrImage(
      data: data,
      size: 250.0,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.H,
      gapless: false,
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
    );
  }

  Future<String> get imagePath async {
    final directory = (await getApplicationDocumentsDirectory()).path;
    return '$directory/qr.png';
  }

  Future<Image> _loadImage() async {
    return await imagePath.then((imagePath) => Image.asset(imagePath));
  }

  Future<void> _captureAndSaveQRCode() async {
    final imageDirectory = await imagePath;

    _screenshotController.captureAndSave(imageDirectory);
    setState(() {
      image = _loadImage();
      print(imageDirectory);
    });
  }

  @override
  void initState() {
    image = _loadImage();
    super.initState();
  }
}
