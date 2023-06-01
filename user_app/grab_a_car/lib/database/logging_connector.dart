import 'package:mysql1/mysql1.dart';
import 'connection_provider.dart';
import 'package:crypt/crypt.dart';
import 'dart:math';


class LoggingConnector{

  //-2 for error, -1 for invalid email or password, positive for customer id
  static Future<int> logIn({required String email, required String password}) async {
    final MySqlConnection? conn = await ConnectionProvider.getConnection();
    if(conn == null) return -2;

    try {
      var result = await conn.query(
        'SELECT id, password_hash FROM customer WHERE email = ?',
        [email],
      );
      if(result.isEmpty) return -1;
      ResultRow row = result.first;
      if(Crypt(row['password_hash'] as String).match(password)) {
        return row['id'] as int;
      }
      return -1;
    } catch (e) {
      return -2;
    } finally {
      await conn.close();
    }
  }

  //-2 for error, -1 for email already in use, positive for success
  static Future<int> register({
    required String name,
    required String surname,
    required String email,
    required String password,})async {
    final MySqlConnection? conn = await ConnectionProvider.getConnection();
    if(conn == null) return -2;

    try {
      var result = await conn.query(
        'SELECT name FROM customer WHERE email = ?', [email],
      );
      if(result.isNotEmpty) return -1;

      final Random rnd = Random();
      const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
      final String salt = String.fromCharCodes(
        Iterable.generate(
          10,
          (_) => chars.codeUnitAt(rnd.nextInt(chars.length))
        )
      );
      final String passwordHash = Crypt.sha256(password, salt: salt).toString();

      result = await conn.query(
        'INSERT INTO customer (name, surname, email, password_hash) '
          'VALUES (?,?,?,?)', [name, surname, email, passwordHash]
      );
      int? affectedRows = result.affectedRows;
      if(affectedRows == null || affectedRows != 1) return -2;
      return 1;
    } catch (e) {
      return -2;
    } finally {
      await conn.close();
    }
  }
}