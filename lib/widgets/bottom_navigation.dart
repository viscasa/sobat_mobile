import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sobat_mobile/authentication/login.dart';
import 'package:sobat_mobile/drug/screens/list_drugentry.dart';

class bottomNavigationBar extends StatefulWidget {
  final CookieRequest request;
  const bottomNavigationBar({super.key, required this.request});

  @override
  State<bottomNavigationBar> createState() => _bottomNavigationBarState();
}

class _bottomNavigationBarState extends State<bottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(1),
        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(
              24,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12.0,
              spreadRadius: 2.0,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 4),
          child: GNav(
            tabBackgroundColor: Colors.green.shade900,
            tabBorderRadius: 30,
            iconSize: 20,
            gap: 5,
            tabs: [
              GButton(
                iconActiveColor: Colors.white,
                iconColor: Colors.black,
                icon: FontAwesomeIcons.house,
                onPressed: () {},
              ),
              GButton(
                iconActiveColor: Colors.white,
                iconColor: Colors.black,
                icon: FontAwesomeIcons.prescriptionBottleMedical,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DrugEntryPage()),
                  );
                },
              ),
              GButton(
                iconActiveColor: Colors.white,
                iconColor: Colors.black,
                icon: FontAwesomeIcons.shop,
                onPressed: () {},
              ),
              GButton(
                icon: FontAwesomeIcons.rightFromBracket,
                iconActiveColor: Colors.white,
                iconColor: Colors.black,
                onPressed: () async {
                  final response = await widget.request.logout(
                      "https://m-arvin-sobat.pbp.cs.ui.ac.id/logout_mobile/");
                  String message = response["message"];
                  if (context.mounted) {
                    if (response['status']) {
                      String uname = response["username"];
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("$message Sampai jumpa, $uname."),
                      ));
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
