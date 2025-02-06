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
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return SizedBox(
        height: height,
        child: ListWheelScrollView.useDelegate(
            itemExtent: 200,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: items.length,
              builder: (context, index) {
                return Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.pink,
                  child: Center(child: Text('${index}')),
                );
              },
            )));
  }
}
