import 'package:flutter/material.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({Key? key}) : super(key: key);

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text(
          "Terms of Use",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        //automaticallyImplyLeading: false,
        elevation: 0.0,
      ),
      body: Container(
        margin: EdgeInsets.all(12),
        //padding: EdgeInsets.all(30),
        child: ListView(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Image.asset(
                  "assets/images/planit_logo.png",
                  fit: BoxFit.contain,
                  height: 100,
                  width: 100,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Last updated September 7, 2022",
                textAlign: TextAlign.center,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                  "Welcome to Another Planit by VShoot LLC! These Terms of Use govern your use of Another Planit. When you create an Another Planit account or use Another Planit, you agree to these terms."),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "Our Service",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline5?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "We, VShoot LLC, are excited to provide you with the Another Planit app. Our top priority is to provide users with a secure and effective experience."),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "Privacy Policy",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline5?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "In order to provide this service, it requires us to collect and securely utilize certain information from you. Our Privacy Policy explains how we collect, use, and secure your information. By using Another Planit, you accept the terms set forth by the Privacy Policy."),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "Your Role as a User",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline5?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "It is our role as the service provider to provide users with the advertised capabilities and environment. In order to do this, we need you to also commit to your role and responsibilities as a user. To be a user of Another Planit, we ask that you agree and follow through with the following responsibilities and restrictions. If you violate any of these terms, or those set forth by any of our policies, we, VShoot LLC, reserve the right to terminate your account without notification."),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text("- You must be at least 13 years old."),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text("- You must not be a convicted sex offender."),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "- We must not have previously disabled your account for violation of law or any of our policies. "),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "- You must not use this service to participate in malicious activities of any sort. This includes, but is not limited to, impersonating others or providing inaccurate information, engaging in unlawful, misleading or fraudulent behaviors."),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "- You must not be prohibited from receiving any aspect of our Service under applicable laws."),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "Our Permissions",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline5?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "By signing up for, and using this service, you give us permission to:"),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "- Store and use the information that you create throughout thee app to enable the functionalities of the app."),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "- Download and install updates to Another Planit on your device when available."),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "- Store and use your information when necessary as outlined by our Privacy Policy."),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "Limited License",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline5?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "Your use of Another Planit serves as your agreement to the following terms and are to be considered in addition to the guidelines outlined in Apple's End User License Agreement. VShoot LLC grants you a revocable, non-exclusive, non-transferable, limited right to install and use Another Planit on a single mobile device controlled and owned by you, and to access and use the application on such mobile device strictly in accordance with the terms and agreements of this license and any service agreement associated with your mobile device including, but not limited to Apple's App Store Terms of Service (collectively “Related Agreements”)."),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "Use Restrictions",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline5?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "You shall use the Another Planit application strictly in accordance with the terms of the Related Agreements and shall not: (a) decompile, reverse engineer, disassemble, attempt to derive the source code of, or decrypt the Application; (b) make any modification, adaptation, improvement, enhancement, translation or derivative work from the Application; (c) violate any applicable laws, rules or regulations in connection with Your access or use of the Application; (d) remove, alter or obscure any proprietary notice (including any notice of copyright or trademark) of VShoot LLC or its affiliates, partners, suppliers or the licensors of the Application; (e) use the Application for any revenue generating endeavor, commercial enterprise, or other purpose for which it is not designed or intended; (f) use the Application for creating a product, service or software that is, directly or indirectly, competitive with or in any way a substitute for any services, product or software offered by VShoot LLC; (g) use the Application to send automated queries to any website or to send any unsolicited commercial e- mail; or (h) use any proprietary information or interfaces of VShoot LLC or other intellectual property of VShoot LLC in the design, development, manufacture, licensing or distribution of any applications, accessories or devices for use with the Application."),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "Disclaimers",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline5?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "- Our Service is provided 'as is,' and we can't guarantee it will be 100% safe and secure or will work perfectly all the time. TO THE EXTENT PERMITTED BY LAW, WE DISCLAIM ALL WARRANTIES, WHETHER EXPRESSED OR IMPLIED, INCLUDING THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND NON-INFRINGEMENT."),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "- We cannot control what people do or say, and we aren’t responsible for their (or your) actions or conduct (whether online or offline) or content (including unlawful or objectionable content). We also aren’t responsible for services and features offered by other people or companies, even if you access them through our Service."),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "- Our responsibility for anything that happens on the Service (also called 'liability') is limited as much as the law will allow. If there is an issue with our Service, we can't know what all the possible impacts might be. This includes if your content, account and/or information is deleted."),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "Contact Information",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline5?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "If you have any questions about this Agreement, please contact us at info@thevshoot.com."),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
