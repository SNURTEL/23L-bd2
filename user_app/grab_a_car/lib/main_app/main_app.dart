import 'package:flutter/material.dart';
import '../database/base_connector.dart';
import 'main_scaffold.dart';

class MainApp extends StatefulWidget {
  final int customerId;

  const MainApp({super.key, required this.customerId});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int state = 0; //0 for loading, 1 for some error, 2 for loaded
  late BaseConnector connector;

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget homeWidget;
    if(state == 0){
      homeWidget = const Center(
          child: Text('Dowloading data from database,\n please wait...')
      );
    }else if(state == 1){
      homeWidget = const Center(
          child: Text(
              'An error occured while loading data from database\n'
                  ', please check your internet connection and restart app')
      );
    }else{
      homeWidget = MainScaffold(connector: connector);
    }
    return MaterialApp(
      title: 'Grab a Car!',
      home: homeWidget,
    );
  }

  Future<void> getData() async {
    BaseConnector? connectorTmp = await BaseConnector.createBaseConnector(widget.customerId);
    if(connectorTmp == null){
      setState(() {
        state = 1;
      });
    }else{
      setState(() {
        state = 2;
        connector = connectorTmp;
      });
    }
  }
}


