import 'dart:async';
import 'dart:convert';

import 'package:calendar/components/buttons/primary_button.dart';
import 'package:calendar/components/text/h1.dart';
import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/util/consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:frccblue/frccblue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:realm/realm.dart';

class TokenInput extends StatefulWidget {
  final Future<void> Function(String) onSubmit;
  final bool inverseColor;

  const TokenInput(
      {Key? key, required this.onSubmit, this.inverseColor = false})
      : super(key: key);

  @override
  State<TokenInput> createState() => _TokenInputState();
}

class _TokenInputState extends State<TokenInput> {
  final TextEditingController _controller = TextEditingController();
  // final FocusNode _textNode = FocusNode();
  String token = '';
  String? error;
  bool isLoading = false;

  // final flutterReactiveBle = FlutterReactiveBle();
  // StreamSubscription<BleStatus>? bleStatusListener;
  // BleStatus? bleStatus;
  // String? bleErrorStatusStr;

  // @override
  // void initState() {
  //   Timer(const Duration(seconds: 1), () {
  //     listenForBluetoothState();
  //   });
  //   super.initState();
  // }

  // @override
  // void dispose() {
  //   Frccblue.stopPeripheral();
  //   bleStatusListener?.cancel();
  //   super.dispose();
  // }

  // void listenForBluetoothState() {
  //   bleStatusListener = flutterReactiveBle.statusStream.listen((status) {
  //     setState(() => bleStatus = status);

  //     switch (status) {
  //       case BleStatus.poweredOff:
  //         setState(() => bleErrorStatusStr =
  //             'Bluetooth is turned off. Please turn it on if you\'d like to recieve an invite code from nearby devices.');
  //         break;
  //       case BleStatus.ready:
  //         setState(() => bleErrorStatusStr = null);
  //         initPlatformState();
  //         break;
  //       case BleStatus.unauthorized:
  //         setState(() => bleErrorStatusStr =
  //             'The app does not have permission to use bluetooth. Please enable it in settings if you\'d like to recieve an invite code from nearby devices.');
  //         break;
  //       case BleStatus.unsupported:
  //         setState(() =>
  //             bleErrorStatusStr = 'This device does not support bluetooth.');
  //         break;
  //       default:
  //     }
  //   });
  // }

  // TODO
  // Future<void> _requestPermissions() async {
  //   final Map<Permission, PermissionStatus> statuses = await [
  //     Permission.bluetooth,
  //     Permission.bluetoothAdvertise,
  //     Permission.location,
  //   ].request();
  //   for (final status in statuses.keys) {
  //     if (statuses[status] == PermissionStatus.granted) {
  //       debugPrint('$status permission granted');
  //     } else if (statuses[status] == PermissionStatus.denied) {
  //       debugPrint(
  //         '$status denied. Show a dialog with a reason and again ask for the permission.',
  //       );
  //     } else if (statuses[status] == PermissionStatus.permanentlyDenied) {
  //       // openAppSettings();
  //       debugPrint(
  //         '$status permanently denied. Take the user to the settings page.',
  //       );
  //     }
  //   }
  // }

  // Future<void> initPlatformState() async {
  //   Frccblue.init(didReceiveWrite: (MethodCall call) {
  //     setState(() {
  //       token = utf8.decode(call.arguments['data']);
  //     });

  //     handleSubmit();
  //   });

  //   Frccblue.startPeripheral(
  //       bluetoothServiceId.toString(), bluetoothCharacteristicId.toString());
  // }

  void onTokenInput(String value) {
    setState(() {
      token = value.toUpperCase();
    });
  }

  void handleSubmit() async {
    try {
      setState(() {
        error = null;
        isLoading = true;
      });
      await widget.onSubmit(token);
      setState(() => isLoading = false);
    } on AppException catch (err) {
      setState(() {
        error = err.message;
        isLoading = false;
      });
    }
  }

  List<Widget> getField() {
    final List<Widget> result = <Widget>[];
    for (int i = 1; i <= 8; i++) {
      result.add(Column(
        children: <Widget>[
          if (token.length >= i)
            H1(
              token[i - 1],
              large: true,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 5.0,
            ),
            child: Container(
              height: 3.0,
              width: (300 / 9 - 5),
              color: const Color.fromRGBO(0, 69, 77, 1),
            ),
          ),
        ],
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: <Widget>[
              const H1(
                'Join Team',
                large: true,
              ),
              const SizedBox(
                height: 20,
              ),
              if (!isLoading)
                Column(
                  children: [
                    const H1('Receive token automatically from nearby devices',
                        center: true),
                    const SizedBox(height: 24),
                    // if (bleStatus == BleStatus.ready)
                    //   Column(children: [
                    //     Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         SizedBox(
                    //           height: 16,
                    //           width: 16,
                    //           child: CircularProgressIndicator(
                    //             color: theme.primaryColor,
                    //           ),
                    //         ),
                    //         const Flexible(
                    //             child: Padding(
                    //                 padding: EdgeInsets.only(left: 8),
                    //                 child:
                    //                     Paragraph("Searching for devices."))),
                    //       ],
                    //     ),
                    //     const SizedBox(height: 16),
                    //     const Paragraph(
                    //         "Make sure the app is open on your other device, you are on the \"Generate Invite Token\" page, and you have generated a new token.",
                    //         center: true),
                    //   ]),
                    // if (bleErrorStatusStr != null)
                    //   Paragraph(bleErrorStatusStr!,
                    //       center: true, color: Colors.red),
                    // if (bleStatus == BleStatus.unauthorized)
                    //   SizedBox(
                    //       width: 200,
                    //       child: PrimaryButton(
                    //           small: true,
                    //           child: const Paragraph('Open App Settings',
                    //               small: true),
                    //           onPressed: () => openAppSettings())),
                    // const SizedBox(height: 56),
                    // const H1('Or enter your 8 digit invite token manually',
                    //     center: true),
                    const H1('Enter your 8 digit invite token', center: true),
                  ],
                ),
              if (error != null) const SizedBox(height: 20),
              if (error != null)
                Text(
                  'Error: ${error!}',
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              SizedBox(
                height: 90,
                width: 320,
                child: Stack(
                  children: <Widget>[
                    Opacity(
                      opacity: 1,
                      child: TextFormField(
                        controller: _controller,
                        // autofocus: true,
                        textCapitalization: TextCapitalization.characters,
                        onChanged: onTokenInput,
                        maxLength: 8,
                        autocorrect: false,
                        showCursor: false,
                        style: const TextStyle(color: Colors.transparent),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: getField(),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                  width: 300,
                  child: PrimaryButton(
                      onPressed: handleSubmit,
                      isLoading: isLoading,
                      color: widget.inverseColor ? Colors.white : null,
                      child: const Paragraph('Join Team'))),
              const SizedBox(height: 56),
            ],
          )),
    );
  }
}
