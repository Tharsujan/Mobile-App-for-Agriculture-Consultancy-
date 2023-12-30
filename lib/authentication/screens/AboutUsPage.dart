import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('About Us'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thumi Agro Engineering & Consultancy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Welcome to our company! We are dedicated to providing the best products and services to our customers.',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 24),
              SectionHeader('Our Mission'),
              SizedBox(height: 8),
              Text(
                'To deliver high-quality products and exceptional services that exceed our customers\' expectations.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              SectionHeader('Contact Us'),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ContactIconButton(
                    icon: Icons.phone,
                    color: Colors.blue,
                    onPressed: () {
                      launch("tel://0705759523");
                    },
                  ),
                  ContactIconButton(
                    icon: Icons.web,
                    color: Colors.blue,
                    onPressed: () {
                      launch(
                          "https://www.templatemonster.com/website-templates/tag/plants/r");
                    },
                  ),
                  ContactIconButton(
                    icon: Icons.facebook,
                    color: Colors.blue,
                    onPressed: () {
                      launch(
                          "https://www.facebook.com/thars.sujan?mibextid=2JQ9oc");
                    },
                  ),
                  ContactIconButton(
                    icon: Icons.email,
                    color: Colors.blue,
                    onPressed: () async {
                      final Uri _emailLaunchUri = Uri(
                        scheme: 'mailto',
                        path: 'thumi@gmail.com',
                        queryParameters: {'subject': 'Hello from our app'},
                      );
                      final String _emailLaunchString =
                          _emailLaunchUri.toString();
                      await launch(_emailLaunchString);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class ContactIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  ContactIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: CircleBorder(),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: color,
        ),
      ),
    );
  }
}
