import 'package:mysql1/mysql1.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class ConnectionProvider{
   static String __dbHost ='', __dbUser='', __dbName='', __dbPassword='';
   static int __dbPort = -1;
   static bool loaded = false;

   static Future<MySqlConnection?> getConnection() async{
     if(!loaded) await __readCredentials();
     MySqlConnection? conn;
     try {
       conn = await MySqlConnection.connect(ConnectionSettings(
         host: __dbHost,
         port: __dbPort,
         user: __dbUser,
         db: __dbName,
         password: __dbPassword,
       ));
     }catch(e){
       conn = null;
     }
     return conn;
   }

   static Future<void> __readCredentials() async{
     String jsonText = await rootBundle.loadString('assets/connection_credentials.json');
     Map<String, dynamic> jsonMap = jsonDecode(jsonText);
      __dbHost = jsonMap['host'];
      __dbUser = jsonMap['user'];
      __dbName = jsonMap['name'];
      __dbPassword = jsonMap['password'];
      __dbPort = jsonMap['port'];
   }
}