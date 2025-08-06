import 'package:flutter/material.dart';
import 'package:broka/lib_brok_a/screens/profile_page.dart';
// import 'package:broka/screens/settings_page.dart';
// import 'package:broka/screens/about_page.dart';

class MyDrawerWidget extends StatelessWidget {
  const MyDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Company App Name Header
          SizedBox(height: 50),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade700,
            child: Text(
              "Broka App Menu",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Profile header using UserAccountsDrawerHeader.
          Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UserAccountsDrawerHeader(
                accountName: Center(
                  child: const Text(
                    "Philip Studios",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                accountEmail:
                    Center(child: const Text("philipaswa01@gmail.com")),
                currentAccountPicture: SizedBox(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const CircleAvatar(
                        backgroundImage: AssetImage("assets/user.jpg"),
                      ),
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ],
          ),
          // Navigation items.
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.person,
                  text: 'Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilePage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  text: 'Settings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info,
                  text: 'About',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AboutPage()),
                    );
                  },
                ),
                Divider(color: Colors.grey, thickness: 1),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.black),
                  title: Text(
                    'Logout',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  onTap: () {
                    // Implement logout functionality here.
                  },
                ),
              ],
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
      // ),
    );
  }

  // Helper method to build a styled drawer item.
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade800),
      title: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:broka/screens/profile_page.dart';
// // Make sure to import your SettingsPage and AboutPage widgets.
// // import 'package:broka/screens/settings_page.dart';
// // import 'package:broka/screens/about_page.dart';

// class MyDrawerWidget extends StatelessWidget {
//   const MyDrawerWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: Container(
//         // Apply a gradient background to the entire drawer.
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.green.shade900, Colors.green.shade500],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             // Custom header with a gradient and profile details.
//             DrawerHeader(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.transparent, // Transparent to show the gradient.
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Circular profile picture with a white border.
//                   CircleAvatar(
//                     radius: 40,
//                     backgroundColor: Colors.white,
//                     child: CircleAvatar(
//                       radius: 37,
//                       backgroundImage: AssetImage("assets/user.jpg"),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     'Philip Studios',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'philipaswa01@gmail.com',
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Divider for separation.
//             Divider(color: Colors.white70, thickness: 1),
//             // Profile Menu Item
//             ListTile(
//               leading: Icon(Icons.person, color: Colors.white),
//               title: Text(
//                 'Profile',
//                 style: TextStyle(color: Colors.white, fontSize: 16),
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const ProfilePage()),
//                 );
//               },
//             ),
//             // Settings Menu Item
//             ListTile(
//               leading: Icon(Icons.settings, color: Colors.white),
//               title: Text(
//                 'Settings',
//                 style: TextStyle(color: Colors.white, fontSize: 16),
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const SettingsPage()),
//                 );
//               },
//             ),
//             // About Menu Item
//             ListTile(
//               leading: Icon(Icons.info, color: Colors.white),
//               title: Text(
//                 'About',
//                 style: TextStyle(color: Colors.white, fontSize: 16),
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const AboutPage()),
//                 );
//               },
//             ),
//             // Optional: Additional menu item for Logout
//             const SizedBox(height: 20),
//             Divider(color: Colors.white70, thickness: 1),
//             ListTile(
//               leading: Icon(Icons.logout, color: Colors.white),
//               title: Text(
//                 'Logout',
//                 style: TextStyle(color: Colors.white, fontSize: 16),
//               ),
//               onTap: () {
//                 // Implement logout functionality here.
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }











// import 'package:flutter/material.dart';
// import 'package:broka/screens/profile_page.dart';
// import 'package:flutter/material.dart';

// class MyDrawerWidget extends StatelessWidget {
//   const MyDrawerWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: Column(
//         children: [
//           // Profile header with gradient background.
//           UserAccountsDrawerHeader(
//             accountName: Text(
//               "Philip Studios",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             accountEmail: Text("philipaswa01@gmail.com"),
//             currentAccountPicture: CircleAvatar(
//               backgroundImage: AssetImage("assets/user.jpg"),
//             ),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.green.shade400, Colors.green.shade800],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           // Navigation items.
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.zero,
//               children: [
//                 _buildDrawerItem(
//                   context,
//                   icon: Icons.person,
//                   text: 'Profile',
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const ProfilePage()),
//                     );
//                   },
//                 ),
//                 _buildDrawerItem(
//                   context,
//                   icon: Icons.settings,
//                   text: 'Settings',
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const SettingsPage()),
//                     );
//                   },
//                 ),
//                 _buildDrawerItem(
//                   context,
//                   icon: Icons.info,
//                   text: 'About',
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const AboutPage()),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//           Divider(),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               'Version 1.0.0',
//               style: TextStyle(color: Colors.grey),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper method to build a styled drawer item.
//   Widget _buildDrawerItem(
//     BuildContext context, {
//     required IconData icon,
//     required String text,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.green.shade800),
//       title: Text(
//         text,
//         style: TextStyle(fontWeight: FontWeight.bold),
//       ),
//       trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//       onTap: onTap,
//     );
//   }
// }














// // import 'package:broka/main%20copy%202.dart';
// import 'package:broka/screens/profile_page.dart';
// import 'package:flutter/material.dart';

// class MyDrawerWidget extends StatelessWidget {
//   const MyDrawerWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           DrawerHeader(
//             decoration: BoxDecoration(color: Colors.green),
//             child: Text(
//               'Broka Menu',
//               style: TextStyle(color: Colors.white, fontSize: 24),
//             ),
//           ),
//           UserAccountsDrawerHeader(
//             accountName: Text(
//               "Philip Studios",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             accountEmail: Text("philipaswa01@gmail.com"),
//             currentAccountPicture: CircleAvatar(
//               backgroundImage: AssetImage("assets/user.jpg"),
//             ),
//             decoration: BoxDecoration(
//               color: Colors.green,
//             ),
//           ),
//           ListTile(
//             leading: Icon(Icons.person),
//             title: Text('Profile'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const ProfilePage()),
//               );
//             },
//           ),
//           ListTile(
//             leading: Icon(Icons.settings),
//             title: Text('Settings'),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const SettingsPage()),
//               );
//             },
//           ),
//           ListTile(
//             leading: Icon(Icons.info),
//             title: Text('About'),
//             onTap: () {
//               Navigator.push(context,
//                   MaterialPageRoute(builder: (context) => AboutPage()));
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
