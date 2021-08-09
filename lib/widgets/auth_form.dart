import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/helper.dart';
import '../providers/auth_provider.dart';
import '../models/http_exception.dart';

enum AuthMode { Signup, Login }

class AuthForm extends StatefulWidget {
  final BoxConstraints? authConstraints;

  const AuthForm({Key? key, this.authConstraints}) : super(key: key);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  AuthMode _authMode = AuthMode.Login;
  final GlobalKey<FormState> _formKey = GlobalKey();
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  String? _emailErrorText;
  bool _emailError = false;
  String? _passwordErrorText;
  bool _passwordError = false;
  String? _confirmPasswordErrorText;
  bool _confirmPasswordError = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }



  Future<void> _submit() async {
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<AuthProvider>(context, listen: false).login(
          _authData['email'],
          _authData['password'],
        );
      } else {
        await Provider.of<AuthProvider>(context, listen: false).signup(
          _authData['email'],
          _authData['password'],
        );
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password';
      }
      Helper.showErrorDialog(context, errorMessage);
    } catch (error) {
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      Helper.showErrorDialog(context, errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  InputDecoration? _textFormFieldDecoration(String hintText, String? errorText) {
    return InputDecoration(
      errorText: errorText,
      hintText: hintText,
      fillColor: const Color(0xFFECEFF1),
      filled: true,
      contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32.0),
        borderSide: BorderSide(color: Color(0xFFECEFF1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32.0),
        borderSide: BorderSide(color: Color(0xFFECEFF1)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32.0),
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32.0),
        borderSide: BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: widget.authConstraints!.maxHeight * 0.5,
        width: widget.authConstraints!.maxWidth * 0.8,
        constraints: BoxConstraints(
            minHeight: _authMode == AuthMode.Signup
                ? widget.authConstraints!.maxHeight * 0.5
                : widget.authConstraints!.maxWidth * 0.4),
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (ctx, formConstraints) {
              return Container(
                height: _authMode == AuthMode.Signup
                    ? formConstraints.maxHeight
                    : formConstraints.maxHeight * 0.7,
                constraints: BoxConstraints(
                    minHeight: _authMode == AuthMode.Signup
                        ? formConstraints.maxHeight
                        : formConstraints.maxHeight * 0.7),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: _textFormFieldDecoration('E-mail', _emailError ? _emailErrorText! : null),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          String emailErrorText = '';
                          bool emailError = false;
                          if (value!.isEmpty) {
                            emailErrorText = 'E-mail is required.';
                            emailError = true;
                          } else if (!value.contains('@')) {
                            emailErrorText = 'Invalid E-mail.';
                            emailError = true;
                          }
                          if(emailError) {
                            setState(() {
                              _emailError = emailError;
                              _emailErrorText = emailErrorText;
                            });
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if(_emailError) {
                            setState(() {
                              _emailError = false;
                              _emailErrorText = null;
                            });
                          }
                        },
                        onSaved: (value) {
                          if(!_emailError) {
                            _authData['email'] = value!;
                          }
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        obscureText: true,
                        decoration: _textFormFieldDecoration('Password' , _passwordError ? _passwordErrorText : null),
                        controller: _passwordController,
                        validator: (value) {
                          String passwordErrorText = '';
                          bool passwordError = false;
                          if (value!.isEmpty) {
                            passwordErrorText = 'Password is required.';
                            passwordError = true;
                          } else if (value.length < 5) {
                            passwordErrorText = 'Password is too short.';
                            passwordError = true;
                          }
                          if(passwordError) {
                            setState(() {
                              _passwordError = passwordError;
                              _passwordErrorText = passwordErrorText;
                            });
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if(_passwordError) {
                            setState(() {
                              _passwordError = false;
                              _passwordErrorText = null;
                            });
                          }
                        },
                        onSaved: (value) {
                          if(!_passwordError) {
                            _authData['password'] = value!;
                          }
                        },
                      ),
                      if (_authMode == AuthMode.Signup)
                        const SizedBox(height: 20.0),
                      if (_authMode == AuthMode.Signup)
                        TextFormField(
                          enabled: _authMode == AuthMode.Signup,
                          obscureText: true,
                          decoration:
                              _textFormFieldDecoration('Confirm Password', _confirmPasswordError ? _confirmPasswordErrorText : null),
                          validator: _authMode == AuthMode.Signup
                              ? (value) {
                                  String confirmPasswordErrorText = '';
                                  bool confirmPasswordError = false;
                                  if(value!.isEmpty) {
                                    confirmPasswordErrorText = 'Confirm password is required.';
                                    confirmPasswordError = true;
                                  } else if (value != _passwordController.text) {
                                    confirmPasswordErrorText = 'Passwords do not match.';
                                    confirmPasswordError = true;
                                  }
                                  if(confirmPasswordError) {
                                    setState(() {
                                      _confirmPasswordError = confirmPasswordError;
                                      _confirmPasswordErrorText = confirmPasswordErrorText;
                                    });
                                  }
                                  return null;
                                }
                              : null,
                          onChanged: (value) {
                            if(_confirmPasswordError) {
                              setState(() {
                                _confirmPasswordError = false;
                                _confirmPasswordErrorText = null;
                              });
                            }
                          },
                        ),
                      const SizedBox(height: 25.0),
                      if (_isLoading)
                        CircularProgressIndicator(
                            color: Theme.of(context).primaryColor)
                      else
                        Material(
                          elevation: 1.0,
                          borderRadius: BorderRadius.circular(30.0),
                          clipBehavior: Clip.antiAlias,
                          color: Theme.of(context).primaryColor,
                          child: MaterialButton(
                            minWidth: formConstraints.maxWidth * 0.6,
                            padding: const EdgeInsets.fromLTRB(
                                20.0, 15.0, 20.0, 15.0),
                            child: Text(
                              _authMode == AuthMode.Login ? 'Login' : 'Signup',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              _formKey.currentState!.validate();
                              if(_authMode == AuthMode.Login) {
                                if (_emailError || _passwordError) {
                                  return;
                                }
                                _submit();
                              } else {
                                if (_emailError || _passwordError || _confirmPasswordError) {
                                  return;
                                }
                                _submit();
                              }
                            },
                          ),
                        ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _authMode == AuthMode.Login
                                  ? 'Don\'t have an account?'
                                  : 'Have an account?',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                            MaterialButton(
                              clipBehavior: Clip.antiAlias,
                              padding: EdgeInsets.symmetric(horizontal: 2.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                _authMode == AuthMode.Login
                                    ? 'Create'
                                    : 'Login',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 12,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _emailError = false;
                                  _passwordError = false;
                                  _confirmPasswordError = false;
                                });
                                _switchAuthMode();
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
