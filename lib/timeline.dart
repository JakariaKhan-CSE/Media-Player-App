import 'package:flutter/material.dart';

class TimeLineScreen extends StatefulWidget {
  const TimeLineScreen({super.key});

  @override
  State<TimeLineScreen> createState() => _TimeLineScreenState();
}

class _TimeLineScreenState extends State<TimeLineScreen> {
  List<int> items = List.generate(
    10,
    (index) => index + 1,
  );

  void addItemAtPosition(int index) {
    setState(() {
      items.insert(index, -1); // -1 represents the new element "NEW"
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return SizedBox(
        height: height,
        child: Column(
          children: [
            Expanded(
              child: ListWheelScrollView.useDelegate(
                  itemExtent: 200,
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: items.length,
                    builder: (context, index) {
                      return Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.pink,
                        child: Center(
                            child: Text(
                          items[index] == -1 ? 'NEW' : items[index].toString(),
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w800),
                        )),
                      );
                    },
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                  onPressed: () {
                    addItemAtPosition(3); // Insert at position 3
                  },
                  child: Text('ADD')),
            )
          ],
        ));
  }
}
