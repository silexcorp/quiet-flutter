import 'package:flutter/material.dart';

import 'material.dart';
import 'theme_picker.dart';

///App 设置页面
class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurar'),
        titleSpacing: 0,
      ),
      body: Container(
        color: const Color.fromARGB(255, 243, 243, 243),
        child: ListView(
          children: <Widget>[
            SettingGroup(
              title: 'Universal',
              children: <Widget>[
                ListTile(
                  title: Text('Cambiar tema'),
                  onTap: () => ThemePicker.show(context),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
