import 'package:flutter/material.dart';
import 'package:signupexample/SignIn/signin.dart';
import 'package:signupexample/SignIn/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signupexample/userscreen/dashboard.dart';

//to run flutter app with minimum MB
//flutter build apk --split-per-abi
//.\gradlew signingReport for creatign sha1

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
      // routes: [],
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLogin = false;
  // ignore: always_declare_return_types
  _checkLogin() async {
    // ignore: omit_local_variable_types
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLogin = (prefs.get('isLogin') ?? false);

    setState(() {
      _isLogin = isLogin;
    });

    print('prefs $isLogin');
  }

  @override
  void initState() {
    _checkLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !_isLogin ? _signInWidget() : Dashboard();
  }

  Widget _signInWidget() {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            image: DecorationImage(
                // image: NetworkImage(
                //     'https://cdn.pixabay.com/photo/2020/03/19/04/58/coconut-trees-4946270_1280.jpg'),
                // fit: BoxFit.fill)
                // ignore: prefer_single_quotes
                image: ExactAssetImage("assets/images/backgroundImage.jpg"),
                fit: BoxFit.fill)),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                //mainLogo(),
                SignIn(),
                SignUp()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
