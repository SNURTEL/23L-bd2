import 'package:flutter/material.dart';
import '../database/base_connector.dart';
import 'main_scaffold.dart';

class MainApp extends StatefulWidget {
  final VoidCallback logoutCallback;
  final int customerId;

  MainApp({super.key, required this.customerId, required this.logoutCallback});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool loaded = false;
  BaseConnector? connector;

  @override
  initState(){
    super.initState();
    BaseConnector.createBaseConnector(widget.customerId).then(
            (BaseConnector? value){
          setState((){
            connector = value;
            loaded = true;
          });
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget homeWidget;
    if(loaded){
      BaseConnector? theConnector = connector;
      if(theConnector == null){
        homeWidget = const Center(
            child: Text(
                'An error occured while loading data from database\n'
                    ', please check your internet connection and restart app'
            )
        );
      }else{
        homeWidget = MainScaffold(connector: theConnector, logoutCallback: widget.logoutCallback,);
      }
    }else{
      homeWidget = const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Dowloading data from database,\n please wait...'),
          CircularProgressIndicator()
        ],
      );
    }

    return  MaterialApp(
      title: 'Grab a Car!',
      home: homeWidget,
    );
  }
}




