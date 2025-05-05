import 'package:agawin_unievent_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:agawin_unievent_app/bloc/auth_bloc/auth_event.dart';
import 'package:agawin_unievent_app/bloc/auth_bloc/auth_state.dart';
import 'package:agawin_unievent_app/screen/admin/admin_dashboard.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      if (context.mounted) {
        context.read<AuthBloc>().add(CheckAuthSession());
      }
    });

    final size = MediaQuery.of(context).size;
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthStates>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()),
            );
          }
          if (state is AuthFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Container(
                width: size.width,
                height: size.height,
                color: Color.fromARGB(255, 4, 3, 84),
              ),
              SizedBox(
                width: size.width,
                height: size.height * 2,
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset('images/bagobo_pattern_white.png'),
                ),
              ),

              titleSide(size),
              signInSide(size, emailController, passwordController, context),
            ],
          );
        },
      ),
    );
  }

  Positioned titleSide(Size size) {
    return Positioned(
      left: 0,
      width: size.width * .55,
      height: size.height,
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size.width * 5,
              height: 150,
              child: Image.asset('images/university_brand.png'),
            ),
            Text(
              "UNIVENTS",
              style: TextStyle(fontSize: 70, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Positioned signInSide(
    Size size,
    TextEditingController emailController,
    TextEditingController passwrodController,
    BuildContext context,
  ) {
    return Positioned(
      right: 0,
      child: Container(
        width: size.width * .45,
        height: size.height,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            bottomLeft: Radius.circular(40),
          ),
        ),
        padding: EdgeInsets.only(left: 50, right: 50),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 125,
              height: 125,
              child: Image.asset('images/university_seal.png'),
            ),
            Text(
              "Welcome, Atenean",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 40),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: emailController,
                decoration: inputDesign("Email"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: passwrodController,
                decoration: inputDesign("Password"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                top: 8.0,
                bottom: 40,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: "Forgot Password?",
                      style: TextStyle(
                        color: Color.fromARGB(255, 4, 3, 84),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 350,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 22, 17, 177),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        context.read<AuthBloc>().add(
                          EmailSignInRequested(
                            emailController.text,
                            passwrodController.text,
                          ),
                        );
                      },
                      child: Text("Login"),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "Or Sign-In via:",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(GoogleSignInRequested());
                    },
                    icon: Row(
                      children: [
                        Icon(FontAwesomeIcons.google),
                        SizedBox(width: 10),
                        Text("Google", style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Row(
                      children: [
                        Icon(FontAwesomeIcons.facebook),
                        SizedBox(width: 10),
                        Text("Facebook", style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration inputDesign(text) {
    return InputDecoration(labelText: text, border: UnderlineInputBorder());
  }
}
