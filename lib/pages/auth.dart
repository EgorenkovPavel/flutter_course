import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped_models/main.dart';
import '../models/auth.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AuthPageState();
  }
}

class AuthPageState extends State<AuthPage> {
  String _login;
  String _password;
  bool acceptTerms = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  AuthMode _authMode = AuthMode.LOGIN;

  DecorationImage _buildBackgroungImage() {
    return DecorationImage(
      fit: BoxFit.cover,
      colorFilter:
          ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop),
      image: AssetImage('assets/background.jpg'),
    );
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'E-mail', filled: true, fillColor: Colors.white),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {},
      onSaved: (String value) {
        _login = value;
      },
    );
  }

  Widget _buildPasswordConfirmTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Confirm password', filled: true, fillColor: Colors.white),
      obscureText: true,
      validator: (String value) {
        if (_passwordTextController.text != value) {
          return 'Password do not match';
        }
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Password', filled: true, fillColor: Colors.white),
      obscureText: true,
      controller: _passwordTextController,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Password is empty';
        }
      },
      onSaved: (String value) {
        _password = value;
      },
    );
  }

  Widget _buildAcceptSwitch() {
    return SwitchListTile(
      title: Text('Accept terms'),
      value: acceptTerms,
      onChanged: (bool value) {
        setState(() {
          acceptTerms = value;
        });
      },
    );
  }

  void _submitForm(Function authenticate) async {
    if (!_formKey.currentState.validate() || !acceptTerms) {
      return;
    }
    _formKey.currentState.save();

    Map<String, dynamic> info = await authenticate(_login, _password, _authMode);

    if (!info['success']) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(info['message']),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
      return;
    }

    Navigator.pushReplacementNamed(context, '/products');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Form(
          key: _formKey,
          child: Container(
            decoration: BoxDecoration(image: _buildBackgroungImage()),
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(children: <Widget>[
                    _buildEmailTextField(),
                    SizedBox(
                      height: 10.0,
                    ),
                    _buildPasswordTextField(),
                    SizedBox(
                      height: 10.0,
                    ),
                    _authMode == AuthMode.SINGUP
                        ? _buildPasswordConfirmTextField()
                        : Container(),
                    _buildAcceptSwitch(),
                    FlatButton(
                      child: Text(
                          'Switch to ${_authMode == AuthMode.LOGIN ? 'Signup' : 'Login'}'),
                      onPressed: () {
                        setState(() {
                          if (_authMode == AuthMode.LOGIN) {
                            _authMode = AuthMode.SINGUP;
                          } else {
                            _authMode = AuthMode.LOGIN;
                          }
                        });
                      },
                    ),
                    ScopedModelDescendant<MainModel>(
                      builder: (BuildContext context, Widget child,
                          MainModel model) {
                        return model.isLoading
                            ? CircularProgressIndicator()
                            : RaisedButton(
                                color: Theme.of(context).accentColor,
                                textColor: Colors.white,
                                child: Text(_authMode == AuthMode.LOGIN
                                    ? 'LOGIN'
                                    : 'SIGN UP'),
                                onPressed: () =>
                                    _submitForm(model.authenticate));
                      },
                    )

//                  )
//                  GestureDetector(
//                    onTap: _submitForm,
//                    child: Container(
//                      color: Colors.green,
//                      padding: EdgeInsets.all(5.0),
//                      child: Text('My button'),

//                    ),
//                  )
                  ]),
                ),
              ),
            ),
          ),
        ));
  }
}
