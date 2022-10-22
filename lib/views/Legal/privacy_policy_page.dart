import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
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
          "Privacy Policy",
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
                  "assets/images/planit_logo_white.png",
                  fit: BoxFit.contain,
                  height: 100,
                  width: 100,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Last updated August 28, 2022",
                textAlign: TextAlign.center,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                "VSHOOT LLC is the developer and owner of Another Planit.  We, VShoot LLC respect the privacy of our users. This Privacy Policy explains how we use, disclose, and safeguard your information when you use the Another Planit app. Be sure to read this Privacy Policy carefully, and IF YOU DO NOT AGREE WITH THE TERMS OF THIS PRIVACY POLICY, PLEASE DO NOT ACCESS THE APPLICATION. We reserve the right to make changes to this Privacy Policy at any time and for any reason. We will alert you about any changes by updating the “Last updated” date of this Privacy Policy. You are encouraged to periodically review this Privacy Policy to stay informed of updates. You will be deemed to have been made aware of, will be subject to, and will be deemed to have accepted the changes in any revised Privacy Policy by your continued use of the application after the date such revised Privacy Policy is posted. This Privacy Policy does not apply to the third-party online/mobile store from which you install the Application. We are not responsible for any of the data collected by any such third party. ",
                //textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "INFORMATION COLLECTED",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline5?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "The information we may collect via the Application depends on the content and materials you use, and includes:"),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "Personal Data",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline6?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "This information includes personally identifiable information that you voluntarily give to us, including your email address when creating an Another Planit account and an optional profile picture, which you can set from your profile, after creating an account in your profile."),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "Derivative Data",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline6?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "Information our servers need to collect when you access the Application in order to deliver app functionality, such as your native actions that are integral to the Application, including, but not limited your creation of new events, goals, video stories, backlog items, habits, life categories, etc. Such information is securely stored and for the sole purpose of delivering app functionalities to the end-user."),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "Mobile Device Access",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline6?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "Another Planit may ask for access to your photo library in such cases where you would like to set a profile picture or upload a cover video. Additionally, camera access is requested only in the case where a user would like to utilize the video stories feature or create a new cover video. In the case that you opt not to allow our application to utilize these integral device components, you will experience limited application functionality. If you wish to change our access or permissions, you may do so in your device’s settings. Additionally, information such as your device Internet Protocol (“IP”) address, device name, operating system version, the configuration of the app when utilizing our Service, the time and date of your use of the Service, and other statistics may be collected for app efficiency and usability.",
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "Push Notifications",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline6?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "We may request to send you push notifications regarding your account or the Application. If you wish to opt-out from receiving these types of communications, you may turn them off in your device’s settings.",
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "Data From Contests, Giveaways, and Surveys",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline6?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "Personal and other information you may provide when entering contests or giveaways and/or responding to surveys.",
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 5),
              child: Text(
                "USE OF INFORMATION",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline5?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "The information that we collect allows us to efficiency and effectively deliver app functionality to the end-user. Specifically, we may use the information collected via the Application to:"),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text("1. Deliver core app functionalities."),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text("2. Create and maintain your account."),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text("3. Email you regarding your account."),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "4. Increase the efficiency and operation of the Application."),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "5. Monitor and analyze usage and trends to improve your experience with the Application."),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text("6. Notify you of updates to the Application."),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "7. Offer new products, services, mobile applications, and/or recommendations to you."),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "8. Prevent fraudulent transactions, monitor against theft, and protect against criminal activity."),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child:
                  Text("9. Administer sweepstakes, promotions, and contests."),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "10. Request feedback and contact you about your use of the Application."),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text("11. Resolve disputes and troubleshoot problems."),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text("12. Send Newsletters."),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 5),
              child: Text(
                "DISCLOSURE OF INFORMATION ",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline5?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "Under certain circumstances we may need to share the collected information. Such situations are as follows: "),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "By Law or to Protect Rights ",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline6?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "If we believe the release of information about you is necessary to respond to legal process, to investigate or remedy potential violations of our policies, or to protect the rights, property, and safety of others, we may share your information as permitted or required by any applicable law, rule, or regulation. ",
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "Third-Party Service Providers",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline6?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "We may share limited information with third parties that perform services for us or on our behalf including data analysis, email delivery, hosting/storage services, customer service, and marketing assistance. Two such parties being Google cloud-based services and Amazon Web Services.",
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "Business Partners",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline6?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "We may share your information with our business partners to offer you certain products, services or promotions. We are not responsible for the actions of third parties with whom you share personal or sensitive data, and we have no authority to manage or control third-party solicitations. If you no longer wish to receive correspondence, emails or other communications from third parties, you are responsible for contacting the third party directly.",
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "Sale or Bankruptcy",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline6?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "If we reorganize or sell all or a portion of our assets, undergo a merger, or are acquired by another entity, we may transfer your information to the successor entity. If we go out of business or enter bankruptcy, your information would be an asset transferred or acquired by a third party. You acknowledge that such transfers may occur and that the transferee may decline to honor commitments we made in this Privacy Policy. If this is to occur, and you are unsatisfied with the Privacy Policy set forth by the transferee, discontinue your use of the application.",
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 5),
              child: Text(
                "Child Policy",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline5?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "We do not knowingly solicit information from or market to children under the age of 13."),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 5),
              child: Text(
                "MARKETING AND DATA ANALYTICS ",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline5?.fontSize),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "Internet-Based Advertising ",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline6?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "Additionally, we may use third-party software to serve ads on the Application, implement email marketing campaigns, and manage other interactive marketing initiatives. This third-party software may use cookies or similar tracking technology to help manage and optimize your online experience with us. For more information about opting-out of interest-based ads, visit the Network Advertising Initiative Opt-Out Tool or Digital Advertising Alliance Opt-Out Tool ."),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "Analytics",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline6?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "Currently we do not collect any data for analytics, but in the future we may, which may include partnering with selected third-party vendors to allow tracking technologies and remarketing services on the Application through the use of first party cookies and third-party cookies, to, among other things, analyze and track users’ use of the Application, determine the popularity of certain content, and better understand online activity. By accessing the Application, you consent to the collection and use of your information by these third-party vendors."),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 5),
              child: Text(
                "SECURITY OF YOUR INFORMATION",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline5?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "We use administrative, technical, and physical security measures to help protect your personal information. Although we cannot guarantee foolproof security, we make your data privacy our top priority and have taken great measures to optimize the security of all users’ information. Users’ personal information is contained behind secured structures and is only accessible via secured servers and by a limited number of personas who have special access rights. By using this app you accept that we, VShoot LLC, are and will always take the necessary measures to keep all of your data safe, but in thee cases where such safety is compromised outside of our control, VShoot LLC and the Another Planit App is not liable."),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 5),
              child: Text(
                "INFORMATION TRANSPARENCY",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline5?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "We value and follow any rules and regulations which speak to data collection transparency. You may at any time review or change the information in your account or terminate your account by:"),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "- Logging into your account settings and updating your account."),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "-  Contacting us using the contact information provided below Upon your request to terminate your account, we will deactivate or delete your account and information from our active databases. "),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                "Emails and Communications",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline6?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "If you no longer wish to receive correspondence, emails, or other communications from us, you may opt-out by:"),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text("-  Opting to unsubscribe from the correspondences."),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "-  Contacting us using the contact information provided belowIf you no longer wish to receive correspondence, emails, or other communications from third parties, you should contact the third party directly. "),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 5),
              child: Text(
                "CALIFORNIA PRIVACY RIGHTS",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline5?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "California Civil Code Section 1798.83, also known as the “Shine The Light” law, permits our users who are California residents to request and obtain from us, once a year and free of charge, information about categories of personal information (if any) we disclosed to third parties for direct marketing purposes and the names and addresses of all third parties with which we shared personal information in the immediately preceding calendar year. If you are a California resident and would like to make such a request, please submit your request to us using the contact information provided below. If you are under 18 years of age, reside in California, and have a registered account with the Application, you have the right to request removal of unwanted data that you publicly post on the Application. To request removal of such data, please contact us using the contact information provided below, and include the email address associated with your account and a statement that you reside in California. We will make sure the data is not publicly displayed on the Application, but please be aware that the data may not be completely or comprehensively removed from our systems."),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 5),
              child: Text(
                "Contact Us",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline5?.fontSize),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
              child: Text(
                  "If you have questions or comments about this Privacy Policy, please contact us via our website at www.anotherplanit.com or email us at info@thevshoot.com"),
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
