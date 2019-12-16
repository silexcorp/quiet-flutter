import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/part/part.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final GlobalKey<FormState> _formState = GlobalKey();

  TextEditingController _phoneController;
  TextEditingController _passwordController;

  String _loginFailedMessage;

  @override
  void initState() {
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Iniciar sesión"),
        ),
        body: Form(
          key: _formState,
          autovalidate: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(
                  height: 100,
                ),
                TextFormField(
                  controller: _phoneController,
                  validator: (text) {
                    if (text.trim().isEmpty) {
                      return "El número de teléfono no puede estar vacío.";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    errorText: _loginFailedMessage,
                    filled: true,
                    labelText: "Número de teléfono",
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  autofocus: false,
                ),
                const SizedBox(
                  height: 24,
                ),
                PasswordField(
                  validator: (text) {
                    if (text.trim().isEmpty) {
                      return "La contraseña no puede estar vacía";
                    }
                    return null;
                  },
                  controller: _passwordController,
                ),
                const SizedBox(
                  height: 24,
                ),
                RaisedButton(
                  onPressed: _onLogin,
                  child: Text("Haga clic para iniciar sesión",
                      style: Theme.of(context).primaryTextTheme.body1),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ));
  }

  void _onLogin() async {
    if (_formState.currentState.validate()) {
      try {
        var result = await showLoaderOverlay(
            context,
            UserAccount.of(context, rebuildOnChange: false)
                .login(_phoneController.text, _passwordController.text));
        if (result["code"] == 200) {
          Navigator.pop(context); //login succeed
        } else {
          showSimpleNotification(context, Text(result["msg"] ?? "Error de inicio de sesión"));
        }
      } catch (e) {
        showSimpleNotification(context, Text('$e'));
      }
    }
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    this.validator,
    this.controller,
  });

  final FormFieldValidator<String> validator;
  final TextEditingController controller;

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: _obscureText,
      validator: widget.validator,
      controller: widget.controller,
      decoration: InputDecoration(
        border: const UnderlineInputBorder(),
        filled: true,
        labelText: "Contraseña",
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            semanticLabel: _obscureText ? 'Mostrar contraseña' : 'Ocultar contraseña',
          ),
        ),
      ),
    );
  }
}
