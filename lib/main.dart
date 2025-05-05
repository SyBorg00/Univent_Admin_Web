import 'package:agawin_unievent_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:agawin_unievent_app/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: "https://nvjawcnoopwerheuyvci.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im52amF3Y25vb3B3ZXJoZXV5dmNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ1MTI5NzEsImV4cCI6MjA2MDA4ODk3MX0.XRp3hS8EKHV0SUdodyGn2f1R1UMt7XunV7e9Y0tT0eM",
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(create: (context) => AuthBloc(), child: Login()),
    );
  }
}
