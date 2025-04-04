import 'package:flutter/material.dart';

void main() {
  runApp(const FlutterBook());
}

class _Dummy extends StatelessWidget {
  final String _title;

  const _Dummy(this._title);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(_title));
  }
}

class FlutterBook extends StatelessWidget {
  const FlutterBook({super.key});
  static const _tabs = [
    {'icon':Icons.date_range, 'name':'Appointments'},
    {'icon':Icons.contacts, 'name':'Contacts'},
    {'icon':Icons.note, 'name':'Notes'},
    {'icon':Icons.assignment_turned_in, 'name':'Tasks'},

  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Book',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: DefaultTabController(
        length: _tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text('FlutterBook :'),
                SizedBox(width: 8),
                Text('Epifanio Sarinana'),
              ],
            ),
            bottom: TabBar(tabs: _tabs
                .map((tab) => Tab(icon: Icon(tab['icon'] as IconData?), text: tab['name'] as String))
                .toList(),
            )
          ),
          body: TabBarView(
              children: _tabs.map((tab) => _Dummy(tab['name'] as String)).toList(),
          )
        )
      )
    );
  }
}