import 'package:flutter/material.dart';
import 'package:signupexample/SignUp/signupform.dart';
import 'package:signupexample/SignUp/signupimages.dart';
import 'package:signupexample/SignUp/signupintroduce.dart';
import 'package:signupexample/Database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signupexample/userscreen/dashboard.dart';
// import 'package:signupexample/userscreen/userscreen.dart';

class SignUpWithMail extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignUpWithMail();
}

class _SignUpWithMail extends State<SignUpWithMail> {
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _nameTextController = TextEditingController();
  final _emergencycontactTextController = TextEditingController();
  final _introduceTextController = TextEditingController();

  // ignore: prefer_final_fields
  Map<String, dynamic> _userDataMap = Map<String, dynamic>();

  // ignore: prefer_final_fields
  PageController _pageController = PageController();

  String _nextText = 'Next';
  Color _nextColor = Colors.green[800];

  // ignore: always_declare_return_types
  _updateMyTitle(List<dynamic> data) {
    setState(() {
      _userDataMap[data[0]] = data[1];
    });
  }

  // ignore: always_declare_return_types
  _setIsLogin() async {
    // ignore: omit_local_variable_types
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogin', true);
  }

  // reference to our single class that manages the database
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    _query();
    _userDataMap['gender'] = 'Man';
    _userDataMap['term'] = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  // ignore: prefer_single_quotes
                  image: ExactAssetImage("assets/images/backgroundImage.jpg"),
                  fit: BoxFit.fill)),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(4.0),
                    padding: const EdgeInsets.only(top: 10, bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[400]),
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 18.0, top: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Create Account',
                              style: TextStyle(
                                  fontSize: 34, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Container(
                          width: 400,
                          height: 500,
                          child: PageView(
                            onPageChanged: (int page) {
                              print('the pageView page is $page');
                              if (page == 2) {
                                setState(() {
                                  _nextText = 'Submit';
                                  _nextColor = Colors.blue[900];
                                });
                              } else {
                                setState(() {
                                  _nextText = 'Next';
                                  _nextColor = Colors.green[800];
                                });
                              }
                            },
                            controller: _pageController,
                            children: <Widget>[
                              SignUpForm(
                                  _emailTextController,
                                  _passwordTextController,
                                  _nameTextController,
                                  _emergencycontactTextController,
                                  _updateMyTitle),
                              SignUpImages(_updateMyTitle),
                              SignUpIntroduce(_introduceTextController)
                            ],
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                // ignore: deprecated_member_use
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        // ignore: unnecessary_new
                                        new BorderRadius.circular(12.0),
                                  ),
                                  // ignore: sort_child_properties_last
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'Cancel',
                                        style: TextStyle(fontSize: 28),
                                      ),
                                    ],
                                  ),
                                  textColor: Colors.black,
                                  color: Colors.white,
                                  padding: EdgeInsets.all(10),
                                  onPressed: () {
                                    print(
                                        'email: ${_emailTextController.text}');
                                    print(
                                        'password: ${_passwordTextController.text}');
                                    print('name: ${_nameTextController.text}');
                                    print(
                                        'intro: ${_introduceTextController.text}');

                                    print('_userDataMap $_userDataMap');
                                    Navigator.pop(context);
//                              _query();
                                  },
                                ),
                              ),
                            ),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  right: 8.0,
                                ),
                                // ignore: deprecated_member_use
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        // ignore: unnecessary_new
                                        new BorderRadius.circular(12.0),
                                  ),
                                  // ignore: sort_child_properties_last
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        _nextText,
                                        style: TextStyle(fontSize: 28),
                                      ),
                                    ],
                                  ),
                                  textColor: Colors.white,
                                  color: _nextColor,
                                  padding: EdgeInsets.all(10),
                                  onPressed: () {
                                    if (_pageController.page.toInt() == 2) {
                                      print('last page');
                                      _insert();
                                      _setIsLogin();

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Dashboard()),
                                      );
                                    } else {
                                      _pageController.animateToPage(
                                          _pageController.page.toInt() + 1,
                                          duration: Duration(milliseconds: 200),
                                          curve: Curves.easeIn);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  // Button onPressed methods

  void _insert() async {
    // row to insert
    // ignore: omit_local_variable_types
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: _nameTextController.text,
      DatabaseHelper.columnGender: _userDataMap['gender'],
      DatabaseHelper.columnEmail: _emailTextController.text,
      DatabaseHelper.columncontact: _emergencycontactTextController.text,
      DatabaseHelper.columnPassword: _passwordTextController.text,
      DatabaseHelper.columnAge: _userDataMap['age'],
      DatabaseHelper.columnImageOne: _userDataMap['image0'],
      DatabaseHelper.columnImageTwo: _userDataMap['image1'],
      DatabaseHelper.columnImageThree: _userDataMap['image2'],
      DatabaseHelper.columnImageFour: _userDataMap['image3'],
      DatabaseHelper.columnImageIntro: _introduceTextController.text,
    };
    final id = await dbHelper.insert(row);
    print('inserted row id: $id');
  }

  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    print('query all rows:');
    allRows.forEach((row) {
      print(row);
      print('row age is ${row[DatabaseHelper.columnAge]}');
      return null;
    });
  }
}
