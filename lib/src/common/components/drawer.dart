import 'package:crud_fire/src/common/components/list_tile.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onSingOut;
  const MyDrawer({
    super.key,
    required this.onProfileTap,
    required this.onSingOut,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              //Header
              const DrawerHeader(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 64,
                ),
              ),
              //home list tile
              MyListTile(
                icon: Icons.home,
                text: "H O M E",
                onTap: () => Navigator.pop(context),
              ),

              //profile list tile
              MyListTile(
                icon: Icons.person,
                text: "P E R F I L",
                onTap: onProfileTap,
              ),
            ],
          ),
          //logout list tile
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: Column(
              children: [
                MyListTile(
                  icon: Icons.logout,
                  text: "S A I R",
                  onTap: onSingOut,
                ),
                Text(
                  'From binary.ao',
                  style: TextStyle(color: Colors.grey[600]),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
