import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NouvaCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  // final Future<void> Function() onExportChat;
  final Future<void> Function()? onExportChat;

  NouvaCustomAppBar({Key? key, required this.themeNotifier, this.onExportChat})
    : preferredSize = const Size.fromHeight(kToolbarHeight),
      super(key: key);

  @override
  final Size preferredSize;

  void _requestPermission(BuildContext context) async {
    PermissionStatus status = await Permission.photos.request();

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Permission status: $status")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness platformBrightness = MediaQuery.platformBrightnessOf(
      context,
    );

    return AppBar(
      elevation: 1,

      // backgroundColor: Theme.of(context).cardColor,
      // backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // backgroundColor: Colors.red,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,

      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Green Valley Farm"),
          Text(
            "Makueni, Kenya",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
          ),
        ],
      ),
      actions: [
        // Theme Toggle
        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, currentMode, child) {
            bool isDark =
                (currentMode == ThemeMode.dark) ||
                (currentMode == ThemeMode.system &&
                    platformBrightness == Brightness.dark);

            ThemeMode nextMode = isDark ? ThemeMode.light : ThemeMode.dark;
            IconData icon =
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined;
            String tooltip =
                isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme';

            return IconButton(
              icon: Icon(icon),
              tooltip: tooltip,
              onPressed: () {
                themeNotifier.value = nextMode;
                // You may want to persist this setting
              },
            );
          },
        ),

        // Notifications icon (keep original)
        IconButton(icon: Icon(Icons.notifications), onPressed: () {}),

        // Profile picture (keep original)
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green.shade600, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: CircleAvatar(backgroundImage: AssetImage("assets/user.jpg")),
          ),
        ),

        // Popup menu
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          onSelected: (String result) {
            if (result == 'export') {
              onExportChat!();
            } else if (result == 'request_permission') {
              _requestPermission(context);
            }
          },
          itemBuilder:
              (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'export',
                  child: ListTile(
                    leading: Icon(Icons.download_rounded),
                    title: Text('Export Chat'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'request_permission',
                  child: ListTile(
                    leading: Icon(Icons.security),
                    title: Text('Request Permission'),
                  ),
                ),
              ],
        ),

        SizedBox(width: 10),
      ],
    );
  }
}



// import 'package:flutter/material.dart';

// class NouvaCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   @override
//   final Size preferredSize;

//   NouvaCustomAppBar({Key? key})
//       : preferredSize = const Size.fromHeight(kToolbarHeight),
//         super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("Green Valley Farm"),
//           Text(
//             "Makueni, Kenya",
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
//           )
//         ],
//       ),
//       // Text("Makueni, Kenya"),
//       actions: [
//         IconButton(
//           icon: Icon(Icons.notifications),
//           onPressed: () {},
//         ),
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(
//               color: Colors.green.shade600,
//               width: 2,
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(2.0),
//             child: CircleAvatar(backgroundImage: AssetImage("assets/user.jpg")
//                 // backgroundImage: NetworkImage('https://via.placeholder.com/150'),
//                 ),
//           ),
//         ),
//         SizedBox(width: 10),
//       ],
//     );
//   }
// }



      // return AppBar(
      //   title: Text('broka', style: TextStyle(fontWeight: FontWeight.bold)),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.notifications),
      //       onPressed: () {},
      //     ),
      //     Container(
      //       width: 40,
      //       height: 40,
      //       decoration: BoxDecoration(
      //         shape: BoxShape.circle,
      //         border: Border.all(
      //           color: Colors.green.shade600,
      //           width: 2,
      //         ),
      //       ),
      //       child: Padding(
      //         padding: const EdgeInsets.all(2.0),
      //         child: CircleAvatar(backgroundImage: AssetImage("assets/user.jpg")
      //             // backgroundImage: NetworkImage('https://via.placeholder.com/150'),
      //             ),
      //       ),
      //     ),
      //     SizedBox(width: 10),
      //   ],
      // );



  // class name extends StatefulWidget {
  //   const name({super.key});

  //   @override
  //   State<name> createState() => _nameState();
  // }

  // class _nameState extends State<name> {
  //   @override
  //   Widget build(BuildContext context) {
  //     return 
  //   }
  // }


