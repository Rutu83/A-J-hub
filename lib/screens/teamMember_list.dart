import 'package:flutter/material.dart';

class TeamMemberList extends StatefulWidget {
  const TeamMemberList({super.key});

  @override
  TeamMemberListState createState() => TeamMemberListState();
}

class TeamMemberListState extends State<TeamMemberList> {
  int _selectedIndex = 0;

  final List<String> _items = [
    'Suhaas B R',
    'Clifton Palmer McLendon',
    'Dion Houston Sr',
    'Joe Devney',
    'James',
  ];

  final List<Widget> _contentWidgets = [
    const List1(),  // Complex view for Item 1
    const List2(),
    const List3(),
    const Text('Content for Item 4'),
    const Text('Content for Item 5'),
  ];

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          "Team Members",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), // Changed to black for visibility
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: Row(
        children: <Widget>[
          // Left Side List
          SizedBox(
            width: 150,
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_items[index]),
                  onTap: () => _onItemTap(index),
                  selected: _selectedIndex == index,
                );
              },
            ),
          ),
          // Right Side Content Display
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: Center(
                child: _contentWidgets[_selectedIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class List1 extends StatefulWidget {
  const List1({super.key});

  @override
  List1State createState() => List1State();
}

class List1State extends State<List1> {
  int _selectedIndex = 0;

  final List<String> _items = [
    'Fake Item 1',
    'Fake Item 2',
    'Fake Item 3',
    'Fake Item 4',
    'Fake Item 5',
    // Duplicating data
    'Fake Item 1 Duplicate',
    'Fake Item 2 Duplicate',
    'Fake Item 3 Duplicate',
    'Fake Item 4 Duplicate',
    'Fake Item 5 Duplicate',
  ];

  final List<Widget> _contentWidgets = [
    const Text('Fake Content for Item 1'),
    const Text('Fake Content for Item 2'),
    const Text('Fake Content for Item 3'),
    const Text('Fake Content for Item 4'),
    const Text('Fake Content for Item 5'),
    // Duplicating content for duplicates
    const Text('Item 1'),
    const Text('Item 2'),
    const Text('Item 3'),
    const Text(' Item 4'),
    const Text('Item 5'),
  ];

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black38)
        ),
        child: Row(
          children: <Widget>[
            // Left Side List with Fake Items
            SizedBox(
              width: 150,
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_items[index]),
                    onTap: () => _onItemTap(index),
                    selected: _selectedIndex == index,
                  );
                },
              ),
            ),
            // Right Side Content Display with Fake Content
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: Center(
                  child: _contentWidgets[_selectedIndex],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





class List2 extends StatefulWidget {
  const List2({super.key});

  @override
  List1State createState() => List1State();
}

class List2State extends State<List2> {
  int _selectedIndex = 0;

  final List<String> _items = [
    'Fake Item 1',
    'Fake Item 2',
    'Fake Item 3',
    'Fake Item 4',
    'Fake Item 5',
    // Duplicating data
    'Fake Item 1 Duplicate',
    'Fake Item 2 Duplicate',
    'Fake Item 3 Duplicate',
    'Fake Item 4 Duplicate',
    'Fake Item 5 Duplicate',
  ];

  final List<Widget> _contentWidgets = [
    const Text('Fake Content for Item 1'),
    const Text('Fake Content for Item 2'),
    const Text('Fake Content for Item 3'),
    const Text('Fake Content for Item 4'),
    const Text('Fake Content for Item 5'),
    // Duplicating content for duplicates
    const Text('Item 1'),
    const Text('Item 2'),
    const Text('Item 3'),
    const Text(' Item 4'),
    const Text('Item 5'),
  ];

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black38)
        ),
        child: Row(
          children: <Widget>[
            // Left Side List with Fake Items
            SizedBox(
              width: 150,
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_items[index]),
                    onTap: () => _onItemTap(index),
                    selected: _selectedIndex == index,
                  );
                },
              ),
            ),
            // Right Side Content Display with Fake Content
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: Center(
                  child: _contentWidgets[_selectedIndex],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class List3 extends StatefulWidget {
  const List3({super.key});

  @override
  List1State createState() => List1State();
}

class List3State extends State<List3> {
  int _selectedIndex = 0;

  final List<String> _items = [
    'Fake Item 1',
    'Fake Item 2',
    'Fake Item 3',
    'Fake Item 4',
    'Fake Item 5',
    // Duplicating data
    'Fake Item 1 Duplicate',
    'Fake Item 2 Duplicate',
    'Fake Item 3 Duplicate',
    'Fake Item 4 Duplicate',
    'Fake Item 5 Duplicate',
  ];

  final List<Widget> _contentWidgets = [
    const Text('Fake Content for Item 1'),
    const Text('Fake Content for Item 2'),
    const Text('Fake Content for Item 3'),
    const Text('Fake Content for Item 4'),
    const Text('Fake Content for Item 5'),
    // Duplicating content for duplicates
    const Text('Item 1'),
    const Text('Item 2'),
    const Text('Item 3'),
    const Text(' Item 4'),
    const Text('Item 5'),
  ];

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black38)
        ),
        child: Row(
          children: <Widget>[
            // Left Side List with Fake Items
            SizedBox(
              width: 150,
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_items[index]),
                    onTap: () => _onItemTap(index),
                    selected: _selectedIndex == index,
                  );
                },
              ),
            ),
            // Right Side Content Display with Fake Content
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: Center(
                  child: _contentWidgets[_selectedIndex],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

