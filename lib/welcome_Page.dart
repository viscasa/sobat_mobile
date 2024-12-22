import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sobat_mobile/authentication/login.dart';
import 'package:sobat_mobile/authentication/register.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Spacer(),
            Center(
              child: Container(
                  height: 200, child: Image.asset('assets/herbal.png')),
            ),
            Spacer(),
            Text(
              "Obatnya di Solo",
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              "Sehatnya di Kamu",
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ),
                        );
                      },
                      child: Text("SignUp")),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                      child: Text("Login")),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
