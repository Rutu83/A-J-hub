import 'package:allinone_app/screens/category_selected.dart';
import 'package:flutter/material.dart';

class CategoryTopics extends StatelessWidget {
  final String title;
  final List<Map<String, String>> topics; // List of topics with titles and image paths

  const CategoryTopics({super.key, required this.title, required this.topics});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Colors.transparent,
        elevation: 4.0,
        shadowColor: Colors.grey.withOpacity(0.5),
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Number of columns
            crossAxisSpacing: 10.0, // Spacing between columns
            mainAxisSpacing: 10.0, // Spacing between rows
            childAspectRatio: 2 / 2, // Aspect ratio of the items
          ),
          itemCount: topics.length, // Use the number of topics
          itemBuilder: (context, index) {
            final topic = topics[index];
            final imageUrl = topic['image']!;
            final topicTitle = topic['title']!; // Get the title of each topic

            return InkWell(
              onTap: () {
                // Define the list of images to show based on the title
                List<String> images;


                print(topicTitle);

                if (topicTitle == 'Navratri') {
                  images = [
                    'assets/images/navratri/navratri.jpg',
                    'assets/images/navratri/navratri2.jpg',
                    'assets/images/navratri/navratri3.jpg',
                    'assets/images/navratri/navratri4.jpg',
                    'assets/images/navratri/navratri5.jpg',
                    'assets/images/navratri/navratri6.jpg',
                    'assets/images/navratri/navratri7.jpg',
                    'assets/images/navratri/navratri8.jpg',
                    'assets/images/navratri/navratri9.jpg',
                    'assets/images/navratri/navratri10.jpg',
                    'assets/images/navratri/navratri11.jpg',
                    'assets/images/navratri/navratri12.jpg',
                    'assets/images/navratri/navratri13.jpg',
                    'assets/images/navratri/navratri14.jpg',
                  ];
                } else if (topicTitle == 'Gandhi Jayanti') {
                  images = [
                    'assets/images/gandhiji/gandhiji.jpg',
                    'assets/images/gandhiji/gandhiji2.jpg',
                    'assets/images/gandhiji/gandhiji3.jpg',
                    'assets/images/gandhiji/gandhiji4.jpg',
                    'assets/images/gandhiji/gandhiji5.jpg',
                    'assets/images/gandhiji/gandhiji6.jpg',
                    'assets/images/gandhiji/gandhiji7.jpg',
                    'assets/images/gandhiji/gandhiji8.jpg',
                    'assets/images/gandhiji/gandhiji9.jpg',
                    'assets/images/gandhiji/gandhiji10.jpg',
                    'assets/images/gandhiji/gandhiji11.jpg',
                    'assets/images/gandhiji/gandhiji12.jpg',
                    'assets/images/gandhiji/gandhiji13.jpg',
                    'assets/images/gandhiji/gandhiji14.jpg',
                    'assets/images/gandhiji/gandhiji15.jpg',
                    'assets/images/gandhiji/gandhiji16.jpg',
                    'assets/images/gandhiji/gandhiji17.jpg',
                    'assets/images/gandhiji/gandhiji18.jpg',
                    'assets/images/gandhiji/gandhiji19.jpg',
                    'assets/images/gandhiji/gandhiji20.jpg',
                    'assets/images/gandhiji/gandhiji21.jpg',
                  ];
                } else if (topicTitle == 'Birthday') {
                  images = [
                    'assets/images/birthday/birthday.jpg',
                    'assets/images/birthday/birthday2.jpg',
                    'assets/images/birthday/birthday3.jpg',
                    'assets/images/birthday/birthday4.jpg',
                    'assets/images/birthday/birthday5.jpg',
                    'assets/images/birthday/birthday6.jpg',
                    'assets/images/birthday/birthday7.jpg',
                    'assets/images/birthday/birthday8.jpg',
                    'assets/images/birthday/birthday9.jpg',
                    'assets/images/birthday/birthday10.jpg',
                    'assets/images/birthday/birthday11.jpg',
                    'assets/images/birthday/birthday12.jpg',
                  ];
                } else if (topicTitle == 'Hanuman Dada') {
                  images = [
                    'assets/images/hanuman/hanuman.jpg',
                    'assets/images/hanuman/hanuman1.jpg',
                    'assets/images/hanuman/hanuman2.jpg',
                    'assets/images/hanuman/hanuman3.jpg',
                    'assets/images/hanuman/hanuman4.jpg',
                    'assets/images/hanuman/hanuman5.jpg',
                    'assets/images/hanuman/hanuman6.jpg',
                    'assets/images/hanuman/hanuman7.jpg',
                    'assets/images/hanuman/hanuman8.jpg',
                    'assets/images/hanuman/hanuman9.jpg',
                    'assets/images/hanuman/hanuman10.jpg',
                    'assets/images/hanuman/hanuman11.jpg',
                    'assets/images/hanuman/hanuman12.jpg',
                    'assets/images/hanuman/hanuman13.jpg',
                    'assets/images/hanuman/hanuman14.jpg',
                  ];
                }  else if (topicTitle == 'Quotes by Scientists') {
                  images = [
                    'assets/images/quotes/Quotes.jpg',
                    'assets/images/quotes/Quotes2.jpg',
                    'assets/images/quotes/Quotes3.jpg',
                    'assets/images/quotes/Quotes4.jpg',
                    'assets/images/quotes/Quotes5.jpg',
                    'assets/images/quotes/Quotes6.jpg',
                    'assets/images/quotes/Quotes7.jpg',
                    'assets/images/quotes/Quotes9.jpg',
                    'assets/images/quotes/Quotes10.jpg',
                    'assets/images/quotes/Quotes11.jpg',
                    'assets/images/quotes/Quotes12.jpg',
                    'assets/images/quotes/Quotes13.jpg',
                  ];
                }else if (title == 'Farm store') {
                  images = [
                    'assets/images/framstore/framstore.jpg',
                    'assets/images/framstore/framstore2.jpg',
                    'assets/images/framstore/framstore3.jpg',
                    'assets/images/framstore/framstore4.jpg',
                    'assets/images/framstore/framstore5.jpg',
                    'assets/images/framstore/framstore6.jpg',
                    'assets/images/framstore/framstore7.jpg',
                    'assets/images/framstore/framstore8.jpg',
                    'assets/images/framstore/framstore9.jpg',
                    'assets/images/framstore/framstore10.jpg',
                    'assets/images/framstore/framstore11.jpg' ,
                    'assets/images/framstore/framstore12.jpg' ,
                    'assets/images/framstore/framstore13.jpg' ,
                    'assets/images/framstore/framstore14.jpg',
                  ];
                } else if (title == 'Mahadev') {
                  images = [
                    'assets/images/shiv/shiv.jpg',
                    'assets/images/shiv/shiv2.jpg',
                    'assets/images/shiv/shiv3.jpg',
                    'assets/images/shiv/shiv4.jpg',
                    'assets/images/shiv/shiv5.jpg',
                    'assets/images/shiv/shiv6.jpg',
                    'assets/images/shiv/shiv7.jpg',
                    'assets/images/shiv/shiv8.jpg',
                    'assets/images/shiv/shiv9.jpg',
                    'assets/images/shiv/shiv10.jpg',
                    'assets/images/shiv/shiv11.jpg',
                    'assets/images/shiv/shiv12.jpg',
                    'assets/images/shiv/shiv13.jpg',
                    'assets/images/shiv/shiv14.jpg' ,
                  ];
                } else if (title == 'Marketing') {
                  images = [
                    'assets/images/Marketing/Marketing.jpg',
                    'assets/images/Marketing/Marketing2.jpg',
                    'assets/images/Marketing/Marketing3.jpg',
                    'assets/images/Marketing/Marketing4.jpg',
                    'assets/images/Marketing/Marketing5.jpg',
                    'assets/images/Marketing/Marketing6.jpg',
                    'assets/images/Marketing/Marketing7.jpg',
                    'assets/images/Marketing/Marketing8.jpg',

                  ];
                }else {
                  images = []; // Default empty list if no matching title
                }

                // Navigate to the CategorySelected screen only if the images list is not empty
                if (images.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategorySelected(imagePaths: images),
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200, width: 1.0), // Add border color and width
                  borderRadius: BorderRadius.circular(22.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0), // Match the border radius of the container
                  child: Image.asset(
                    imageUrl,
                    fit: BoxFit.fill,
                    width: double.infinity,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
