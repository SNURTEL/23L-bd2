import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../database/logging_connector.dart';
import 'package:email_validator/email_validator.dart';
import 'connector_utils.dart';

/*
(r'browser98privacy', r'$5$VIzRYdSlKR$qQ197dQBnarwZ541SQLFwSi38/gd36ELFik.0.tTaX3'),
(r'cybercrime99awareness', r'$5$Xjj7RTbLvI$OKbL3F9im.aS9bdVr2Nfa0yfbgjjsra7qw8SXXoWmI9'),
(r'social100media', r'$5$qymUEFk7pR$a6W6ajByY6SRKi3zFtiRKxCav51/VX3snOa4yaCE5S6'),
*/

class LoggingApp extends StatelessWidget {
  void Function(int) logInCallback;
  LoggingApp({super.key, required this.logInCallback});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Grab a Car!',
      home: LoggingScaffold(logInCallback: logInCallback),
    );
  }
  }

class LoggingScaffold extends StatelessWidget {
   LoggingScaffold({super.key, required this.logInCallback});
   void Function(int) logInCallback;

  final GlobalKey <FormState> loginKey = GlobalKey<FormState>();
  final GlobalKey <FormState> registrationKey = GlobalKey<FormState>();

  final TextEditingController logEmailController = TextEditingController();
  final TextEditingController logPasswordController = TextEditingController();

  final TextEditingController regNameController = TextEditingController();
  final TextEditingController regSurnameController = TextEditingController();
  final TextEditingController regEmailController = TextEditingController();
  final TextEditingController regPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return   DefaultTabController(
      length: 2,
      child: Scaffold(
        body: TabBarView(
          children: [
            Form(
              key: loginKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'email',
                      ),
                      validator: (String? value){
                        if(value != null && EmailValidator.validate(value)) return null;
                        return 'Invalid email address.';
                      },
                      controller: logEmailController,
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'password',
                      ),
                      controller: logPasswordController,
                    ),
                  ),
                  TextButton(
                    onPressed: (){
                      if(loginKey.currentState!.validate()){
                        Future<int> future = LoggingConnector.logIn(
                            email: logEmailController.text,
                            password: logPasswordController.text
                        );
                        showFutureDialog(
                          future: future,
                          context: context,
                          progressInfo: 'Checking you credentials, please wait.',
                          errorInfo: 'Unable to login.\n'
                              'Please check internet connection and try again later.',
                          failureInfo: 'Invalid email or passwor.',
                          successInfo: 'You have benn logged in, please wait few seconds.',
                          popOnSuccess: true,
                        ).then((int? value){
                          if(value != null && value > 0) {
                            logInCallback(value);
                          }
                        });
                      }
                    },
                    child: Text('LogIn'),
                  )
                ],
              ),
            ),
            Form(
              key: registrationKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'name',
                      ),
                      controller: regNameController,
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'surname',
                      ),
                      controller: regSurnameController,
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'email',
                      ),
                      validator: (String? value){
                        if(value != null && EmailValidator.validate(value)) return null;
                        return 'Invalid email address.';
                      },
                      controller: regEmailController,
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'password',
                      ),
                      controller: regPasswordController,
                    ),
                  ),
                  TextButton(
                    onPressed: (){
                      if(registrationKey.currentState!.validate()){
                        Future<int> future = LoggingConnector.register(
                            name: regNameController.text,
                            surname: regSurnameController.text,
                            email: regEmailController.text,
                            password: regPasswordController.text,
                        );
                        showFutureDialog(
                            future: future,
                            context: context,
                            progressInfo: 'Registrating, please wait.',
                            errorInfo: 'Unable to register.\n'
                              'Please check internet connection and try again later.',
                            failureInfo: 'Email adress already in use.',
                            successInfo: 'Congratulations!\n'
                                'You are now registered.'
                                'Now, you can login.',
                            popOnSuccess: false,
                        );
                      }
                    },
                    child: Text('Register'),
                  )
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: const Material(
          color: Colors.lightBlue,
          child: TabBar(
            labelStyle: TextStyle(fontSize: 25),
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'LogIn', ),
              Tab(text: 'Register'),
            ],
          ),
        ),
      ),
    );
  }
}