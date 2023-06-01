import 'package:flutter/material.dart';
import 'main_app/main_app.dart';
import 'logging/logging_app.dart';

void main() {
  runApp(Starter());
}


class Starter extends StatefulWidget {
  const Starter({super.key,});

  @override
  State<Starter> createState() => _StarterState();
}

class _StarterState extends State<Starter> {
  int customerId = -1;

  @override
  Widget build(BuildContext context) {
    if(customerId > 0) {
      return MainApp(
          customerId: customerId,
          logoutCallback: () => setState((){customerId = -1;}),
      );
    } else {
      return LoggingApp(
        logInCallback: (int obtainedCustomerId){
            print("Cusomtomer id is $obtainedCustomerId");
            setState((){customerId = obtainedCustomerId;});
          },
        );
    }
  }
}

