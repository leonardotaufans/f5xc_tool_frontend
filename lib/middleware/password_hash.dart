
import 'package:crypt/crypt.dart';

class PasswordHash {
  //todo: Remove salt from here
  final String _salt = "arTx206oR1_";
  String encryptPassword(String rawString) {
    final d0 = Crypt.sha512(rawString, salt: _salt);
    return d0.toString();
  }
}