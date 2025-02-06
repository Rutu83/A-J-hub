import 'package:allinone_app/utils/configs.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class CharityScreen extends StatefulWidget {
  const CharityScreen({super.key});

  @override
   CharityScreenState createState() =>  CharityScreenState();
}

class  CharityScreenState extends State<CharityScreen> {

  Map<String, dynamic>? charityData;
  String total = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCharityData();
  }

  Future<void> fetchCharityData() async {
    const String url = '${BASE_URL}charity/total';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          charityData = json.decode(response.body);

          total = (charityData!['total_charity'] / 5).toStringAsFixed(0);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              'Charity',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        elevation: 4,
        shadowColor: Colors.red.shade200,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),




      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Background image tapped')),
                  );
                },
                child: Image.asset(
                  'assets/images/c6.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Make a Difference",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Join us in transforming lives through education, food, and care. Explore our programs and contribute to the cause.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: buildCustomButton(
                          context,
                          'Skill School',
                          Icons.school,
                          '₹ $total',
                          Colors.red
                            //  () => showCustomBottomSheet(context, buildSkillSchoolContent()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: buildCustomButton(
                          context,
                          'Food',
                          Icons.fastfood,
                          '₹ $total',
                          Colors.red
                            //  () => showCustomBottomSheet(context, buildFoodContent()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: buildCustomButton(
                          context,
                          'Tree Plantation',
                          Icons.park,
                          '₹ $total',
                          Colors.red
                           //   () => showCustomBottomSheet(context, buildTreePlantationContent()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: buildCustomButton(
                          context,
                          'Indian Games',
                          Icons.sports_kabaddi,
                          '₹ $total',
                          Colors.red
                            //  () => showCustomBottomSheet(context, buildIndianGamesContent()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: buildCustomButton(
                          context,
                          'Child Care',
                          Icons.child_care,
                          '₹ $total',
                          Colors.red
                             // () => showCustomBottomSheet(context, buildChildCareContent()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }



  Widget buildCustomButton(BuildContext context, String title, IconData icon, String amount, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      ),
      onPressed: (){

      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Text(
              amount,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }



  void showCustomBottomSheet(BuildContext context, Widget content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: content,
      ),
    );
  }

  Widget buildSkillSchoolContent() {
    return Container(
      color: Colors.red.shade50,
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Skill School Foundation',
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
            ),
            const SizedBox(height: 16),

            buildStyledSection(
              title: 'Who We Are',
              content:
              'We started in 2015 with 4 children and a teacher in a small room. '
                  'The SKILL SCHOOL is a dedicated and passionate team who work together '
                  'with their untiring efforts and deep understanding. The team works '
                  'selflessly with utmost care and passion. Self-help skills are taught '
                  'in a unique and playful way.',
            ),
            const SizedBox(height: 16),

            buildStyledSection(
              title: 'Why We Are Unique',
              content:
              'We think out of the box to bring out the hidden talent of each child.',
            ),
            const SizedBox(height: 16),

            buildStyledSection(
              title: 'Family Counselling',
              content:
              'SkillSchool team provides family counseling to help parents become aware of what is happening with the child. '
                  'Family counseling can help the whole family communicate better and resolve issues.',
            ),
            const SizedBox(height: 16),

            buildStyledSection(
              title: 'Respite and Day Care',
              content:
              'SkillSchool foundation provides day care facilities for all children with special needs.',
            ),
            const SizedBox(height: 16),

            buildStyledSection(
              title: 'Hostel Facility',
              content:
              'SkillSchool foundation provides accommodation with hygienic food and a clean environment for children with special needs.',
            ),
            const SizedBox(height: 16),

            buildStyledSection(
              title: 'We Provide',
              content:
              'Therapies and education to children, including special education, occupational therapy, sensory integration therapy, and more.',
            ),
            const SizedBox(height: 16),

            buildStyledSection(
              title: 'Expertise Areas',
              content:
              'Intellectual disabilities, Autism, ADHD, Learning disabilities, Mental retardation, Down syndrome, Cerebral palsy, and Slow learners.',
            ),
            const SizedBox(height: 16),

            buildStyledSection(
              title: 'About Us',
              content:
              'We believe in a holistic approach. Each child has a unique talent that must be nurtured and developed.',
            ),
            const SizedBox(height: 16),

          ],
        ),
      ),
    );
  }

  Widget buildStyledSection({required String title, required String content}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget buildFoodContent() {
    return Container(
      color: Colors.red.shade50,
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fastfood, color: Colors.red.shade800, size: 36),
                const SizedBox(width: 10),
                Text(
                  'The Akshaya Patra Foundation',
                  style: GoogleFonts.roboto(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'The Akshaya Patra Foundation is a not-for-profit organisation headquartered in Bengaluru, India. '
                      'The Foundation strives to eliminate classroom hunger by implementing the PM POSHAN (Mid-Day Meal) Programme. '
                      'It provides nutritious meals to children studying in government schools and government-aided schools. '
                      'Akshaya Patra also aims to counter malnutrition and support the Right to Education of children hailing from socio-economically challenging backgrounds.',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            buildStyledSection1(
              icon: Icons.visibility,
              title: 'Our Vision',
              content: 'No child in India shall be deprived of education because of hunger.',
            ),
            const SizedBox(height: 16),
            buildStyledSection1(
              icon: Icons.flag,
              title: 'Our Mission',
              content: 'To feed 3 million children every day by 2025.',
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bar_chart, color: Colors.red.shade800, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          'Impact Statistics',
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '• Over 4 billion meals served\n'
                          '• Over 2.25 million+ children benefitted\n'
                          '• Reached to over 23,000 schools\n'
                          '• 16 States and 2 Union Territories\n'
                          '• 75 Locations',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),


          ],
        ),
      ),
    );
  }

  Widget buildStyledSection1({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.red.shade800, size: 28),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }




  Widget buildTreePlantationContent() {
    return Container(
      color: Colors.red.shade50,
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.park, color: Colors.red.shade800, size: 36),
                const SizedBox(width: 10),
                Text(
                  'SayTrees',
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.red.shade800, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          'About Us',
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Bangalore, fondly called “The city of Gardens” inspired fables and verses alike. With an unbelievably pleasant weather throughout the year, it was a green haven for decades. '
                          'Corporation of the city and rapid influx of the IT industry brought jobs and investments galore, but took a toll on the natural beauty the city was blessed with. '
                          'That\'s when a motley group of individuals - software engineers at work and passionate tree lovers at heart came together, and ‘SayTrees’ was born.',
                      style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            buildStyledSection2(
              icon: Icons.visibility,
              title: 'Our Mission',
              content: 'To make citizens aware about the need of trees for our survival and protect natural resources for generations to come.',
            ),
            const SizedBox(height: 16),

            // Card(
            //   elevation: 4,
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Padding(
            //     padding: const EdgeInsets.all(16.0),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Row(
            //           children: [
            //             Icon(Icons.link, color: Colors.red.shade800, size: 28),
            //             const SizedBox(width: 10),
            //             Text(
            //               'Quick Links',
            //               style: GoogleFonts.roboto(
            //                 fontSize: 20,
            //                 fontWeight: FontWeight.bold,
            //                 color: Colors.red.shade800,
            //               ),
            //             ),
            //           ],
            //         ),
            //         const SizedBox(height: 10),
            //         Text(
            //           '• Home\n'
            //               '• About\n'
            //               '• Impact\n'
            //               '• Mission & Vision\n'
            //               '• Get Involved\n'
            //               '• Projects\n'
            //               '• Donate\n'
            //               '• Contact\n',
            //           style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
            //         ),
            //       ],
            //     ),
            //   ),),
            // const SizedBox(height: 16),
            // buildTeamSection(),
            // const SizedBox(height: 16),
            // buildContactUsSection(),
          ],
        ),
      ),
    );
  }

  Widget buildStyledSection2({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.red.shade800, size: 28),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTeamSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.group, color: Colors.red.shade800, size: 28),
                const SizedBox(width: 10),
                Text(
                  'Meet Our Team',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            buildTeamMember('Kapil Sharma', 'Founder & Director'),
            buildTeamMember('Deokant Payasi', 'Trustee'),
            buildTeamMember('Durgesh Agrahari', 'Head of Partnerships & Projects'),
            buildTeamMember('Nitin Nath', 'Program Manager, Delhi/NCR'),
            buildTeamMember('Shashank Sharma', 'Program Manager, Bengaluru'),
            buildTeamMember('Madhusudhan Iyenger', 'Program Manager, Bengaluru'),
            buildTeamMember('Shivam', 'Project Manager, DLHI/NCR'),
            buildTeamMember('Arpana Shetty', 'Program Manager, Outreach & Marketing'),
            buildTeamMember('Mudassir Pasha', 'Operations Coordinator, South India'),
          ],
        ),
      ),
    );
  }

  Widget buildTeamMember(String name, String role) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(Icons.person, color: Colors.red.shade800, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$name - $role',
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContactUsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.contact_mail, color: Colors.red.shade800, size: 28),
                const SizedBox(width: 10),
                Text(
                  'Contact Us',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Address: No. 6, 1st Cross, First Floor, Basapura, Near Hosa Road Junction, Bengaluru, Karnataka 560100',
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 5),
            Text(
              'Phone: +91 - 96635 77758',
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 5),
            Text(
              'Email: info@saytrees.org',
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }



  Widget buildChildCareContent() {
    return Container(
      color: Colors.red.shade50,
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.child_care, color: Colors.red.shade800, size: 36),
                const SizedBox(width: 10),
                Text(
                  'Child Help Foundation',
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Child Help Foundation is an NGO in India dedicated to child welfare and education. '
                      'We strive to provide a better future for underprivileged children through various initiatives, including education, healthcare, and vocational training.',
                  style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 16),
            buildStyledSection3(
              icon: Icons.flag,
              title: 'Our Mission',
              content:
              'To ensure that every child has access to basic education and healthcare, creating a sustainable future for the next generation.',
            ),
            const SizedBox(height: 16),
            buildStyledSection3(
              icon: Icons.volunteer_activism,
              title: 'Get Involved',
              content:
              'Join us in our mission! Volunteer, donate, or partner with us to make a difference in the lives of children in need.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.family_restroom, color: Colors.red.shade800, size: 36),
                const SizedBox(width: 10),
                Text(
                  'Miracle Foundation',
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Miracle Foundation is dedicated to transforming the lives of orphaned and abandoned children. '
                      'We focus on providing quality care, education, and opportunities for growth and development.',
                  style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 16),
            buildStyledSection3(
              icon: Icons.visibility,
              title: 'Our Vision',
              content:
              'To create a world where every child has a loving family, quality education, and the chance to thrive.',
            ),
            const SizedBox(height: 16),
            buildStyledSection3(
              icon: Icons.volunteer_activism,
              title: 'Get Involved',
              content:
              'Support us through donations, volunteering, or spreading the word about our mission.',
            ),
            const SizedBox(height: 16),


          ],
        ),
      ),
    );
  }

  Widget buildStyledSection3({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.red.shade800, size: 28),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              content,
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }






  Widget buildGameSection({required String title, required String content, required IconData icon}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.red.shade800, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIndianGamesContent() {
    return Container(
      color: Colors.red.shade50,
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sports, color: Colors.red.shade800, size: 36),
                const SizedBox(width: 10),
                Text(
                  'Which games do kids in India like to play?',
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Games and fun are the most common language of childhood. Some are known worldwide, not only in Slovakia but also in India. '
                      'Girls like to play the Ludo board game, while the boys think about their next chess move. Kabaddi, Lagorie, or Carrom, are the games not known in Slovakia – but very popular among Indian children.',
                  style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 16),
            buildGameSection(
              title: 'Kabaddi',
              content: 'Kabaddi is one of the oldest sports in the world. The entire match lasts 40 minutes, divided into two 20-minute halves. '
                  'The game field is 13 x 10 meters for men, and 12 x 8 meters for women. The game is played by two teams, each with 7 players. '
                  'The striker tries to get onto the opponent’s half. If the striker touches the opponent’s player, he scores. If the opponent’s team catches the striker, he does not score and is ejected. '
                  'The team that scores more points in both halves wins.',
              icon: Icons.sports_kabaddi,
            ),
            buildGameSection(
              title: 'Lagorie',
              content: 'Lagorie is another Indian game. It is played with seven wooden bricks or flat rocks, stacked on each other and forming a tower. '
                  'Players are divided into two teams. The striker starts the game by hitting the tower with a small ball. '
                  'After that, his team tries to build a tower again, while the opposing team’s defenders throw balls. '
                  'If the ball hits the player from the striker’s team, he is suspended and cannot continue in the game.',
              icon: Icons.toys,
            ),
            buildGameSection(
              title: 'Carrom',
              content: 'Carrom is a board game suitable for every generation. It is played on a squared smooth wooden mat that measures 70 cm. '
                  'Each player has nine rocks, some light in color, and some dark. '
                  'The main purpose of the game is to throw all the stones, including the queen rock, into the hole. '
                  'The game ends when one of the players throws all the stones. The winner gets 1 point for each opponent’s rock left on the mat and 5 points for hiding the "queen rock."',
              icon: Icons.sports_handball,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.volunteer_activism, color: Colors.red.shade800, size: 36),
                const SizedBox(width: 10),
                Text(
                  'Slovak Catholic Charity',
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Adopcia na diaľku® (Children\'s Donation Project) is implemented freely and independently of the state and other non-profit organizations.',
                  style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 16),

          ],
        ),
      ),
    );
  }











  Widget buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.roboto(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
