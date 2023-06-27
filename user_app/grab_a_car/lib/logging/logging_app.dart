import 'package:flutter/material.dart';
import '../database/logging_connector.dart';
import 'package:email_validator/email_validator.dart';
import 'connector_utils.dart';

class LoggingApp extends StatelessWidget {
  final void Function(int) logInCallback;
  const LoggingApp({super.key, required this.logInCallback});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Grab a Car!',
      home: LoggingScaffold(logInCallback: logInCallback),
    );
  }
  }

class LoggingScaffold extends StatefulWidget {
   LoggingScaffold({super.key, required this.logInCallback});

   final void Function(int) logInCallback;

  @override
  State<LoggingScaffold> createState() => _LoggingScaffoldState();
}

class _LoggingScaffoldState extends State<LoggingScaffold> {
  final GlobalKey <FormState> loginKey = GlobalKey<FormState>();
  final GlobalKey <FormState> registrationKey = GlobalKey<FormState>();
  final TextEditingController logEmailController = TextEditingController();
  final TextEditingController logPasswordController = TextEditingController();
  final TextEditingController regNameController = TextEditingController();
  final TextEditingController regSurnameController = TextEditingController();
  final TextEditingController regEmailController = TextEditingController();
  final TextEditingController regPasswordController = TextEditingController();

  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
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
                      validator: __emailValidator,
                      controller: logEmailController,
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: logPasswordController,
                      validator: __getValidator('Password'),
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            setState(() {_passwordVisible = !_passwordVisible;});
                          },
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (loginKey.currentState!.validate()) {
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
                        ).then((int? value) {
                          if (value != null && value > 0) {
                            widget.logInCallback(value);
                          }
                        });
                      }
                    },
                    child: const Text('LogIn'),
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
                      validator: __getValidator('Name'),
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
                      validator: __getValidator('Surname'),
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
                      validator: __emailValidator,
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
                      validator: __getValidator('Password'),
                      controller: regPasswordController,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (registrationKey.currentState!.validate()) {
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
                          failureInfo: 'Email address already in use.',
                          successInfo: 'Congratulations!\n'
                              'You are now registered.'
                              'Now, you can login.',
                          popOnSuccess: false,
                        );
                      }
                    },
                    child: const Text('Register'),
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
              Tab(text: 'LogIn',),
              Tab(text: 'Register'),
            ],
          ),
        ),
      ),
    );
  }

  static String? __emailValidator(String? value){
    if(value == null || value.isEmpty) return "Email is required.";
    if(EmailValidator.validate(value)) return null;
    return 'Invalid email address.';
  }

  static  String? Function(String?) __getValidator(String fieldName){
    return (String? value){
      if(value == null || value.isEmpty) return '$fieldName is required.';
      return null;
    };
  }
}