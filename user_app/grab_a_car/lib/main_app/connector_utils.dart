import 'package:flutter/material.dart';

Future showFutureDialog({
    required Future<bool> future,
    required BuildContext context,
    required String progressInfo,
    required String failedInfo,
    required String successInfo,
}){
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
          content: FutureBuilder<bool>(
              future: future,
              builder: (BuildContext context, snapshot) {
                List<Widget> columnChildren;
                if(snapshot.hasData){
                  String info = (snapshot.data == null || snapshot.data == false) ?
                    failedInfo : successInfo;

                  columnChildren = [
                    Text(info),
                    TextButton(child: const Text('OK'), onPressed: (){
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },),
                  ];
                }else{
                  columnChildren = [
                     Text(progressInfo),
                     const CircularProgressIndicator()
                  ];
                }
                return Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: columnChildren,
                    )
                );
              }
          )
      )
  );
}