import 'package:flutter/material.dart';
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
                overlayColor: MaterialStateProperty.all(Colors.transparent),
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
          padding: EdgeInsets.all(5),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2), // Shadow color
                spreadRadius: 1, // Spread radius
                blurRadius: 5, // Blur radius
                offset: Offset(0, 3), // Changes position of shadow
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
    return const Center(child: Text('Food Content')); // Placeholder
  }

  Widget buildTreePlantationContent() {
    return const Center(child: Text('Tree Plantation Content')); // Placeholder
  }

  Widget buildChildCareContent() {
    return const Center(child: Text('Child Care Content')); // Placeholder
  }

  Widget buildIndianGamesContent() {
    return const Center(child: Text('Indian Games Content')); // Placeholder
  }
}
