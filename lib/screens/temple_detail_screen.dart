import 'dart:ui' as ui;

import 'package:ajhub_app/model/temple_model.dart';
import 'package:ajhub_app/utils/common.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TempleDetailScreen extends StatelessWidget {
  final Temple temple;

  const TempleDetailScreen({super.key, required this.temple});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            iconTheme: const IconThemeData(color: Colors.white), // back arrow white
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                parseHtmlString(temple.name),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Blurred background to fill any gaps (prevents awkward letterboxing)
                  CachedNetworkImage(
                    imageUrl: temple.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorWidget: (context, url, error) => const SizedBox(),
                  ),
                  BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(color: Colors.black.withOpacity(0.3)),
                  ),
                  
                  // 2. Uncropped main image (so text doesn't go out of boundary)
                  CachedNetworkImage(
                    imageUrl: temple.imageUrl,
                    fit: BoxFit.contain, // Shows full image without clipping edges
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => Container(
                      color: Colors.transparent,
                      child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                    ),
                    errorWidget: (context, url, error) =>
                        Image.asset('assets/images/app_logo.png'),
                  ),
                  
                  // 3. Dark gradient at bottom for readable text
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parseHtmlString(temple.name),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          parseHtmlString(temple.location),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  const Text(
                    'About',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Html(
                    data: _cleanHtml(temple.description),
                    style: {
                      "body": Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        fontSize: FontSize(15.sp),
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        color: Colors.grey.shade800,
                        textAlign: TextAlign.start,
                        lineHeight: LineHeight(1.6),
                      ),
                      "p": Style(
                        fontSize: FontSize(15.sp),
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w400,
                        textAlign: TextAlign.start,
                        margin: Margins.only(bottom: 12),
                      ),
                      "h1": Style(
                        fontSize: FontSize(22.sp),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        margin: Margins.only(top: 16, bottom: 8),
                      ),
                      "h2": Style(
                        fontSize: FontSize(20.sp),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        margin: Margins.only(top: 14, bottom: 8),
                      ),
                      "h3": Style(
                        fontSize: FontSize(18.sp),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        margin: Margins.only(top: 12, bottom: 8),
                      ),
                      "ul": Style(
                        margin: Margins.only(bottom: 16),
                        padding: HtmlPaddings.only(left: 20),
                        listStylePosition: ListStylePosition.outside,
                      ),
                      "li": Style(
                        fontSize: FontSize(15.sp),
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        color: Colors.grey.shade800,
                        margin: Margins.only(bottom: 8),
                      ),
                      "strong": Style(
                        fontSize: FontSize(15.sp),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      "br": Style(
                        whiteSpace: WhiteSpace.normal,
                      ),
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _cleanHtml(String? html) {
    if (html == null || html.isEmpty) return "";

    String content = html;

    // 1. Unconditionally decode HTML entities for brackets so flutter_html 
    // parses them as actual HTML tags rather than displaying raw <p> strings.
    content = content
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&amp;', '&');

    // 2. Clean up common messy patterns from backend
    content = content
        .replaceAll(RegExp(r'(<br\s*/?>\s*)+'), '<br>')
        .replaceAll('&nbsp;', ' ')
        // Remove stray '= ' (equals followed by space) at the start of any line or after an HTML tag, 
        // ensuring we don't break base64 padding (which has no space).
        .replaceAll(RegExp(r'(^|\n|>)\s*=\s+'), r'$1')
        .replaceAll('=&nbsp;', ' ');

    return content.trim();
  }
}
