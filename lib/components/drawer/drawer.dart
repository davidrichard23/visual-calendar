import 'package:calendar/components/buttons/primary_button.dart';
import 'package:calendar/components/drawer/create_invite.dart';
import 'package:calendar/components/drawer/drawer_row.dart';
import 'package:calendar/components/drawer/team_selection.dart';
import 'package:calendar/realm/app_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrawerComponent extends StatefulWidget {
  const DrawerComponent({Key? key}) : super(key: key);

  @override
  State<DrawerComponent> createState() => DrawerComponentState();
}

class DrawerComponentState extends State<DrawerComponent> {
  bool isCreatingInvite = false;

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppServices>(context);
    final theme = Theme.of(context);

    void toggleCreateInvite() {
      setState(() => isCreatingInvite = !isCreatingInvite);
    }

    void handleLogout() {
      // app.deleteUser(realmManager.realm!);
      Navigator.pushReplacementNamed(context, '/login');
      app.logOutUser();
    }

    return Container(
        margin: const EdgeInsets.only(top: 8, left: 8, bottom: 8),
        child: Drawer(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(56),
            ),
            backgroundColor: theme.backgroundColor,
            child: SafeArea(
                bottom: false,
                child: Column(children: [
                  Expanded(
                      child: ListView(
                          clipBehavior: Clip.hardEdge,
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
                          children: [
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: TeamSelection()),
                        const SizedBox(height: 48),
                        DrawerRow(
                          icon: Icons.add_circle_outline,
                          text: 'Generate Invite Token',
                          onTap: toggleCreateInvite,
                        ),
                        CreateInvite(isOpen: isCreatingInvite),
                        DrawerRow(
                          icon: Icons.people_alt_outlined,
                          text: 'Manage Team (coming soon)',
                          color: Colors.black.withOpacity(0.3),
                          onTap: () {},
                        ),
                        DrawerRow(
                          icon: Icons.settings_outlined,
                          text: 'Manage Account (coming soon)',
                          color: Colors.black.withOpacity(0.3),
                          onTap: () {},
                        ),
                      ])),
                  Padding(
                      padding: const EdgeInsets.all(16),
                      child: PrimaryButton(
                          medium: true,
                          onPressed: handleLogout,
                          color: const Color.fromARGB(255, 255, 117, 107),
                          child: const Text('Logout'))),
                ]))));
  }
}
