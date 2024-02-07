import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vcard_maintained/vcard_maintained.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _orgController = TextEditingController();
  final _positionController = TextEditingController();
  final _workUrlController = TextEditingController();
  final _qrKey = GlobalKey();

  String _vCardData = '';
  bool _showQRCode = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> requestPermissions() async {
    await Permission.storage.request();
  }

  Future<void> _exportQrCode() async {

    await requestPermissions();


      // Get the RenderRepaintBoundary for the QR code widget
      final boundary =
      _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // Capture the QR code as an image
      final image =
      await boundary.toImage(pixelRatio: 3.0); // For higher resolution

      // Convert the image to bytes
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();
    try {
      if (pngBytes != null) {
        // Get the external storage directory
        final directory = await getApplicationDocumentsDirectory();

        // Create a unique filename
        final filename =
            DateTime
                .now()
                .millisecondsSinceEpoch
                .toString() + '.png';
        final file = await File('${directory!.path}/$filename').create();
        print(file.path);
        // Save the QR code as a PNG image
        //await file.writeAsBytes(pngBytes);

        await GallerySaver.saveImage(file.path);

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR code exported successfully!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error exporting QR code'),
          ),
        );
      }
    } catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text('Error exporting QR code: ${e.toString()}'),
        ),
      );
    }
  }

  void _generateVCardAndShowQRCode() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final vCard = VCard();
      vCard.firstName = _firstNameController.text;
      vCard.lastName = _lastNameController.text;
      vCard.workPhone = _phoneController.text;
      vCard.workEmail = _emailController.text;
      vCard.organization = _orgController.text;
      vCard.role = _positionController.text;
      vCard.jobTitle = _positionController.text;
      vCard.workUrl = _workUrlController.text;

      _vCardData = ''; // Clear previous data
      _vCardData = vCard
          .getFormattedString(); // Generate vCard string with proper version (3.0)
      setState(() {
        _showQRCode = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    hintText: 'Enter your first name',
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    hintText: 'Enter your last name',
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your email address',
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _orgController,
                  decoration: const InputDecoration(
                    labelText: 'Organization',
                    hintText: 'Enter your organization name',
                  ),
                ),
                TextFormField(
                  controller: _positionController,
                  decoration: const InputDecoration(
                    labelText: 'Position',
                    hintText: 'Enter your position',
                  ),
                ),
                TextFormField(
                  controller: _workUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Work Website',
                    hintText: 'Enter your work website',
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _generateVCardAndShowQRCode,
                  child: const Text('Generate QR Code'),
                ),
                const SizedBox(height: 20.0),
                Visibility(
                  visible: _showQRCode,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: _exportQrCode,
                        child: const Text('Export'),
                      ),
                      RepaintBoundary(
                        key: _qrKey,
                        child: QrImageView(

                          data:
                              _vCardData, // This should contain your generated vCard string
                          backgroundColor: Colors
                              .white, // Customize background color (optional)
                          version:
                              QrVersions.auto, // Automatically choose QR version
                          errorCorrectionLevel: QrErrorCorrectLevel
                              .Q, // High error correction level
                          gapless: false,
                          size: 320,
                          embeddedImage: const AssetImage('assets/Asset_7.png'),
                          embeddedImageStyle: const QrEmbeddedImageStyle(
                            size: Size(120, 80),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
