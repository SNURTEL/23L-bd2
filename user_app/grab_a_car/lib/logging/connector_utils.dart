import 'package:flutter/material.dart';

Future<int?> showFutureDialog({
  required Future<int> future,
  required BuildContext context,
  required String progressInfo,
  required String failureInfo,
  required String errorInfo,
  required String successInfo,
  required bool popOnSuccess,
}){
  return showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
          content: FutureBuilder<int>(
              future: future,
              builder: (BuildContext context, snapshot) {
                List<Widget> columnChildren;
                if(snapshot.hasData){
                  String info;
                  int? result = snapshot.data;
                  if(result == null || result == -2){
                    info = errorInfo;
                  } else if(result == -1){
                    info = failureInfo;
                  } else{
                    if(popOnSuccess) Navigator.of(context).pop(result);
                    info = successInfo;
                  }

                  columnChildren = [
                    Text(info),
                    TextButton(child: const Text('OK'), onPressed: (){
                      Navigator.of(context).pop();
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