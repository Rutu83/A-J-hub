import 'dart:convert';

import 'package:ajhub_app/main.dart';
import 'package:ajhub_app/screens/business_form.dart';
import 'package:ajhub_app/screens/edit_business_form.dart';
import 'package:ajhub_app/utils/configs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BusinessList extends StatefulWidget {
  const BusinessList({super.key});

  @override
  BusinessListState createState() => BusinessListState();
}

class BusinessListState extends State<BusinessList> {
  List<dynamic> businessData = [];
  bool isLoading = true;
  int? selectedBusinessId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await fetchStoredBusinessID();
    await fetchBusinessData();
  }

  Future<void> fetchStoredBusinessID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        selectedBusinessId = prefs.getInt('selected_business_id');
      });
    }
  }

  Future<void> fetchBusinessData() async {
    const apiUrl = '${BASE_URL}getbusinessprofile';
    String token = appStore.token;

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        if (mounted) {
          setState(() {
            businessData = data ?? [];
            isLoading = false;
          });

          if (selectedBusinessId == null && businessData.isNotEmpty) {
            if (businessData.length == 1) {
              _setActiveBusiness(businessData.first, showSnackbar: false);
            } else {
              _promptToSelectDefaultBusiness();
            }
          }
        }
      } else if (response.statusCode == 404) {
        // --- MODIFIED: Treat 404 as "No Businesses Found" (Valid State) ---
        if (mounted) {
          setState(() {
            businessData = [];
            isLoading = false;
          });
        }
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _setActiveBusiness(dynamic business,
      {bool showSnackbar = true}) async {
    if (business == null) return;

    if (mounted) {
      setState(() {
        selectedBusinessId = business['id'];
      });
    }

    await _storeActiveBusiness(business);

    if (showSnackbar && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${business['business_name']} is now set as active.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _promptToSelectDefaultBusiness() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false, // User must make a choice
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Select Your Active Business'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: businessData.length,
                itemBuilder: (context, index) {
                  final business = businessData[index];
                  return ListTile(
                    title:
                        Text(business['business_name'] ?? 'Unnamed Business'),
                    onTap: () {
                      Navigator.of(dialogContext).pop();
                      _setActiveBusiness(business);
                    },
                  );
                },
              ),
            ),
          );
        },
      );
    });
  }

  // --- MODIFIED: Proper saving of active business data ---
  Future<void> _storeActiveBusiness(dynamic business) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (business['id'] == null) return;

    // 1. Store the ID of the selected business
    await prefs.setInt('selected_business_id', business['id']);

    // 2. Store individual fields for easy access on other screens.
    // This is useful if another screen only needs the name or logo without
    // needing to decode the entire business object.
    await prefs.setString(
        'active_business_name', business['business_name'] ?? 'No Name');
    await prefs.setString('active_business_logo', business['logo'] ?? '');
    await prefs.setString(
        'active_business_owner_photo', business['personal_photo'] ?? '');

    await prefs.setString('active_business', json.encode(business));
  }

  void _handleErrorResponse(http.Response response) {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${response.statusCode}. Failed to load data.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmDelete(String businessId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Business'),
          content: const Text('Are you sure you want to delete this business?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteBusinessProfile(businessId);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteBusinessProfile(String businessId) async {
    if (mounted) setState(() => isLoading = true);
    final String apiUrl = '${BASE_URL}delete/business-profile/$businessId';
    String token = appStore.token;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Business deleted successfully.'),
                backgroundColor: Colors.green),
          );
        }

        // --- MODIFIED: Properly clear all active business data if it was deleted ---
        if (selectedBusinessId.toString() == businessId) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('selected_business_id');
          await prefs.remove('active_business');
          await prefs.remove('active_business_name');
          await prefs.remove('active_business_logo');
          await prefs.remove('active_business_owner_photo');
          if (mounted) {
            setState(() {
              selectedBusinessId = null;
            });
          }
        }
        await fetchBusinessData();
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('An error occurred. Please try again later.'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _handleBusinessSelection(int businessId) async {
    if (selectedBusinessId == businessId) return;

    final selectedBusinessObject = businessData
        .firstWhere((b) => b['id'] == businessId, orElse: () => null);
    if (selectedBusinessObject == null) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Active Business'),
        content: Text(
            'Do you want to make "${selectedBusinessObject['business_name']}" your active business?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _setActiveBusiness(selectedBusinessObject);
    }
  }

  void _navigateToAddBusiness() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BusinessForm()),
    ).then((_) => fetchBusinessData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'My Businesses',
          style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : businessData.isEmpty
              ? _buildNoDataAvailable()
              : ListView.builder(
                  padding: EdgeInsets.all(12.w),
                  itemCount: businessData.length,
                  itemBuilder: (context, index) {
                    final business = businessData[index];
                    final bool isSelected =
                        selectedBusinessId == business['id'];

                    return BusinessCard(
                      business: business,
                      isSelected: isSelected,
                      onTap: () => _handleBusinessSelection(business['id']),
                      onUpdate: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EditBusinessForm(business: business)),
                        ).then((result) {
                          if (result == true) {
                            fetchBusinessData();
                          }
                        });
                      },
                      onDelete: () => _confirmDelete(business['id'].toString()),
                    );
                  },
                ),
      floatingActionButton: businessData.length < 3
          ? FloatingActionButton.extended(
              onPressed: _navigateToAddBusiness,
              backgroundColor: Colors.red,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text('Add Business',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
    );
  }

  Widget _buildNoDataAvailable() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.add_circled, size: 80, color: Colors.grey[400]),
          SizedBox(height: 20.h),
          Text('Add Your First Business',
              style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'Create a business profile to start generating posters.',
              style:
                  GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// BusinessCard widget remains unchanged
class BusinessCard extends StatelessWidget {
  final dynamic business;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const BusinessCard({
    super.key,
    required this.business,
    required this.isSelected,
    required this.onTap,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    String imageUrl = business['logo'] ?? '';
    String ownerPhotoUrl = business['personal_photo'] ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: isSelected ? 6 : 2,
        margin: EdgeInsets.only(bottom: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
          side: BorderSide(
              color: isSelected ? Colors.red : Colors.grey.shade200,
              width: isSelected ? 2.0 : 1.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  SizedBox(
                    width: 70.w,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 35.r,
                          backgroundColor: Colors.grey.shade100,
                          child: ClipOval(
                            child: imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    width: 70.r * 2,
                                    height: 70.r * 2,
                                    placeholder: (context, url) =>
                                        const CupertinoActivityIndicator(),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                            'assets/images/app_logo.png'),
                                  )
                                : Icon(Icons.business_center,
                                    size: 30.r, color: Colors.grey.shade400),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 15.r,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 13.r,
                              backgroundColor: Colors.grey.shade200,
                              child: ClipOval(
                                child: ownerPhotoUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: ownerPhotoUrl,
                                        fit: BoxFit.cover,
                                        width: 13.r * 2,
                                        height: 13.r * 2,
                                        placeholder: (context, url) =>
                                            const CupertinoActivityIndicator(),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                                'assets/images/app_logo.png'),
                                      )
                                    : Icon(Icons.person,
                                        size: 15.r,
                                        color: Colors.grey.shade400),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          business['business_name'] ?? 'No Name',
                          style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          business['owner_name'] ?? 'No Owner Name',
                          style: GoogleFonts.poppins(
                              fontSize: 13.sp, color: Colors.grey.shade700),
                        ),
                        const Divider(height: 16),
                        _buildDetailRow(Icons.phone_outlined,
                            business['mobile_number'] ?? 'N/A'),
                        SizedBox(height: 4.h),
                        _buildDetailRow(
                            Icons.email_outlined, business['email'] ?? 'N/A'),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'Edit') onUpdate();
                      if (value == 'Delete') onDelete();
                    },
                    icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                          value: 'Edit', child: Text('Edit')),
                      const PopupMenuItem<String>(
                          value: 'Delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14)),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade500, size: 14.sp),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black54),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
