import 'dart:convert';

import 'package:ajhub_app/utils/configs.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

// Data model for each category in the grid
class CharityCategory {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTapAction;

  CharityCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    this.onTapAction,
  });
}

class CharityScreen extends StatefulWidget {
  const CharityScreen({super.key});

  @override
  CharityScreenState createState() => CharityScreenState();
}

class CharityScreenState extends State<CharityScreen> {
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
    // --- Mapped categories to their content builder functions ---
    final List<CharityCategory> charityCategories = [
      CharityCategory(
        id: '1',
        title: 'NO\nPOVERTY',
        icon: Icons.family_restroom,
        color: const Color(0xFFE5243B),
        onTapAction: () =>
            showCustomBottomSheet(context, buildNoPovertyContent()),
      ),
      CharityCategory(
        id: '2',
        title: 'ZERO\nHUNGER',
        icon: Icons.ramen_dining_outlined,
        color: const Color(0xFFDDA63A),
        onTapAction: () =>
            showCustomBottomSheet(context, buildZeroHungerContent()),
      ),
      CharityCategory(
        id: '3',
        title: 'GOOD HEALTH\nAND WELL-BEING',
        icon: Icons.monitor_heart_outlined,
        color: const Color(0xFF4C9F38),
        onTapAction: () =>
            showCustomBottomSheet(context, buildGoodHealthContent()),
      ),
      CharityCategory(
        id: '4',
        title: 'QUALITY\nEDUCATION',
        icon: Icons.school_outlined,
        color: const Color(0xFFC5192D),
        onTapAction: () =>
            showCustomBottomSheet(context, buildQualityEducationContent()),
      ),
      CharityCategory(
        id: '5',
        title: 'TREE\nPLANTATION',
        icon: Icons.energy_savings_leaf_outlined,
        color: const Color(0xFF3F7E44), // Adjusted color for better theme
        onTapAction: () =>
            showCustomBottomSheet(context, buildTreePlantationContent()),
      ),
      CharityCategory(
        id: '6',
        title: 'CLEAN WATER\nAND SANITATION',
        icon: Icons.water_drop_outlined,
        color: const Color(0xFF26BDE2),
        onTapAction: () =>
            showCustomBottomSheet(context, buildCleanWaterContent()),
      ),
    ];

    const String mainDescription =
        "Your Subscription, Their Future: Making a\n Difference Together."
        "Every time you subscribe to AJ Hub, you're not just gaining access to incredible content – you're directly contributing to a brighter future for those in need. We believe in the power of collective giving, and that's why a portion of every subscription goes directly to our dedicated charity fund.\n\n"
        "This fund supports vital initiatives, e.g., providing education for underprivileged children, delivering essential relief to communities in crisis, or supporting environmental conservation. Your choice to subscribe creates a ripple effect of positive change, transforming lives and empowering communities.\n\n"
        "Thank you for being a part of something bigger. Together, we can make a significant difference. Be proud to be part of a platform that champions generosity. Subscribe today and help us amplify our impact!";

