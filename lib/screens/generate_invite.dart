import 'dart:async';
import 'dart:convert';
import 'package:calendar/components/buttons/primary_button.dart';
import 'package:calendar/components/text/h1.dart';
import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/models/team_invite_model.dart';
import 'package:calendar/realm/init_realm.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:calendar/state/app_state.dart';
import 'package:calendar/util/consts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:share_plus/share_plus.dart';

const inviteTypeDescriptions = {
  'caregiver':
      'A caregiver is someone who is able to create and edit events for this team\'s dependent. This person will need to create an account and use an invite token to join the team.',
  'dependent':
      'A dependent is someone who will be using the calendar to help structure their day. There can only be one dependent per team, but you can use multiple invites to setup multiple devices for them. A dependent does not need to sign up for an account.'
};

class GenerateInvite extends StatefulWidget {
  const GenerateInvite({Key? key}) : super(key: key);

  @override
  State<GenerateInvite> createState() => _GenerateInviteState();
}

class _GenerateInviteState extends State<GenerateInvite> {
  // final flutterReactiveBle = FlutterReactiveBle();
  // StreamSubscription<DiscoveredDevice>? scanDeviceListener;
  // StreamSubscription<BleStatus>? bleStatusListener;
  // BleStatus? bleStatus;
  String? error;
  String? bleStatusErrorStr;

  String selectedInviteType = 'caregiver';
  TeamInviteModel? newInvite;
  // DiscoveredDevice? device;

  // @override
  // void initState() {
  //   listenForBluetoothState();
  //   super.initState();
  // }

  // @override
  // void dispose() {
  //   scanDeviceListener?.cancel();
  //   bleStatusListener?.cancel();
  //   super.dispose();
  // }

  // void listenForBluetoothState() {
  //   bleStatusListener = flutterReactiveBle.statusStream.listen((status) {
  //     setState(() => bleStatus = status);

  //     switch (status) {
  //       case BleStatus.poweredOff:
  //         if (scanDeviceListener != null) scanDeviceListener!.cancel();
  //         setState(() => bleStatusErrorStr =
  //             'Bluetooth is turned off. Please turn it on if you\'d like to share this code with nearby devices.');
  //         break;
  //       case BleStatus.ready:
  //         setState(() => bleStatusErrorStr = null);
  //         if (newInvite != null) scanBle();
  //         break;
  //       case BleStatus.unauthorized:
  //         setState(() => bleStatusErrorStr =
  //             'The app does not have permission to use bluetooth. Please enable it in settings if you\'d like to share this code with nearby devices.');
  //         break;
  //       case BleStatus.unsupported:
  //         setState(() =>
  //             bleStatusErrorStr = 'This device does not support bluetooth.');
  //         break;
  //       default:
  //     }
  //   });
  // }

  // void scanBle() {
  //   scanDeviceListener = flutterReactiveBle.scanForDevices(
  //       withServices: [bluetoothServiceId],
  //       scanMode: ScanMode.lowPower).listen((d) {
  //     setState(() => device = d);
  //     scanDeviceListener!.cancel();
  //     handleSendToDevice(d);
  //   }, onError: (err) {
  //     setState(() => error = err.toString());
  //   });
  // }

  // handleSendToDevice(DiscoveredDevice device) async {
  //   flutterReactiveBle
  //       .connectToAdvertisingDevice(
  //     id: device.id,
  //     withServices: [bluetoothServiceId],
  //     prescanDuration: const Duration(seconds: 5),
  //     connectionTimeout: const Duration(seconds: 2),
  //   )
  //       .listen((connectionState) async {
  //     final characteristic = QualifiedCharacteristic(
  //         serviceId: bluetoothServiceId,
  //         characteristicId: bluetoothCharacteristicId,
  //         deviceId: device.id);

  //     await flutterReactiveBle.writeCharacteristicWithResponse(characteristic,
  //         value: utf8.encode(newInvite!.token.toUpperCase()));

  //     Fluttertoast.showToast(
  //         msg: "Successfully Invited New Device",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.CENTER,
  //         timeInSecForIosWeb: 5,
  //         backgroundColor: Colors.black.withOpacity(0.8),
  //         textColor: Colors.white,
  //         fontSize: 16.0);
  //     Navigator.pop(context);
  //   }, onError: (error) {
  //     setState(() => error = error.toString());
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

