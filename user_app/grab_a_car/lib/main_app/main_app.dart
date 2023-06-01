import 'package:flutter/material.dart';
import '../database/base_connector.dart';
import 'main_scaffold.dart';

class MainApp extends StatelessWidget {
  final Future<BaseConnector?> future;
  final VoidCallback logoutCallback;

  MainApp({super.key, required int customerId, required this.logoutCallback}) :
        future = BaseConnector.createBaseConnector(customerId);

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Grab a Car!',
      home: FutureBuilder<BaseConnector?>(
          future: future,
          builder: (BuildContext context, snapshot) {
            if(snapshot.hasData){
              BaseConnector? connector = snapshot.data;
              if(connector == null){
                return const Center(
                    child: Text(
                      'An error occured while loading data from database\n'
                      ', please check your internet connection and restart app'
                    )
                  );
              }else{
                return MainScaffold(connector: connector, logoutCallback: logoutCallback,);
              }
            }else{
              return const Center(
                child: Column(
                  children: [
                    Text('Dowloading data from database,\n please wait...'),
                    CircularProgressIndicator()
                  ],
                ),
              );
            }
          }
      ),
    );
  }

}