    const String highlightedFooter =
        "Subscribe. Support. Shine. Your Impact Starts Here.\n"
        "5% of every subscription goes to donation";

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
              size: 26,
            ),
            const SizedBox(width: 10),
            Text(
              'Charity',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        elevation: 4,
        shadowColor: Colors.red.shade200,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Background image tapped')),
                  );
                },
                child: Image.asset(
                  'assets/images/charity.jpeg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Join Hands to Heal the World.",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ExpandableText(
                    text: mainDescription,
                    trimLines: 8,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    highlightedFooter,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: charityCategories.length,
                itemBuilder: (context, index) {
                  return _buildGridItem(charityCategories[index]);
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS FOR BUILDING UI ELEMENTS ---

  Widget _buildGridItem(CharityCategory category) {
    return GestureDetector(
      onTap: category.onTapAction,
      child: Card(
        color: category.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        shadowColor: category.color.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.id,
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 33,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        category.title,
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Center(
                child: Icon(
                  category.icon,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showCustomBottomSheet(BuildContext context, Widget content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: content,
          ),
        ),
      ),
    );
  }

  // --- CONTENT BUILDER METHODS ---

  Widget buildNoPovertyContent() {
    return _buildInfoSheet(
      title: 'No Poverty',
      icon: Icons.family_restroom,
      children: [
        _buildParagraph(
            'Poverty is more than just a lack of money; it\'s a denial of opportunity, dignity, and a basic human right. Across our communities, too many individuals and families are trapped in a cycle of deprivation, facing daily struggles for food, shelter, education, and healthcare.'),
        _buildSectionTitle(
            'Our Mission: Empowering Lives, Building Resilience'),
        _buildParagraph(
            'At AJ Hub, we believe that poverty is not inevitable. We are committed to fostering sustainable change, empowering individuals and families to lift themselves out of poverty and build brighter futures.'),
        _buildSectionTitle('How We Make a Difference:'),
        _buildBulletPoint(
            'Sustainable Livelihoods & Skill Development: We provide training and resources for income-generating activities, helping individuals secure stable jobs or start their own small businesses.'),
        _buildBulletPoint(
            'Education & Scholarship Programs: We ensure children and youth have access to quality education, breaking the intergenerational cycle of poverty.'),
        _buildBulletPoint(
            'Food Security & Nutrition Initiatives: We implement programs that provide nutritious meals and promote sustainable farming.'),
        _buildBulletPoint(
            'Access to Basic Necessities: We work to improve access to clean water, sanitation facilities, and safe housing.'),
        _buildSectionTitle('Your Contribution: A Catalyst for Change'),
        _buildParagraph(
            'Every donation, no matter the size, directly fuels our efforts and creates a ripple effect of positive change. Donate today and help us create a future free from poverty.'),
      ],
    );
  }

  Widget buildZeroHungerContent() {
    return _buildInfoSheet(
      title: 'Zero Hunger',
      icon: Icons.ramen_dining_outlined,
      children: [
        _buildParagraph(
            "In a world of abundance, millions still go to bed hungry. Hunger is not just an empty stomach; it's a thief of potential, a barrier to education, and a silent killer of dreams."),
        _buildSectionTitle('The Urgent Challenge:'),
        _buildBulletPoint(
            'Chronic Malnutrition: Lack of the right nutrients leads to stunted growth and weakened immune systems, especially in children.'),
        _buildBulletPoint(
            'Food Insecurity: Unpredictable access to enough food, often due to poverty, conflict, or climate change.'),
        _buildBulletPoint(
            'Smallholder Farmer Vulnerability: Farmers struggle with unpredictable weather and lack of resources, jeopardizing their own food supply.'),
        _buildSectionTitle('Our Commitment: Feeding the Future'),
        _buildParagraph(
            'At AJ Hub, we are dedicated to achieving a world free from hunger. Our mission is to ensure that everyone has consistent access to safe, nutritious, and sufficient food.'),
        _buildSectionTitle('How We Make a Tangible Difference:'),
        _buildBulletPoint(
            'Emergency Food Relief: Providing immediate, nutritious food to families in crisis.'),
        _buildBulletPoint(
            'Sustainable Agriculture Programs: Empowering smallholder farmers with training, resources, and modern farming techniques.'),
        _buildBulletPoint(
            'School Feeding Programs: Ensuring children receive at least one nutritious meal a day at school, which improves attendance and concentration.'),
        _buildSectionTitle('Join Us: Let\'s Cultivate a Hunger-Free World'),
        _buildParagraph(
            'Donate today and help us nourish lives and cultivate hope.'),
      ],
    );
  }

  Widget buildGoodHealthContent() {
    return _buildInfoSheet(
      title: 'Good Health and Well-being',
      icon: Icons.monitor_heart_outlined,
      children: [
        _buildParagraph(
            'Health is not merely the absence of disease; it is a state of complete physical, mental, and social well-being. It is the cornerstone of a fulfilling life, enabling individuals to learn, work, and contribute meaningfully to their families and communities.'),
        _buildSectionTitle('The Challenges to Well-being:'),
        _buildBulletPoint(
            'Limited Access to Quality Healthcare: Many rural and underprivileged areas lack sufficient doctors, nurses, clinics, and essential medicines.'),
        _buildBulletPoint(
            'Preventable Diseases: Common illnesses like infectious diseases and non-communicable diseases (e.g., diabetes, hypertension) can be managed with proper care.'),
        _buildBulletPoint(
            'Mental Health Stigma & Support: Mental health issues often go undiagnosed and untreated.'),
        _buildSectionTitle(
            'Our Commitment: Health for All, Well-being for Life'),
        _buildParagraph(
            'At AJ Hub, we are dedicated to improving public health outcomes and promoting holistic well-being within our communities.'),
        _buildSectionTitle('How We Bring About Change:'),
        _buildBulletPoint(
            'Mobile Health Clinics & Medical Camps: Deploying teams of doctors to remote areas, providing free consultations and medicines.'),
        _buildBulletPoint(
            'Maternal and Child Health Programs: Offering prenatal and postnatal care, immunizations, and nutritional guidance.'),
        _buildBulletPoint(
            'Health & Hygiene Education: Conducting awareness workshops on sanitation, handwashing, and disease prevention.'),
        _buildSectionTitle('Join Us: Invest in Health, Invest in Humanity'),
        _buildParagraph(
            'Donate today and help us build a healthier, happier world for all.'),
      ],
    );
  }

  Widget buildQualityEducationContent() {
    return _buildInfoSheet(
      title: 'Quality Education',
      icon: Icons.school_outlined,
      children: [
        _buildParagraph(
            'Education is the key that unlocks potential, breaks cycles of poverty, and empowers individuals to shape their own destinies. Yet, for countless children, the dream of a quality education remains just a dream.'),
        _buildSectionTitle('The Hurdles to Learning:'),
        _buildBulletPoint(
            'Lack of Access: Many children face geographical, financial, or social barriers to attending school.'),
        _buildBulletPoint(
            'Inadequate Infrastructure: Dilapidated classrooms, lack of proper sanitation, and absence of safe learning environments.'),
        _buildBulletPoint(
            'Resource Scarcity: Lack of basic learning materials, textbooks, and digital tools.'),
        _buildSectionTitle('Our Mission: Empowering Minds, Transforming Lives'),
        _buildParagraph(
            'At AJ Hub, we are committed to bridging the educational gap by creating supportive learning environments and providing essential resources.'),
        _buildSectionTitle('How We Make a Difference:'),
        _buildBulletPoint(
            'School Infrastructure Development: Constructing and renovating classrooms and sanitation facilities.'),
        _buildBulletPoint(
            'Learning Resources & Libraries: Providing textbooks, stationery kits, and setting up libraries.'),
        _buildBulletPoint(
            'Digital Learning & Computer Labs: Establishing computer labs to equip students with 21st-century skills.'),
        _buildBulletPoint(
            'Scholarships & Sponsorships: Offering financial aid to deserving students from disadvantaged backgrounds.'),
        _buildSectionTitle('Join Us: Let\'s Invest in Education, Together'),
        _buildParagraph(
            'Donate today and help us light the path to a brighter, more educated future for every child.'),
      ],
    );
  }

  Widget buildTreePlantationContent() {
    return _buildInfoSheet(
      title: 'Tree Plantation',
      icon: Icons.energy_savings_leaf_outlined,
      children: [
        _buildParagraph(
            'Trees are the lungs of our Earth. They breathe life into our communities, purify the air, regulate our climate, and provide sanctuary for countless species. Yet, deforestation, urbanization, and climate change threaten these essential lifelines.'),
        _buildSectionTitle('The Silent Crisis: Why We Need More Trees'),
        _buildBulletPoint(
            'Climate Change: Trees absorb carbon dioxide. Their loss accelerates global warming.'),
        _buildBulletPoint(
            'Air Pollution: Less trees mean more airborne pollutants, contributing to respiratory illnesses.'),
        _buildBulletPoint(
            'Biodiversity Loss: Destruction of forests leads to the extinction of plants and animals.'),
        _buildSectionTitle(
            'Our Commitment: Re-Greening Our World, One Tree at a Time'),
        _buildParagraph(
            'At AJ Hub, we are committed to large-scale tree plantation drives and reforestation efforts to combat environmental degradation and build a sustainable future.'),
        _buildSectionTitle('How We Make a Green Impact:'),
        _buildBulletPoint(
            'Mass Tree Plantation Drives: Organizing large-scale planting events in degraded forest lands, public spaces, and schools.'),
        _buildBulletPoint(
            'Community Nurseries & Education: Establishing local nurseries and conducting workshops to educate communities on the importance of trees.'),
        _buildBulletPoint(
            'Post-Plantation Care: Ensuring the survival and healthy growth of planted trees through regular watering and protection.'),
        _buildSectionTitle(
            'Join Us: Let\'s Grow a Sustainable Future, Together'),
        _buildParagraph(
            'Donate today and help us plant a greener, healthier future for all.'),
      ],
    );
  }

  Widget buildCleanWaterContent() {
    return _buildInfoSheet(
      title: 'Clean Water and Sanitation',
      icon: Icons.water_drop_outlined,
      children: [
        _buildParagraph(
            'Water is life. Yet, for millions, access to safe, clean drinking water remains a daily struggle, and proper sanitation facilities are a luxury. This leads to preventable diseases, perpetuates poverty, and robs individuals of their dignity.'),
        _buildSectionTitle(
            'The Invisible Crisis: Why Water & Sanitation Matter'),
        _buildBulletPoint(
            'Disease & Sickness: Contaminated water and poor hygiene are primary causes of diseases like diarrhea, cholera, and typhoid.'),
        _buildBulletPoint(
            'Time & Opportunity Lost: Women and girls often bear the burden of walking miles to fetch water, taking away hours from education or income generation.'),
        _buildBulletPoint(
            'Dignity & Safety: Lack of private and safe sanitation facilities exposes individuals, especially women, to harassment and humiliation.'),
        _buildSectionTitle(
            'Our Commitment: Unlocking Health and Dignity for All'),
        _buildParagraph(
            'At AJ Hub, we are dedicated to transforming communities by implementing sustainable water and sanitation solutions that improve health and restore dignity.'),
        _buildSectionTitle('How We Bring About Sustainable Change:'),
        _buildBulletPoint(
            'Safe Water Access: Digging and rehabilitating borewells, installing hand pumps, and implementing water purification systems.'),
        _buildBulletPoint(
            'Hygiene & Sanitation Education: Conducting awareness campaigns on critical hygiene practices like handwashing.'),
        _buildBulletPoint(
            'Constructing Dignified Latrines: Building accessible, private, and safe household and community latrines.'),
        _buildSectionTitle('Join Us: Be a Part of the Water Revolution'),
        _buildParagraph(
            'Donate today and help us bring clean water and sanitation to every doorstep.'),
      ],
    );
  }

  // --- GENERIC WIDGETS FOR BUILDING THE BOTTOM SHEETS ---

  Widget _buildInfoSheet({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      color: const Color(0xFFFFF8F8),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.red.shade800, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.roboto(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 30, thickness: 1),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.roboto(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: GoogleFonts.roboto(
        fontSize: 16,
        color: Colors.black54,
        height: 1.5,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            ' \u2022 ',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET FOR EXPANDABLE TEXT ---
class ExpandableText extends StatefulWidget {
  const ExpandableText({
    Key? key,
    required this.text,
    this.trimLines = 3,
  }) : super(key: key);

  final String text;
  final int trimLines;

  @override
  ExpandableTextState createState() => ExpandableTextState();
}

class ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = const TextStyle(
      fontSize: 16,
      color: Colors.black87,
      height: 1.4,
    );
    final linkTextStyle = defaultTextStyle.copyWith(
      color: Colors.red.shade700,
      fontWeight: FontWeight.bold,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final textSpan = TextSpan(text: widget.text, style: defaultTextStyle);
        final textPainter = TextPainter(
          text: textSpan,
          maxLines: widget.trimLines,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: constraints.maxWidth);

        if (textPainter.didExceedMaxLines) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                _isExpanded
                    ? TextSpan(
                        text: widget.text,
                        style: defaultTextStyle,
                      )
                    : textSpan,
                maxLines: _isExpanded ? null : widget.trimLines,
                overflow: _isExpanded ? null : TextOverflow.ellipsis,
              ),
              GestureDetector(
                onTap: _toggleExpanded,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    _isExpanded ? 'Read Less' : 'Read More',
                    style: linkTextStyle,
                  ),
                ),
              ),
            ],
          );
        } else {
          return Text(widget.text, style: defaultTextStyle);
        }
      },
    );
  }
}
