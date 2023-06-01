import 'package:flutter/material.dart';
import 'package:grab_a_car/main_app/connector_utils.dart';
import '../data/customer.dart';
import '../database/base_connector.dart';

class CustomerDetailsWidget extends StatefulWidget {
  final BaseConnector connector;

  const CustomerDetailsWidget({super.key, required this.connector});

  @override
  _CustomerDetailsWidgetState createState() => _CustomerDetailsWidgetState();
}

class _CustomerDetailsWidgetState extends State<CustomerDetailsWidget> {
  bool _isEditMode = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.connector.customer.name;
    _surnameController.text = widget.connector.customer.surname;
    _emailController.text = widget.connector.customer.email;
  }

  void _makeEditable() {
    setState(() {
      _isEditMode = true;
    });
  }

  void _applyChanges() {
    Customer newCustomer = Customer(
      surname: _surnameController.text,
      name: _nameController.text,
      email: _emailController.text
    );
    Future<bool> future = widget.connector.updateCustomer(newCustomer);
    showFutureDialog(future: future,
        context: context,
        progressInfo: 'Updating your personal information, please wait.',
        failedInfo: 'Unable to update personal info.\n'
            'Please check your internet connection address and try again later.',
        successInfo: 'Personal info successfully updated!',
    ).then((a){makeNonEditable();});
  }

  void makeNonEditable() {
    setState(() {
      _isEditMode = false;
      _nameController.text = widget.connector.customer.name;
      _surnameController.text = widget.connector.customer.surname;
      _emailController.text = widget.connector.customer.email;
    });
  }

  @override
  Widget build(BuildContext context) {
    const leftStyle = TextStyle(fontSize: 16,fontWeight: FontWeight.bold);
    const rightStyle = TextStyle(fontSize: 16);
    const hspace = SizedBox(height: 8);
    const wspace = SizedBox(width: 4);

    Widget body = _isEditMode ?
    Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Name',
          ),
          controller: _nameController,
        ),
        hspace,
        TextFormField(
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Surname',
          ),
          controller: _surnameController,
        ),
        hspace,
        TextFormField(
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Email',
          ),
          controller: _emailController,
        ),
        Row(children: [
          ElevatedButton(onPressed: _applyChanges, child: const Text('Apply')),
          TextButton(onPressed: makeNonEditable, child: const Text('Cancel')),
        ])
      ],
    )
      :
    Column(
      children: [
        Row(children: [
          const Text('Name', style: leftStyle),
          wspace,
          Text(widget.connector.customer.name, style: rightStyle)
        ]),
        hspace,
        Row(children: [
          const Text('Surname', style: leftStyle),
          wspace,
          Text(widget.connector.customer.surname, style: rightStyle)
        ]),
        hspace,
        Row(children: [
          const Text('Email', style: leftStyle),
          wspace,
          Text(widget.connector.customer.email, style: rightStyle)
        ]),
        ElevatedButton(onPressed: _makeEditable, child: const Text('Update Info')),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: body
    );
  }
}