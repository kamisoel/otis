import 'package:flutter/material.dart';
import 'package:validators/validators.dart';

class AddUserPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _AddUserPageState();
}

class AddUserData {
  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _data = AddUserData();

  String _validateEmail(String value) {
    try {
      isEmail(value);
    } catch (e) {
      return 'The E-mail Address must be a valid email address.';
    }

    return null;
  }

  String _validatePassword(String value) {
    if (value.length < 8) {
      return 'The Password must be at least 8 characters.';
    }

    return null;
  }

  String _validateName(String value) {
    if(value.isEmpty) {
      return 'Name cannot be empty!';
    }
    return null;
  }

  void submit() {
    if (this._formKey.currentState.validate()) { // validate form
      _formKey.currentState.save(); // Save our form now.

      Navigator.pop(context, _data);
    }

  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Login'),
      ),
      body: new Container(
          padding: new EdgeInsets.all(20.0),
          child: new Form(
            key: this._formKey,
            child: new ListView(
              children: <Widget>[
                new TextFormField(
                    keyboardType: TextInputType.text, // Use email input type for emails.
                    decoration: new InputDecoration(
                        hintText: 'Max',
                        labelText: 'Vorname'
                    ),
                    validator: _validateName,
                    onSaved: (String value) {
                      _data.firstName = value;
                    }
                ),
                new TextFormField(
                    keyboardType: TextInputType.text, // Use email input type for emails.
                    decoration: new InputDecoration(
                        hintText: 'Mustermann',
                        labelText: 'Nachname'
                    ),
                    validator: _validateName,
                    onSaved: (String value) {
                      _data.lastName = value;
                    }
                ),
                new TextFormField(
                    keyboardType: TextInputType.emailAddress, // Use email input type for emails.
                    decoration: new InputDecoration(
                        hintText: 'you@example.com',
                        labelText: 'E-mail Addresse'
                    ),
                    validator: _validateEmail,
                    onSaved: (String value) {
                      _data.email = value;
                    }
                ),
                new TextFormField(
                    obscureText: true, // Use secure text for passwords.
                    decoration: new InputDecoration(
                        hintText: 'Passwort',
                        labelText: 'Passwort',
                    ),
                    validator: _validatePassword,
                    onSaved: (String value) {
                      _data.password = value;
                    }
                ),
                new Container(
                  width: screenSize.width,
                  child: new RaisedButton(
                    child: new Text(
                      'Login',
                      style: new TextStyle(
                          color: Colors.white
                      ),
                    ),
                    onPressed: this.submit,
                    color: Colors.blue,
                  ),
                  margin: new EdgeInsets.only(
                      top: 20.0
                  ),
                )
              ],
            ),
          )
      ),
    );
  }
}