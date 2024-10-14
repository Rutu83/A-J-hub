// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'package:allinone_app/main.dart';
import 'package:allinone_app/model/business_mode.dart';
import 'package:allinone_app/model/categories_mode.dart';
import 'package:allinone_app/model/login_modal.dart';
import 'package:allinone_app/model/subcategory_model.dart';
import 'package:allinone_app/model/user_data_modal.dart';
import 'package:allinone_app/network/network_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;



Future<void> clearPreferences() async {

  await appStore.setToken('');
  await appStore.setLoggedIn(false);


  // TODO: Please do not remove this condition because this feature not supported on iOS.
  // if (isAndroid) await OneSignal.shared.clearOneSignalNotifications();
}










// login
Future<LoginResponse> loginUser(Map request) async {
  appStore.setLoading(true);

  try {
    log("Request New : $request");
    LoginResponse res = LoginResponse.fromJson(await (handleResponse(
        await buildHttpResponse('login',
            request: request, method: HttpMethodType.POST))));
    return res;
  } catch (e) {

    log("Error during login request: $e");

    rethrow;
  }
}



// save data to shared preferences
Future<void> saveUserDataMobile(LoginResponse loginResponse, UserData data) async {
  if (loginResponse.token.validate().isNotEmpty) await appStore.setToken('');
  appStore.setToken(loginResponse.token!);
  await appStore.setLoggedIn(true);
  await appStore.setName(data.username.validate());
  await appStore.setEmail(data.email.validate());

  appStore.setLoading(false);
  ///Set app configurations
  if (appStore.isLoggedIn) {
    //getAppConfigurations();
  }
}





// get user profile
Future<Map<String, dynamic>> getUserDetail() async {
  try {
    Map<String, dynamic> res;

    res = await handleResponse(
        await buildHttpResponse('profile', method: HttpMethodType.GET));
    return res['profile'];
  } catch (e) {
    appStore.setLoading(false);
    rethrow;
  }
}



// update profile
Future<void> updateProfile({
  required String name,
  required String gender,
  required String dob,
  required Function() onSuccess,
  required Function() onFail,
}) async {


  final String authToken = appStore.token;
  const String apiUrl = 'https://ajhub.co.in/api/profile/update';

  final Map<String, dynamic> payload = {
    'username': name,
    'gender': gender,
    'dob': dob,
  };

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $authToken", // Fix the token format with Bearer
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (kDebugMode) {
        print(response.body);
        print('Status Code: ${response.statusCode}');
      }
      onSuccess();
      // _showSnackBar(context, 'Password changed successfully', Colors.green);
      // Navigator.pop(context); // Navigate back after successful password change
    } else {
      // Show error from server response
      String errorMessage = 'DATA change failed';
      if (response.statusCode == 400) {
        final responseBody = json.decode(response.body);
        errorMessage = responseBody['message'] ?? errorMessage;
      }
      onFail();
      if (kDebugMode) {
        print(errorMessage);
      }
      //   _showSnackBar(context, errorMessage, Colors.red);
      if (kDebugMode) {
        print('Error: ${response.body}');
        print('Status Code: ${response.statusCode}');
      }
    }
  } catch (error) {
    onFail();
    if (kDebugMode) {
      print('Error: $error');
    }

  } finally {

  }
}





// get business-data
Future<List<BusinessModal>> getBusinessData({required List<BusinessModal>? businessmodal}) async {
  try {
    BusinessModal res;

    res = BusinessModal.fromJson(await handleResponse(await buildHttpResponse('business-data', method: HttpMethodType.GET)));
    businessmodal!.clear();
    businessmodal.add(res);
    // lastPageCallback?.call(res.data.validate().length != PER_PAGE_ITEM);
    //
    cachedDashbord = cachedDashbord;

    appStore.setLoading(false);

    return businessmodal;
  } catch (e) {
    appStore.setLoading(false);

    rethrow;
  }
}




// get Categories
Future<CategoriesResponse> getCategories() async {
  try {
    final responseJson = await handleResponse(await buildHttpResponse('categories', method: HttpMethodType.GET));
    final res = CategoriesResponse.fromJson(responseJson);

    // If you want to cache the result
    cachedHome = cachedHome ?? []; // Initialize if null
    cachedHome?.clear();
    cachedHome?.add(res);

    appStore.setLoading(false);

    return res; // Return a single CategoriesResponse
  } catch (e) {
    appStore.setLoading(false);
    rethrow;
  }
}


Future<SubcategoryResponse> getSubCategories() async {
  try {
    final responseJson = await handleResponse(await buildHttpResponse('subcategories', method: HttpMethodType.GET));
    final res = SubcategoryResponse.fromJson(responseJson);

    // If you want to cache the result
    cachedsubcategory = cachedsubcategory ?? []; // Initialize if null
    cachedsubcategory?.clear();
    cachedsubcategory?.add(res);

    appStore.setLoading(false);

    return res; // Return a single CategoriesResponse
  } catch (e) {
    appStore.setLoading(false);
    rethrow;
  }
}