  @override
  Widget build(BuildContext context) {
    final realmManager = Provider.of<RealmManager>(context, listen: true);
    final appState = Provider.of<AppState>(context, listen: true);
    final theme = Theme.of(context);

    void handleCreate() {
      // setState(() {
      //   newInvite = TeamInviteModel(realmManager.realm!,
      //       TeamInvite(ObjectId(), ObjectId(), 'caregiver', token: 'asdfjkhs'));
      // });

      final invite = TeamInviteModel.create(realmManager.realm!,
          TeamInvite(ObjectId(), appState.activeTeam!.id, selectedInviteType));

      setState(() {
        newInvite = invite;
      });

      Clipboard.setData(ClipboardData(text: invite!.token.toUpperCase()))
          .then((_) {
        Fluttertoast.showToast(
            msg: "Copied To Clipboard",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black.withOpacity(0.8),
            textColor: Colors.white,
            fontSize: 16.0);
      });

      // if (bleStatus == BleStatus.ready) scanBle();
    }

    handleShare() {
      Share.share(
          'Here is your invite token to join my visual calendar team: ${newInvite!.token.toUpperCase()}');
    }

    return Scaffold(
        appBar: AppBar(
          foregroundColor: const Color.fromRGBO(0, 69, 77, 1),
          backgroundColor: theme.backgroundColor,
          elevation: 0,
          // shape: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
        ),
        backgroundColor: theme.backgroundColor,
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  if (newInvite == null)
                    Column(children: [
                      const H1(
                        'Create Invite Token',
                        large: true,
                        center: true,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                          width: double.infinity,
                          child: CupertinoSlidingSegmentedControl(
                            backgroundColor: Colors.white,
                            thumbColor: theme.primaryColor,
                            groupValue: selectedInviteType,
                            onValueChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedInviteType = value;
                                  newInvite = null;
                                });
                              }
                            },
                            children: const {
                              'caregiver': Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  'Caregiver',
                                  style: TextStyle(
                                      color: Color.fromRGBO(0, 69, 77, 1)),
                                ),
                              ),
                              'dependent': Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  'Dependent',
                                  style: TextStyle(
                                      color: Color.fromRGBO(0, 69, 77, 1)),
                                ),
                              )
                            },
                          )),
                      const SizedBox(height: 16),
                      Paragraph(
                        inviteTypeDescriptions[selectedInviteType]!,
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                          onPressed: handleCreate,
                          child: const Paragraph('Create Invite Token',
                              small: true)),
                    ]),
                  if (newInvite != null)
                    Column(
                      children: [
                        const H1(
                          'Your Invite Token:',
                          // large: true,
                          color: Color.fromRGBO(0, 69, 77, 0.6),
                        ),
                        const SizedBox(height: 32),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              H1(newInvite!.token.toUpperCase(),
                                  isSelectable: true, large: true),
                              const SizedBox(width: 8),
                              Ink(
                                  decoration: ShapeDecoration(
                                    color: theme.primaryColor,
                                    shape: const CircleBorder(),
                                  ),
                                  child: IconButton(
                                      onPressed: handleShare,
                                      icon: const Icon(
                                        Icons.ios_share_outlined,
                                        color: Colors.white,
                                      )))
                            ]),
                        // const SizedBox(height: 40),
                        // const H1(
                        //     'Share token automatically with nearby devices',
                        //     center: true),
                        // const SizedBox(height: 24),
                        // if (error != null)
                        //   Paragraph('Error: $error!',
                        //       center: true, color: Colors.red),
                        // if (bleStatus == BleStatus.ready)
                        //   Column(
                        //     children: [
                        //       Row(
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         children: [
                        //           SizedBox(
                        //             height: 16,
                        //             width: 16,
                        //             child: CircularProgressIndicator(
                        //               color: theme.primaryColor,
                        //             ),
                        //           ),
                        //           const Flexible(
                        //               child: Padding(
                        //                   padding: EdgeInsets.only(left: 8),
                        //                   child: Paragraph(
                        //                       "Searching for devices."))),
                        //         ],
                        //       ),
                        //       const SizedBox(height: 16),
                        //       const Paragraph(
                        //           "Make sure the app is open on your other device and you are on the \"Join Team\" page.",
                        //           center: true),
                        //     ],
                        //   ),
                        // if (bleStatusErrorStr != null)
                        //   Paragraph(bleStatusErrorStr!,
                        //       center: true, color: Colors.red),
                        // if (bleStatus == BleStatus.unauthorized)
                        //   SizedBox(
                        //       width: 200,
                        //       child: PrimaryButton(
                        //           small: true,
                        //           child: const Paragraph('Open App Settings',
                        //               small: true),
                        //           onPressed: () => openAppSettings())),
                      ],
                    )
                ]))));
  }
}
