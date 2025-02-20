import 'package:f5xc_tool/middleware/config.dart';
import 'package:f5xc_tool/middleware/sql_query_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';

import '../model/login_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late FlutterSecureStorage storage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    storage = const FlutterSecureStorage();
    storage.deleteAll();
  }

  void callback(LoginState state, LoginResult? result) {
    if (state == LoginState.fail) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Login failed"),
              content: Text(
                  '${result?.description?["detail"] ?? "Failed to login due to unexpected error. \n"
                      "Code: ${result?.responseCode ?? 400}"}'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Close'))
              ],
            );
          });
    }
    setState(() {
      loginState = state;
      if (result != null) {
        loginResult = result;
      }
    });
  }

  late LoginResult loginResult = LoginResult(responseCode: 100);
  late LoginState loginState = LoginState.none;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          shrinkWrap: true,
          // mainAxisSize: MainAxisSize.min,
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox.square(child: statusLogin(loginState, loginResult), dimension: MediaQuery.of(context).size.width * 0.23,),
            Text(
              "Login",
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: TextFormField(
                        controller: _usernameController,
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                            hintText: 'Username', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                            hintText: 'Password', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    LoginButton(
                      callback: callback,
                      formKey: _formKey,
                      usernameController: _usernameController,
                      passwordController: _passwordController,
                      storage: storage,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  statusLogin(LoginState loginState, LoginResult loginResult) {
    switch (loginState) {
      case LoginState.none:
        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.2,
          child: Lottie.asset('lottie/login_none.json',
              animate: true, repeat: false),
        );
      case LoginState.loading:
        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.2,
          child: Lottie.asset(
            'lottie/login_loading.json',
          ),
        );
      case LoginState.success:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.2,
                child: Lottie.asset(
                  'lottie/login_success.json',
                )),
            Text('Login success. You\'re logged in as '
                '${loginResult.loginData!.user!.fullName ?? "ERROR"}'),
          ],
        );
      case LoginState.fail:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.2,
                child: Lottie.asset(
                  'lottie/login_loading.json',
                )),
            Text(
              'Login failed. Please check your username/password.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text('Error: ${loginResult.description?["detail"]}')
          ],
        );
    }
  }
}

class LoginButton extends StatefulWidget {
  const LoginButton(
      {super.key,
      required Function callback,
      required GlobalKey<FormState> formKey,
      required TextEditingController usernameController,
      required TextEditingController passwordController,
      required FlutterSecureStorage storage})
      : _callback = callback,
        _usernameController = usernameController,
        _passwordController = passwordController,
        _storage = storage;
  final Function _callback;
  final TextEditingController _usernameController;
  final TextEditingController _passwordController;
  final FlutterSecureStorage _storage;

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          widget._callback(LoginState.loading, null);
          onLogin(context, widget._callback, widget._usernameController.text,
              widget._passwordController.text, widget._storage);
        },
        child: const Text('Login'));
  }
}

onLogin(BuildContext context, Function callback, String username,
    String password, FlutterSecureStorage storage) async {
  LoginResult empty = LoginResult(
      responseCode: 400,
      description: {"detail": "Username/password cannot be empty."},
      loginData: LoginModel());
  if (username.isEmpty || password.isEmpty) {
    callback(LoginState.fail, empty);
    return;
  }
  LoginResult login = await SqlQueryHelper().login(username, password);
  if (login.responseCode == 200) {
    callback(LoginState.success, login);
    await storage.write(key: 'auth', value: login.loginData!.accessToken);
    // await storage.write(key: 'login_result', value: jsonEncode(login));
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  } else {
    callback(LoginState.fail, login);
  }
}
