// main.dart
import 'package:flutter/material.dart';
import 'package:imgpickapp/login/view/login_view.dart';
import 'package:imgpickapp/login/vm/login_vm.dart';
import 'package:imgpickapp/viewmodel/user_viewmodel.dart';
import 'package:imgpickapp/views/user_managment_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserViewModel()),
        ChangeNotifierProvider(create: (context) => LoginViewModel()),
      ],
      child: MaterialApp(
        title: 'User Management App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: LoginView(),
      ),
    );
  }
}
