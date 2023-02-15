import 'package:account/global/global.dart';
import 'package:flutter/material.dart';

class BubbleStories extends StatelessWidget {
  //const BubbleStories({Key? key}) : super(key: key);
  final String text;

  BubbleStories({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.black,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber,
            Colors.lightGreenAccent,
          ],
          begin: FractionalOffset(0.0, 0.0),
          end: FractionalOffset(1.0, 0.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.grey[400],
                image: DecorationImage(
                  image:
                      NetworkImage(sharedPreferences!.getString("photoUrl")!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            /*ExpansionTile(
              title: Text(
                '${text}'.toString(),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              children: [
                ListTile(
                  title: Text(
                    '  20000'.toString(),
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),*/
            Text(
              '  $text'.toString(),
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            Text(
              '  20000'.toString(),
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
