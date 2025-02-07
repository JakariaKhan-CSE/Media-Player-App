import 'package:flutter/material.dart';

final pagebucket = PageStorageBucket();

class TimeLineScreen extends StatefulWidget {
  const TimeLineScreen({super.key});

  @override
  State<TimeLineScreen> createState() => _TimeLineScreenState();
}

class _TimeLineScreenState extends State<TimeLineScreen> {
  // Dummy data
  List<String> items = List.generate(10, (index) => 'Item ${index + 1}');

  // Controller to manage scroll position
  final FixedExtentScrollController _scrollController =
      FixedExtentScrollController();

  // Add a new item to the top of the list
  void addItem() {
    items.insert(0, 'New Item ${items.length + 1}');

    // Adjust the scroll position to maintain the user's current view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpToItem(_scrollController.selectedItem + 1);
    });
    // setState(() {});
  }
  // FixedExtentScrollController? _scrollController;

  // List<int> items = List.generate(
  //   10,
  //   (index) => index + 1,
  // );

  // void addItemAtPosition(int index) {
  //   final currentIndex = _scrollController?.selectedItem;
  //   setState(() {
  //     items.insert(index, -1); // -1 represents the new element "NEW"
  //   });
  //   // Maintain the current scroll position
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _scrollController?.jumpToItem(currentIndex!);
  //   });
  // }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();

  // }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return SizedBox(
        height: height,
        child: Column(
          children: [
            Expanded(
              child: PageStorage(
                bucket: pagebucket,
                child: ListWheelScrollView.useDelegate(
                    key: PageStorageKey<String>('pageOne'),
                    itemExtent: 150, // Height of each item
                    controller:
                        _scrollController, // Attach the scroll controller
                    physics: FixedExtentScrollPhysics(), // Snap to items
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: items.length,
                      builder: (context, index) {
                        return Container(
                          color: Colors.pink.withAlpha(180),
                          child: Center(
                            child: Text(
                              items[index],
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        );
                        // return Container(
                        //   height: 200,
                        //   width: double.infinity,
                        //   color: Colors.pink,
                        //   child: Center(
                        //       child: Text(
                        //     items[index] == -1 ? 'NEW' : items[index].toString(),
                        //     style: TextStyle(
                        //         fontSize: 28, fontWeight: FontWeight.w800),
                        //   )),
                        // );
                      },
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  addItem();
                  // Future.delayed(Duration(microseconds: 10), () {
                  //   setState(() {});
                  // });
                  setState(() {});
                },
                child: Text('Add Item'),
              ),
            ),
          ],
        ));
  }
}
