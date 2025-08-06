import 'package:flutter/material.dart';

class NouvaCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  NouvaCustomAppBar({Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Green Valley Farm"),
          Text(
            "Makueni, Kenya",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
          )
        ],
      ),
      // Text("Makueni, Kenya"),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {},
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.green.shade600,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: CircleAvatar(backgroundImage: AssetImage("assets/user.jpg")
                // backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                ),
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }
}



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


