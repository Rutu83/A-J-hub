// lib/screens/personal_card/temple_slider_section.dart

import 'package:ajhub_app/model/temple_model.dart';
import 'package:ajhub_app/network/rest_apis.dart';
import 'package:ajhub_app/screens/temple_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class TempleSliderSection extends StatefulWidget {
  const TempleSliderSection({super.key});

  @override
  State<TempleSliderSection> createState() => _TempleSliderSectionState();
}

class _TempleSliderSectionState extends State<TempleSliderSection> {
  late Future<List<Temple>> _templesFuture;

  // NEW: Controller for the PageView to manage page properties
  final PageController _pageController = PageController(
    viewportFraction: 0.9, // Each page takes 90% of the viewport width
  );

  @override
  void initState() {
    super.initState();
    _templesFuture = fetchTemples();
  }

  @override
  void dispose() {
    _pageController.dispose(); // Don't forget to dispose of the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Temples of India',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 200,
          child: FutureBuilder<List<Temple>>(
            future: _templesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingIndicator();
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No temples found.'));
              }
              final temples = snapshot.data!;
              // MODIFIED: Replaced ListView.builder with PageView.builder
              return PageView.builder(
                controller: _pageController, // Use the controller
                itemCount: temples.length,
                itemBuilder: (context, index) {
                  // Add a little extra margin for the page effect
                  return _buildTempleCard(context, temples[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds the loading skeleton for the slider.
  Widget _buildLoadingIndicator() {
    // MODIFIED: The loader now mimics the PageView style.
    return PageView.builder(
      controller: PageController(viewportFraction: 0.9),
      itemCount: 2, // Show 2 skeleton cards
      itemBuilder: (context, index) {
        return Container(
          // Adjust margin to match the real card's margin
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  /// Builds a single card for a temple.
  Widget _buildTempleCard(BuildContext context, Temple temple) {
    return GestureDetector(
      onTap: () {
        // This navigation remains the same.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TempleDetailScreen(temple: temple),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 4),
        child: Card(
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // --- UI IMPROVEMENT IS HERE ---
              // First, check if the imageUrl is actually valid (not empty).
              if (temple.imageUrl.isNotEmpty)
                // If it is valid, show the CachedNetworkImage widget.
                CachedNetworkImage(
                  imageUrl: temple.imageUrl, // Corrected to use temple.imageUrl
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),

                  errorWidget: (context, url, error) =>
                      Image.asset('assets/images/app_logo.png'),
                )
              else
                // If the imageUrl is empty, show a placeholder icon instead.
                Container(
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.account_balance, // A fitting icon for a temple
                    color: Colors.grey,
                    size: 60,
                  ),
                ),
              // --- END OF UI IMPROVEMENT ---

              // The gradient and text overlay remain the same.
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      temple.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      temple.location,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
