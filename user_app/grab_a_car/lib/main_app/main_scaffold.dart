import 'package:flutter/material.dart';
import '../database/base_connector.dart';
import 'cars_map.dart';
import 'invoices_list.dart';
import 'tours_list.dart';
import 'customer_info.dart';
import 'logout.dart';

enum Page {carMap, myTours, invoices, profile, logout}

class MainScaffold extends StatefulWidget {
  final BaseConnector connector;
  final VoidCallback logoutCallback;

  const MainScaffold({required this.connector,required this.logoutCallback,
    super.key, });

  @override
  State<MainScaffold> createState() => _MainScaffold();
}


class _MainScaffold extends State<MainScaffold> {
  Page selectedIndex = Page.carMap;

  void tapIndex(Page index){
    setState(() {
      selectedIndex = index;
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    String title;
    Widget body;
    if (selectedIndex == Page.carMap) {
      title = 'Car Map';
      body = CarMap(connector: widget.connector);
    } else if(selectedIndex == Page.myTours) {
      title = 'My Tours';
      body = ToursList(connector: widget.connector);
    }else if(selectedIndex == Page.invoices) {
      title = 'Invoices';
      body = InvoiceList(connector: widget.connector);
    }else if (selectedIndex == Page.profile){
      title = 'Profile';
      body = CustomerDetailsWidget(connector: widget.connector);
    }else{
      title = 'LogOut';
      body = Logout(logoutCallback: widget.logoutCallback);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: Drawer(
          child: ListView(
              children: <ListTile>[
                ListTile(
                  leading: const Icon(Icons.map),
                  title: const Text('Car Map'),
                  onTap: () => tapIndex(Page.carMap),
                  selected: selectedIndex == Page.carMap,
                ),
                ListTile(
                  leading: const Icon(Icons.route),
                  title: const Text('My Tours'),
                  onTap: () => tapIndex(Page.myTours),
                  selected: selectedIndex == Page.myTours,
                ),
                ListTile(
                  leading: const Icon(Icons.receipt),
                  title: const Text('Invoices'),
                  onTap: () => tapIndex(Page.invoices),
                  selected: selectedIndex == Page.invoices,
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () => tapIndex(Page.profile),
                  selected: selectedIndex == Page.profile,
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('LogOut'),
                  onTap: () => tapIndex(Page.logout),
                  selected: selectedIndex == Page.logout,
                )
              ]
          )
      ),
      body: body,
    );
  }
}