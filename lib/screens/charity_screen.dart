import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CharityPage extends StatefulWidget {
  const CharityPage({super.key});

  @override
  CharityPageState createState() => CharityPageState();
}

class CharityPageState extends State<CharityPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  Color titleColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    _scrollController.addListener(() {
      setState(() {
        titleColor = _scrollController.offset > 50 ? Colors.black : Colors.transparent;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.asset(
                  'assets/images/c6.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                'Charity',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                indicatorColor: Colors.transparent,
                unselectedLabelColor: Colors.black,
                dividerColor: Colors.transparent,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                tabs: [
                  buildTab('Skill\nSchool', 0),
                  buildTab('Food', 1),
                  buildTab('Tree\nPlantation', 2),
                  buildTab('Child\nCare', 3),
                  buildTab('Indian\nGames', 4),
                ],
              ),
            ),
          ];
        },
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TabBarView(
            controller: _tabController,
            children: [
              buildSkillSchoolContent(),
              buildFoodContent(),
              buildTreePlantationContent(),
              buildChildCareContent(),
              buildIndianGamesContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTab(String text, int index) {
    return Container(
      padding: EdgeInsets.zero, // Remove any default padding
      decoration: BoxDecoration(
        color: _tabController.index == index ? Colors.blue.shade300 : Colors.grey,
        border: Border.all( color: _tabController.index == index ? Colors.blue.shade300 : Colors.grey,),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Tab(
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
          )
        ),
      ),
    );
  }

  Widget buildSkillSchoolContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSection(
              title: 'Skill School Foundation ',
              content: 'We started in 2015 with 4 children and a teacher in a small room. '
                  'The SKILLSCHOOL is a dedicated and passionate team who work together '
                  'with their untiring efforts and deep understanding. The team works '
                  'selflessly with utmost care and passion. Self-help skills are taught '
                  'in a unique and playful way.',
            ),
            const SizedBox(height: 16),
            buildSection(
              title: 'Why We Are Unique ',
              content: 'We think out of the box to bring out the hidden talent of each child.',
            ),
            const SizedBox(height: 16),
            buildSection(
              title: 'Family Counselling',
              content: 'SkillSchool team provides family counseling to help parents become aware of what is happening with the child. '
                  'Family counseling can help the whole family communicate better and resolve issues.',
            ),
            const SizedBox(height: 16),
            buildSection(
              title: 'Respite and Day Care',
              content: 'SkillSchool foundation provides day care facilities for all children with special needs.',
            ),
            const SizedBox(height: 16),
            buildSection(
              title: 'Hostel Facility',
              content: 'SkillSchool foundation provides accommodation with hygienic food and a clean environment for children with special needs.',
            ),
            const SizedBox(height: 16),
            buildSection(
              title: 'We Provide:',
              content: 'Therapies and education to children, including special education, occupational therapy, sensory integration therapy, '
                  'and more.',
            ),
            const SizedBox(height: 16),
            buildSection(
              title: 'Expert to Work With:',
              content: 'Intellectual disabilities, Autism, ADHD, Learning disabilities, Mental retardation, Down syndrome, Cerebral palsy, and Slow learners.',
            ),
            const SizedBox(height: 16),
            buildSection(
              title: 'About Us',
              content: 'We believe in a holistic approach. Each child has a unique talent that must be nurtured and developed.',
            ),
            const SizedBox(height: 16),
            buildSection(
              title: 'Useful Links',
              content: 'Home\nAbout\nServices\nContact\nContact Us\nPlot no 15 3rd floor SBI Building, Ranaji Enclave, Nangli Sakrawati, New Delhi 110043\n'
                  '+91 999 933 1797 - 999 933 4294 - 888 200 6800\ninfo@skillskoolfoundation.com',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }



  Widget buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title aligned to the right
        Container(
          padding: const EdgeInsets.all(5),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2), // Shadow color
                spreadRadius: 1, // Spread radius
                blurRadius: 5, // Blur radius
                offset: const Offset(0, 3), // Changes position of shadow
              ),
            ],
          ),
          child: Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade500,
            ),
          ),
        ),
        // Content aligned to the left
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(top: 8.0), // Padding above the content
          child: Text(
            content,
            style: GoogleFonts.albertSans(
              fontSize: 16, // Adjust size as needed
              color: Colors.black, // Set the content text color
            ),
            textAlign: TextAlign.left, // Optional: ensures text is left aligned
          ),
        ),
      ],
    );
  }




  Widget buildFoodContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The Akshaya Patra Foundation',
              style: GoogleFonts.roboto(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'The Akshaya Patra Foundation is a not-for-profit organisation headquartered in Bengaluru, India. '
                  'The Foundation strives to eliminate classroom hunger by implementing the PM POSHAN (Mid-Day Meal) Programme. '
                  'It provides nutritious meals to children studying in government schools and government-aided schools. '
                  'Akshaya Patra also aims to counter malnutrition and support the Right to Education of children hailing from socio-economically challenging backgrounds.',
              style: GoogleFonts.roboto(fontSize: 16.sp),
            ),
            const SizedBox(height: 10),
            buildSection(
              title: 'Our Vision',
              content: 'No child in India shall be deprived of education because of hunger.',
            ),
            const SizedBox(height: 10),
            buildSection(
              title: 'Our Mission',
              content: 'To feed 3 million children every day by 2025.',
            ),
            const SizedBox(height: 10),
            buildStatisticsSection(),
            const SizedBox(height: 10),
            buildContactSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Impact Statistics',
          style: GoogleFonts.roboto(fontSize: 20.sp, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        Text(
          '• Over 4 billion meals served\n'
              '• Over 2.25 million+ children benefitted\n'
              '• Reached to over 23,000 schools\n'
              '• 16 States and 2 Union Territories\n'
              '• 75 Locations',
          style: GoogleFonts.roboto(fontSize: 16.sp),
        ),
      ],
    );
  }
  Widget buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Us',
          style: GoogleFonts.roboto(fontSize: 20.sp, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        Text('Email: donorcare@akshayapatra.org', style: GoogleFonts.roboto(fontSize: 16.sp)),
        Text('Phone: 1800-425-8622', style: GoogleFonts.roboto(fontSize: 16.sp)),
      ],
    );
  }

  Widget buildTreePlantationContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SayTrees',
              style: GoogleFonts.roboto(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'About Us: Our Journey\n'
                  'Bangalore, fondly called “The city of Gardens” inspired fables and verses alike. With an unbelievably pleasant weather throughout the year, it was a green haven for decades. '
                  'Corporatisation of the city and rapid influx of the IT industry brought jobs and investments galore, but took a toll on the natural beauty the city was blessed with. '
                  'That\'s when a motley group of individuals - software engineers at work and passionate tree lovers at heart came together, and ‘SayTrees’ was born.',
              style: GoogleFonts.roboto(fontSize: 16.sp),
            ),
            const SizedBox(height: 10),
            Text(
              'Our Mission: To make citizens aware about the need of trees for our survival and protect natural resources for generations to come.',
              style: GoogleFonts.roboto(fontSize: 16.sp),
            ),
            const SizedBox(height: 10),
            Text(
              'Quick Links:\n'
                  '• Home\n'
                  '• About\n'
                  '• Impact\n'
                  '• Mission & Vision\n'
                  '• Get Involved\n'
                  '• Projects\n'
                  '• Donate\n'
                  '• Contact\n',
              style: GoogleFonts.roboto(fontSize: 16.sp),
            ),
            const SizedBox(height: 10),
            buildTeamSection(),
            const SizedBox(height: 10),
            buildContactUsSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }


  Widget buildTeamSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meet Our Team',
          style: GoogleFonts.roboto(fontSize: 20.sp, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        buildTeamMember('Kapil Sharma', 'Founder & Director.'),
        buildTeamMember('Deokant Payasi', 'Trustee.'),
        buildTeamMember('Durgesh Agrahari', 'Head of Partnerships & Projects.'),
        buildTeamMember('Nitin Nath', 'Program Manager, Delhi/NCR.'),
        buildTeamMember('Shashank Sharma', 'Program Manager, Bengaluru.'),
        buildTeamMember('Madhusudhan Iyenger', 'Program Manager, Bengaluru.'),
        buildTeamMember('Shivam', 'Project Manager, DLHI/NCR.'),
        buildTeamMember('Arpana Shetty', 'Program Manager, outreach and marketing.'),
        buildTeamMember('Mudassir Pasha', 'Operations coordinator, SOUTH India.'),
      ],
    );
  }

  Widget buildTeamMember(String name, String role) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        '$name - $role',
        style: GoogleFonts.roboto(fontSize: 16.sp),
      ),
    );
  }

  Widget buildContactUsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Us',
          style: GoogleFonts.roboto(fontSize: 20.sp, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        Text('Address: No. 6, 1st cross, first floor, Basapura, Near Hosa Road Junction, Bengaluru, Karnataka 560100', style: GoogleFonts.roboto(fontSize: 16.sp)),
        Text('Phone: +91 - 96635 77758', style: GoogleFonts.roboto(fontSize: 16.sp)),
        Text('Email: info@saytrees.org', style: GoogleFonts.roboto(fontSize: 16.sp)),
      ],
    );
  }



  Widget buildChildCareContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Child Help Foundation',
              style: GoogleFonts.roboto(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Child Help Foundation is an NGO in India dedicated to child welfare and education. '
                  'We strive to provide a better future for underprivileged children through various initiatives, including education, healthcare, and vocational training.',
              style: GoogleFonts.roboto(fontSize: 16.sp),
            ),
            const SizedBox(height: 10),
            buildSection(
              title: 'Our Mission',
              content: 'To ensure that every child has access to basic education and healthcare, creating a sustainable future for the next generation.',
            ),
            const SizedBox(height: 10),
            buildSection(
              title: 'Get Involved',
              content: 'Join us in our mission! Volunteer, donate, or partner with us to make a difference in the lives of children in need.',
            ),
            const SizedBox(height: 10),
            buildSection(
              title: 'Contact Us',
              content: 'Email: info@childhelpfoundation.org\nPhone: +91 98765 43210',
             ),
            const SizedBox(height: 10),
            Text(
              'Miracle Foundation',
              style: GoogleFonts.roboto(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Miracle Foundation is dedicated to transforming the lives of orphaned and abandoned children. '
                  'We focus on providing quality care, education, and opportunities for growth and development.',
              style: GoogleFonts.roboto(fontSize: 16.sp),
            ),
            const SizedBox(height: 10),
            buildSection(
              title: 'Our Vision',
              content: 'To create a world where every child has a loving family, quality education, and the chance to thrive.',
            ),
            const SizedBox(height: 10),
            buildSection(
              title: 'Get Involved',
              content: 'Support us through donations, volunteering, or spreading the word about our mission.',
            ),
            const SizedBox(height: 10),
            buildSection(
              title: 'Contact Us',
              content: 'Email: info@miraclefoundation.org\nPhone: +91 12345 67890',
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }


  Widget buildGameSection({required String title, required String content}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.roboto(fontSize: 20.sp, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            Text(
              content,
              style: GoogleFonts.roboto(fontSize: 16.sp),
            ),
          ],
        ),
      ),
    );
  }


  Widget buildIndianGamesContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Which games do kids in India like to play?',
              style: GoogleFonts.roboto(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Games and fun are the most common language of childhood. Some are known worldwide, not only in Slovakia but also in India. '
                  'Girls like to play the Ludo board game, while the boys think about their next chess move. Kabaddi, Lagorie, or Carrom, are the games not known in Slovakia – but very popular among Indian children.',
              style: GoogleFonts.roboto(fontSize: 16.sp),
            ),
            const SizedBox(height: 10),
            buildGameSection(
              title: 'Kabaddi',
              content: 'Kabaddi is one of the oldest sports in the world. The entire match lasts 40 minutes, divided into two 20-minute halves. '
                  'The game field is 13 x 10 meters for men, and 12 x 8 meters for women and is divided into 2 equal halves. '
                  'The game is played by two teams, each with 7 players. The striker tries to get onto the opponent’s half. '
                  'If the striker touches the opponent’s player, he scores. If the opponent’s team catches the striker, he does not score and is ejected. '
                  'The team that scores more points in both halves wins.',
            ),
            const SizedBox(height: 10),
            buildGameSection(
              title: 'Lagorie',
              content: 'Lagorie is another Indian game. It is played with seven wooden bricks or flat rocks, stacked on each other and forming a tower. '
                  'Players are divided into 2 teams. The striker starts the game by hitting the tower with a small ball. '
                  'After that, his team tries to build a tower again, while the opposing team’s defenders throw balls. '
                  'If the ball hits the player from the striker’s team, he is suspended and cannot continue in the game.',
            ),
            const SizedBox(height: 10),
            buildGameSection(
              title: 'Carrom',
              content: 'Carrom is a board game suitable for every generation. It is played on a squared smooth wooden mat that measures 70 cm. '
                  'In the corner, there is a hole, under which there can be a net. Each player has nine rocks, some of them are light in color, and some are dark. '
                  'The main purpose of the game is to throw all the stones, including the queen rock, into the hole. '
                  'The game ends when one of the players throws all the stones. The winner gets 1 point for each opponent’s rock left on the wooden mat and 5 points for hiding the "queen rock." '
                  'Both girls and boys enjoy this game.',
            ),
            const SizedBox(height: 20),
            Text(
              'Slovak Catholic Charity',
              style: GoogleFonts.roboto(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Adopcia na diaľku® (Children\'s Donation Project) is implemented freely and independently of the state and other non-profit organizations.',
              style: GoogleFonts.roboto(fontSize: 16.sp),
            ),
            const SizedBox(height: 10),
            buildContactSection2(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget buildContactSection2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact',
          style: GoogleFonts.roboto(fontSize: 20.sp, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        Text('Kapitulská 18', style: GoogleFonts.roboto(fontSize: 16.sp)),
        Text('814 15 Bratislava', style: GoogleFonts.roboto(fontSize: 16.sp)),
        Text('SLOVAKIA', style: GoogleFonts.roboto(fontSize: 16.sp)),
        Text('Phone: 02/5443 44 97', style: GoogleFonts.roboto(fontSize: 16.sp)),
        Text('Email: adopcianadialku@charita.sk', style: GoogleFonts.roboto(fontSize: 16.sp)),
      ],
    );
  }

}
