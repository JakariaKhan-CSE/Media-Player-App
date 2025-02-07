import 'package:flutter/material.dart';

class TimeLineAnother extends StatefulWidget {
  @override
  _ListViewExampleState createState() => _ListViewExampleState();
}

class _ListViewExampleState extends State<TimeLineAnother> {
  final ScrollController _scrollController = ScrollController();
  final List<String> items = List.generate(20, (index) => 'Item ${index + 1}');
  final double itemHeight = 50.0;

  void insertItemsAtBeginning(List<String> newItems) {
    final double previousScrollPosition = _scrollController.offset;
    setState(() {
      items.insertAll(0, newItems);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController
          .jumpTo(previousScrollPosition + newItems.length * itemHeight);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            insertItemsAtBeginning(
                List.generate(5, (index) => 'New Item ${index + 1}'));
          },
          child: Text('Insert Items at Beginning'),
        ),
        Expanded(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverFixedExtentList(
                itemExtent: itemHeight,
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return ListTile(
                      key: ValueKey(items[index]), // Unique key for each item
                      title: Text(items[index]),
                    );
                  },
                  childCount: items.length,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// class TimeLineAnother extends StatefulWidget {
//   const TimeLineAnother({super.key});

//   @override
//   State<TimeLineAnother> createState() => _TimeLineAnotherState();
// }

// class _TimeLineAnotherState extends State<TimeLineAnother> {
//   final ScrollController _scrollController = ScrollController();

//   List<String> _items = List.generate(
//     10,
//     (index) => 'Item ${index + 1}',
//   );

//   // void addItem() {
//   //   setState(() {
//   //     items.insert(0, 'New Item ${items.length + 1}');
//   //   });
//   // }

//   void _addItem() {
//     final currentPosition = _scrollController.position.pixels;
//     final currentItemIndex = (_scrollController.position.pixels / 56).round();

//     setState(() {
//       _items.insert(0, 'New Item ${_items.length}');
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollController.jumpTo(currentItemIndex * 56.0);
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: ListView.builder(
//             controller: _scrollController,
//             itemCount: _items.length,
//             itemBuilder: (context, index) {
//               return Center(
//                   child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Container(
//                   color: Colors.pink,
//                   child: Padding(
//                     padding: const EdgeInsets.all(28.0),
//                     child: Text(_items[index]),
//                   ),
//                 ),
//               ));
//             },
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: ElevatedButton(
//             onPressed: _addItem,
//             child: Text('Add Item'),
//           ),
//         ),
//       ],
//     );
//   }
// }
