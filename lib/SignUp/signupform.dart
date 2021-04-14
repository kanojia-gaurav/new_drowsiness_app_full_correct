import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpForm extends StatefulWidget {
  SignUpForm(
      this.emailTextController,
      this.passwordTextController,
      this.nameTextController,
      this.emergencycontactTextController,
      this.parentAction);

  final TextEditingController emailTextController;
  final TextEditingController passwordTextController;
  final TextEditingController nameTextController;
  final TextEditingController emergencycontactTextController;

  final ValueChanged<List<dynamic>> parentAction;

  @override
  State<StatefulWidget> createState() => _SignUpForm();
}

enum GenderEnum { man, woman }

class _SignUpForm extends State<SignUpForm>
    with AutomaticKeepAliveClientMixin<SignUpForm> {
  GenderEnum _userGender = GenderEnum.man;
  String _selectDateString = 'Select your birthday';

  bool _agreedToTerm = false;
  DateTime _selectedDate = DateTime.now();

  Future<Null> _selectDate(BuildContext context) async {
    // ignore: omit_local_variable_types
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(1930, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _selectedDate)
      // ignore: curly_braces_in_flow_control_structures
      setState(() {
        _selectedDate = picked;
        // ignore: prefer_single_quotes
        _selectDateString = "${_selectedDate.toLocal()}".split(' ')[0];
        _passDataToParent('age', calculateAge(picked));
      });
    print('your age is ${calculateAge(picked)}');
  }

  // ignore: always_declare_return_types
  calculateAge(DateTime birthDate) {
    // ignore: omit_local_variable_types
    DateTime currentDate = DateTime.now();
    // ignore: omit_local_variable_types
    int age = currentDate.year - birthDate.year;
    // ignore: omit_local_variable_types
    int month1 = currentDate.month;
    // ignore: omit_local_variable_types
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      // ignore: omit_local_variable_types
      int day1 = currentDate.day;
      // ignore: omit_local_variable_types
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  void _setAgreedToTerm(bool newValue) {
    _passDataToParent('term', newValue);
    setState(() {
      _agreedToTerm = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      margin: const EdgeInsets.all(15.0),
      padding: const EdgeInsets.all(13.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 360,
            child: TextFormField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.mail),
                  labelText: 'Email',
                  hintText: 'Type your email'),
              validator: (String value) {
                if (value.trim().isEmpty) {
                  return 'Email is required';
                } else {
                  return null;
                }
              },
              controller: widget.emailTextController,
            ),
          ),
          // Divider(),
          SizedBox(
            width: 360,
            child: TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.lock),
                  labelText: 'Password',
                  hintText: 'Type password'),
              validator: (String value) {
                if (value.trim().isEmpty) {
                  return 'Password is required';
                } else {
                  return null;
                }
              },
              controller: widget.passwordTextController,
            ),
          ),
          // Divider(),
          SizedBox(
            width: 360,
            child: TextFormField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.account_circle),
                  labelText: 'Name',
                  hintText: 'Type Name'),
              validator: (String value) {
                if (value.trim().isEmpty) {
                  return 'Nickname is required';
                } else {
                  return null;
                }
              },
              controller: widget.nameTextController,
            ),
          ),
          // Divider(),
          SizedBox(
            width: 360,
            child: TextFormField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.contact_phone),
                  labelText: 'emergency Contact',
                  hintText: 'Emergency contact'),
              validator: (String value) {
                if (value.trim().isEmpty) {
                  return 'Emergency contact is required';
                } else {
                  return null;
                }
              },
              controller: widget.emergencycontactTextController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
          ),
          // Divider(),
          Row(
            children: <Widget>[
              Icon(
                Icons.wc,
                color: Colors.grey,
              ),
              Radio(
                value: GenderEnum.man,
                groupValue: _userGender,
                onChanged: (GenderEnum value) {
                  setState(() {
                    _passDataToParent('gender', 'Man');
                    _userGender = value;
                  });
                },
              ),
              // ignore: unnecessary_new
              new GestureDetector(
                onTap: () {
                  setState(() {
                    _passDataToParent('gender', 'Man');
                    _userGender = GenderEnum.man;
                  });
                },
                child: Text('Man'),
              ),
              SizedBox(
                width: 20,
              ),
              Radio(
                value: GenderEnum.woman,
                groupValue: _userGender,
                onChanged: (GenderEnum value) {
                  setState(() {
                    _passDataToParent('gender', 'Woman');
                    _userGender = value;
                  });
                },
              ),
              // ignore: unnecessary_new
              new GestureDetector(
                onTap: () {
                  setState(() {
                    _passDataToParent('gender', 'Woman');
                    _userGender = GenderEnum.woman;
                  });
                },
                child: Text('Woman'),
              ),
            ],
          ),
          // Divider(),
          SizedBox(
            width: 360,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.cake,
                  color: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Container(
                    width: 260,
                    // ignore: deprecated_member_use
                    child: RaisedButton(
                      onPressed: () {
                        _selectDate(context);
                      },
                      // ignore: sort_child_properties_last
                      child: Text(_selectDateString),
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Checkbox(
                  value: _agreedToTerm,
                  onChanged: _setAgreedToTerm,
                ),
                GestureDetector(
                  onTap: () => _setAgreedToTerm(!_agreedToTerm),
                  child: const Text(
                    'I agree to Terms of Services, Privacy Policy',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _passDataToParent(String key, dynamic value) {
    // ignore: omit_local_variable_types
    List<dynamic> addData = List<dynamic>();
    addData.add(key);
    addData.add(value);
    widget.parentAction(addData);
  }

  @override
  bool get wantKeepAlive => true;
}
