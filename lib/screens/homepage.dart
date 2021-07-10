import 'package:flutter/material.dart';
import '../widgets/news.dart';
import '../constants.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: white,
        elevation: 5,
        title: Text(
          'News For You',
          style: TextStyle(color: Colors.red, fontSize: 21),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        margin: EdgeInsets.only(top: 10),
        child: NewsWidget(),
      ),
    );
  }
}