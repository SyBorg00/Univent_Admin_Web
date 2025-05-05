import 'package:flutter/material.dart';

class OrganizationBanner extends StatelessWidget {
  final String? uid;
  final String? name;
  final String? email;
  final String? facebook;
  final CircleAvatar? logo;
  final Widget? banner;

  const OrganizationBanner({
    super.key,
    this.uid,
    this.name,
    this.email,
    this.facebook,
    this.logo,
    this.banner,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: AspectRatio(
              aspectRatio: 2 / 3,
              child:
                  banner ??
                  Image.asset('images/placeholder_bg.webp', fit: BoxFit.fill),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 8, 8, 8),
                      Color.fromARGB(255, 24, 24, 24),
                      Color.fromARGB(220, 24, 24, 24),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 0.6, 0.85, 1.0],
                  ),
                ),
              ),
            ),
          ),
          Positioned(left: 0, right: 0, top: 90, child: logo ?? CircleAvatar()),
          Positioned(
            left: 0,
            right: 0,
            bottom: 120,
            child: Column(
              children: [
                Text(
                  name ?? "Title",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontSize: 35,
                  ),
                ),
                Text(
                  email ?? "Email",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
                Text(
                  facebook ?? "Facebook",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