// Widget _buildNewReleasesSection1() {
//   return _buildHorizontalCardSection1(
//     sectionTitle: 'Month Special',
//     items: [
//       _buildCardItem1('Gandhi Jayanti', '116M Plays', 'assets/images/gandhi_jayanti.jpg'),
//       _buildCardItem1('Navratri Wishes', '25.9M Plays', 'assets/images/navratri_wishes.jpg'),
//       _buildCardItem1('Hot Deal', '292.7M Plays', 'assets/images/hot_deal.png'),
//       _buildCardItem1('Birthday', '9.4M Plays', 'assets/images/birthday.jpg'), // Using local asset
//       _buildCardItem1('Hanuman Dada', '15.2M Plays', 'assets/images/hanuman_dada.jpg'),
//       _buildCardItem1('Trending', '19.9M Plays', 'assets/images/trending.png'),
//     ],
//   );
// }
//
// Widget _buildCardItem1(String title, String plays, String imageUrl) {
//
//   return  InkWell(
//     onTap: () {
//       // Define the list of images to show based on the title
//       List<Map<String, String>> images;
//
//       if (title == 'Gandhi Jayanti') {
//         images = [
//           {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji.jpg'},
//           {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji2.jpg'},
//           {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji3.jpg'},
//           {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji4.jpg'},
//           {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji5.jpg'},
//           {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji6.jpg'},
//           {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji7.jpg'},
//           {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji8.jpg'},
//           {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji9.jpg'},
//           {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji11.jpg'},
//           {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji12.jpg'},
//           {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji13.jpg'},
//           {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji15.jpg'},
//           {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji16.jpg'},
//           {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji17.jpg'},
//           {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji18.jpg'},
//           {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji19.jpg'},
//           {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji20.jpg'},
//           {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji21.jpg'},
//           {'title': 'Gandhi Jayanti', 'image': 'assets/images/gandhiji/gandhiji14.jpg'},
//           // Add more images as needed
//         ];
//       } else if (title == 'Navratri Wishes') {
//         images = [
//           {'title': 'Navratri', 'image': 'assets/images/navratri/navratri.jpg'},
//           {'title': 'Navratri', 'image': 'assets/images/navratri/navratri2.jpg'},
//           {'title': 'Navratri', 'image': 'assets/images/navratri/navratri3.jpg'},
//           {'title': 'Navratri', 'image': 'assets/images/navratri/navratri4.jpg'},
//           {'title': 'Navratri', 'image': 'assets/images/navratri/navratri5.jpg'},
//           {'title': 'Navratri', 'image': 'assets/images/navratri/navratri6.jpg'},
//           {'title': 'Navratri', 'image': 'assets/images/navratri/navratri7.jpg'},
//           {'title': 'Navratri', 'image': 'assets/images/navratri/navratri8.jpg'},
//           {'title': 'Navratri', 'image': 'assets/images/navratri/navratri9.jpg'},
//           {'title': 'Navratri', 'image': 'assets/images/navratri/navratri10.jpg'},
//           {'title': 'Navratri', 'image': 'assets/images/navratri/navratri11.jpg'},
//           {'title': 'Navratri', 'image': 'assets/images/navratri/navratri12.jpg'},
//           {'title': 'Navratri', 'image': 'assets/images/navratri/navratri13.jpg'},
//           // Add more images as needed
//         ];
//       }  else if (title == 'Birthday') {
//         images = [
//           {'title': 'Birthday', 'image': 'assets/images/birthday/birthday.jpg'},
//           {'title': 'Birthday', 'image': 'assets/images/birthday/birthday2.jpg'},
//           {'title': 'Birthday', 'image': 'assets/images/birthday/birthday3.jpg'},
//           {'title': 'Birthday', 'image': 'assets/images/birthday/birthday4.jpg'},
//           {'title': 'Birthday', 'image': 'assets/images/birthday/birthday5.jpg'},
//           {'title': 'Birthday', 'image': 'assets/images/birthday/birthday6.jpg'},
//           {'title': 'Birthday', 'image': 'assets/images/birthday/birthday7.jpg'},
//           {'title': 'Birthday', 'image': 'assets/images/birthday/birthday8.jpg'},
//           {'title': 'Birthday', 'image': 'assets/images/birthday/birthday9.jpg'},
//           {'title': 'Birthday', 'image': 'assets/images/birthday/birthday10.jpg'},
//           {'title': 'Birthday', 'image': 'assets/images/birthday/birthday11.jpg'},
//           {'title': 'Birthday', 'image': 'assets/images/birthday/birthday12.jpg'},
//           // Add more images as needed
//         ];
//       }  else if (title == 'Hanuman Dada') {
//         images = [
//           {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman.jpg'},
//           {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman1.jpg'},
//           {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman2.jpg'},
//           {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman3.jpg'},
//           {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman4.jpg'},
//           {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman5.jpg'},
//           {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman6.jpg'},
//           {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman7.jpg'},
//           {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman8.jpg'},
//           {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman9.jpg'},
//           {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman10.jpg'},
//           {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman11.jpg'},
//           {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman12.jpg'},
//           {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman13.jpg'},
//           {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman14.jpg'},
//           {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman9.jpg'},
//           {'title': 'Hanuman Dada', 'image': 'assets/images/hanuman/hanuman10.jpg'},
//           // Add more images as needed
//         ];
//       }else {
//         images = []; // Default empty list if no matching title
//       }
//
//       // Navigate to the CategoryTopics screen with the relevant images
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => CategoryTopics(
//             title: title,
//             topics: images,
//           ),
//         ),
//       );
//     },
//     child: Container(
//       width: 100.w,
//       margin: EdgeInsets.only(right: 10.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Container(
//             width: 100.w,
//             height: 100.w,
//             decoration: const BoxDecoration(
//               shape: BoxShape.circle,
//             ),
//             child: ClipOval(
//               child: imageUrl.startsWith('assets/')
//                   ? Image.asset(
//                 imageUrl,
//                 fit: BoxFit.cover,
//               )
//                   : Image.network(
//                 imageUrl,
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           SizedBox(height: 10.h),
//           Text(
//             title,
//             style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
//             overflow: TextOverflow.ellipsis,
//             maxLines: 1,
//           ),
//         ],
//       ),
//     ),
//   );
//
// }
