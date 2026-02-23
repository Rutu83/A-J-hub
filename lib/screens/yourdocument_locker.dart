// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ajhub_app/main.dart'; // For appStore.token
import 'package:ajhub_app/utils/configs.dart'; // For BASE_URL
import 'package:crypto/crypto.dart'; // ** NEW: For hashing the security answer **
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gallery_saver_plus/gallery_saver.dart'; // ** NEW: For saving images **
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart'; // ** NEW: For temp file path **
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart'; // ** NEW: For sharing files **
import 'package:shared_preferences/shared_preferences.dart';

// ===================================================================
// PIN AUTHENTICATION GATE (Now with Recovery)
// ===================================================================

class DocumentLockerScreen extends StatefulWidget {
  const DocumentLockerScreen({super.key});

  @override
  State<DocumentLockerScreen> createState() => _DocumentLockerScreenState();
}

class _DocumentLockerScreenState extends State<DocumentLockerScreen> {
  // --- Existing State ---
  bool _isUnlocked = false;
  bool _isLoading = true;
  String? _savedPin;
  String _currentPin = '';
  String _tempPin = '';
  String _statusMessage = 'Create a 4-digit PIN';
  bool _isConfirming = false;

  // --- ** NEW STATE FOR PIN RECOVERY ** ---
  bool _isSettingUpSecurity = false;
  bool _isRecoveringPin = false;
  String? _savedSecurityQuestion;
  String? _savedAnswerHash;
  String? _selectedQuestion;
  final _answerController = TextEditingController();

  final List<String> _securityQuestions = [
    'What was your first pet\'s name?',
    'What is your mother\'s maiden name?',
    'What was the name of your elementary school?',
    'In which city were you born?',
  ];

  @override
  void initState() {
    super.initState();
    _checkPinStatus();
    _selectedQuestion = _securityQuestions.first;
  }

  /// Hashes a string using SHA-256 for secure storage.
  String _hashString(String input) {
    final bytes = utf8.encode(input); // data being hashed
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _checkPinStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _savedPin = prefs.getString('document_locker_pin');
      _savedSecurityQuestion = prefs.getString('locker_security_question');
      _savedAnswerHash = prefs.getString('locker_security_answer_hash');
      _isLoading = false;
      _statusMessage =
          _savedPin == null ? 'Create a 4-digit PIN' : 'Enter your PIN';
    });
  }

  // --- ** UPDATED: Main Build Method with New UI States ** ---
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isUnlocked) {
      return const _DocumentLockerFeature();
    } else if (_isSettingUpSecurity) {
      return _buildSecurityQuestionSetupScreen();
    } else if (_isRecoveringPin) {
      return _buildPinRecoveryScreen();
    } else {
      return _buildPinScreen();
    }
  }

  void _onKeyPressed(String value) {
    // ... (This function remains unchanged)
    if (_isUnlocked) return;
    setState(() {
      if (value == 'backspace') {
        if (_currentPin.isNotEmpty) {
          _currentPin = _currentPin.substring(0, _currentPin.length - 1);
        }
      } else if (_currentPin.length < 4) {
        _currentPin += value;
      }

      if (_currentPin.length == 4) {
        _handlePinSubmission();
      }
    });
  }

  // --- ** UPDATED: Logic for PIN Creation and Verification ** ---
  Future<void> _handlePinSubmission() async {
    if (_savedPin == null) {
      // --- PIN Setup Flow ---
      if (!_isConfirming) {
        _tempPin = _currentPin;
        setState(() {
          _isConfirming = true;
          _statusMessage = 'Confirm your PIN';
          _currentPin = '';
        });
      } else {
        if (_currentPin == _tempPin) {
          // ** CHANGE: Instead of unlocking, go to security setup **
          setState(() {
            _statusMessage = 'PIN Confirmed. Now set up recovery.';
            _isSettingUpSecurity = true;
          });
        } else {
          setState(() {
            _statusMessage = 'PINs did not match. Try again.';
            _isConfirming = false;
            _tempPin = '';
            _currentPin = '';
          });
          Timer(const Duration(seconds: 2), () {
            if (mounted && !_isUnlocked) {
              setState(() => _statusMessage = 'Create a 4-digit PIN');
            }
          });
        }
      }
    } else {
      // --- PIN Verification Flow (Unchanged) ---
      if (_currentPin == _savedPin) {
        setState(() {
          _statusMessage = 'Unlocked!';
          _isUnlocked = true;
        });
      } else {
        setState(() => _statusMessage = 'Incorrect PIN. Try again.');
        _currentPin = '';
        Timer(const Duration(seconds: 2), () {
          if (mounted && !_isUnlocked) {
            setState(() => _statusMessage = 'Enter your PIN');
          }
        });
      }
    }
  }

  // --- ** NEW: Handle saving the security question ** ---
  Future<void> _saveSecurityInfo() async {
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Answer cannot be empty.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('document_locker_pin', _currentPin);
    await prefs.setString('locker_security_question', _selectedQuestion!);
    await prefs.setString('locker_security_answer_hash',
        _hashString(_answerController.text.trim()));

    setState(() {
      _statusMessage = 'PIN Created!';
      _isUnlocked = true;
    });
  }

  // --- ** NEW: Handle verifying the recovery answer ** ---
  void _verifyRecoveryAnswer() {
    final enteredAnswer = _answerController.text.trim();
    if (enteredAnswer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your answer.')));
      return;
    }

    final enteredAnswerHash = _hashString(enteredAnswer);
    if (enteredAnswerHash == _savedAnswerHash) {
      // Success! Reset PIN.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Verification successful. Please create a new PIN.'),
          backgroundColor: Colors.green));
      _resetPinSettings();
    } else {
      // Failure
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Incorrect answer. Please try again.'),
          backgroundColor: Colors.red));
    }
  }

  // --- ** NEW: Reset all PIN-related settings ** ---
  Future<void> _resetPinSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('document_locker_pin');
    await prefs.remove('locker_security_question');
    await prefs.remove('locker_security_answer_hash');

    if (!mounted) return;
    setState(() {
      _isRecoveringPin = false;
      _isConfirming = false;
      _savedPin = null;
      _currentPin = '';
      _tempPin = '';
      _answerController.clear();
      _statusMessage = 'Create a 4-digit PIN';
    });
  }

  // --- ** UPDATED AND NEW UI WIDGETS ** ---

  Widget _buildPinScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Icon(CupertinoIcons.lock_shield_fill,
                color: Colors.red, size: 48),
            const SizedBox(height: 24),
            Text('Document Locker',
                style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            const SizedBox(height: 12),
            Text(_statusMessage,
                style:
                    GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: index < _currentPin.length
                        ? Colors.red
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            const Spacer(),
            _buildKeypad(),
            // ** NEW: Forgot PIN button **
            if (_savedPin != null)
              TextButton(
                onPressed: () {
                  if (_savedSecurityQuestion == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('No recovery method was set up for this PIN.'),
                        backgroundColor: Colors.orange));
                  } else {
                    setState(() {
                      _isRecoveringPin = true;
                      _currentPin = '';
                      _answerController.clear();
                    });
                  }
                },
                child: Text('Forgot PIN?',
                    style: GoogleFonts.poppins(color: Colors.red)),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    // ... (This widget remains unchanged)
    final keys = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '',
      '0',
      'backspace'
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: keys.map((key) {
        if (key.isEmpty) return Container();
        return TextButton(
          style: TextButton.styleFrom(shape: const CircleBorder()),
          onPressed: () => _onKeyPressed(key),
          child: key == 'backspace'
              ? const Icon(Icons.backspace_outlined,
                  color: Colors.black54, size: 28)
              : Text(key,
                  style:
                      GoogleFonts.poppins(fontSize: 32, color: Colors.black87)),
        );
      }).toList(),
    );
  }

  // ** NEW: Screen for setting up the security question **
  Widget _buildSecurityQuestionSetupScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
          title: const Text('Setup Recovery'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(CupertinoIcons.question_circle_fill,
                size: 60, color: Colors.red),
            const SizedBox(height: 20),
            Text('Security Question',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
                'This will be used to recover your PIN if you forget it. Choose wisely.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey[600])),
            const SizedBox(height: 40),
            // Dropdown for questions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey.shade400)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedQuestion,
                  isExpanded: true,
                  items: _securityQuestions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: GoogleFonts.poppins()),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedQuestion = newValue;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Textfield for answer
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                labelText: 'Your Answer (case-sensitive)',
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2)),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveSecurityInfo,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text('Save and Continue',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ** NEW: Screen for recovering the PIN **
  Widget _buildPinRecoveryScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Recover PIN'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _isRecoveringPin = false),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(CupertinoIcons.lock_open_fill,
                size: 60, color: Colors.red),
            const SizedBox(height: 20),
            Text('Answer Your Question',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            // Display the question
            Text(_savedSecurityQuestion ?? 'No question found.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87)),
            const SizedBox(height: 20),
            // Textfield for answer
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                labelText: 'Your Answer (case-sensitive)',
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2)),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _verifyRecoveryAnswer,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text('Verify and Reset PIN',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// The rest of the file remains unchanged.
// _DocumentLockerFeature, DocumentLockerOnboardingScreen,
// DocumentLockerContentPage, and DocumentViewPage are all the same.
// ===================================================================

class _DocumentLockerFeature extends StatefulWidget {
  const _DocumentLockerFeature();

  @override
  State<_DocumentLockerFeature> createState() => _DocumentLockerFeatureState();
}

class _DocumentLockerFeatureState extends State<_DocumentLockerFeature> {
  bool _showOnboarding = true;

  void _proceedToLocker() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return DocumentLockerOnboardingScreen(
        onFinished: _proceedToLocker,
      );
    } else {
      return const DocumentLockerContentPage();
    }
  }
}

class DocumentLockerOnboardingScreen extends StatelessWidget {
  final VoidCallback onFinished;

  const DocumentLockerOnboardingScreen({super.key, required this.onFinished});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Colors.red;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.lock_shield_fill,
                      color: primaryColor, size: 32),
                  SizedBox(width: 12),
                  Text(
                    'Aj Hub Locker',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryColor),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: Image.asset('assets/images/lockerimg.jpeg'),
              ),
              const Spacer(),
              const Text('Anytime, Anywhere',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937))),
              const SizedBox(height: 16),
              const Text(
                'One can access their Digital documents anytime, anywhere and share it online. This is convenient and time saving.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.grey.shade300)),
                  const SizedBox(width: 8),
                  Container(
                      width: 24,
                      height: 8,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: primaryColor)),
                  const SizedBox(width: 8),
                  Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.grey.shade300)),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onFinished,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Let's Go",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Document {
  final int id;
  final String name;
  final String imageUrl;

  Document({required this.id, required this.name, required this.imageUrl});

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
        id: json['id'], name: json['name'], imageUrl: json['image_url']);
  }
}

class DocumentLockerContentPage extends StatefulWidget {
  const DocumentLockerContentPage({super.key});

  @override
  State<DocumentLockerContentPage> createState() =>
      _DocumentLockerContentPageState();
}

class _DocumentLockerContentPageState extends State<DocumentLockerContentPage> {
  final List<Document> _documents = [];
  final ImagePicker _picker = ImagePicker();
  bool _isDeleting = false;
  bool _isFetching = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    setState(() => _isFetching = true);
    try {
      final response = await http.get(Uri.parse('${BASE_URL}documents'),
          headers: {'Authorization': 'Bearer ${appStore.token}'});
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _documents.clear();
          _documents.addAll(data.map((doc) => Document.fromJson(doc)).toList());
        });
      } else {
        throw Exception(
            'Failed to load documents. Status: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error fetching documents: $e'),
          backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  Future<void> _uploadToApi(String docName, File imageFile) async {
    setState(() => _isUploading = true);
    var uri = Uri.parse('${BASE_URL}documents/upload');
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer ${appStore.token}'
      ..fields['name'] = docName
      ..files.add(
          await http.MultipartFile.fromPath('document_image', imageFile.path));
    try {
      var response = await http.Response.fromStream(await request.send());
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Document uploaded!'),
            backgroundColor: Colors.green));
        await _fetchDocuments();
      } else {
        throw Exception('Upload failed: ${response.body}');
      }
    } catch (e) {
      print('Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Upload error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteDocument(int docId) async {
    if (_isDeleting) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this document?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      final url = Uri.parse('${BASE_URL}documents/$docId');
      final response = await http.delete(url, headers: {
        'Authorization': 'Bearer ${appStore.token}',
        'Accept': 'application/json'
      });

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Document deleted successfully.'),
            backgroundColor: Colors.green));
        setState(() => _documents.removeWhere((doc) => doc.id == docId));
      } else {
        String errorMessage = 'Failed to delete document.';
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage =
              errorData['error'] ?? errorData['message'] ?? errorMessage;
        } catch (_) {
          errorMessage =
              response.body.isNotEmpty ? response.body : errorMessage;
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'),
          backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _handleUploadProcess() async {
    final String? docName = await _showNameDialog();
    if (docName != null && docName.isNotEmpty) {
      _showImageSourceActionSheet(context, (ImageSource source) async {
        final XFile? pickedFile = await _picker.pickImage(source: source);
        if (pickedFile != null) {
          await _uploadToApi(docName, File(pickedFile.path));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Document Locker'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
              onPressed: _isFetching ? null : _fetchDocuments,
              icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Stack(
        children: [
          _buildBodyContent(),
          if (_isUploading) _buildUploadingOverlay(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isUploading ? null : _handleUploadProcess,
        backgroundColor: _isUploading ? Colors.grey : Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isFetching) {
      return const Center(child: CircularProgressIndicator(color: Colors.red));
    }
    if (_documents.isEmpty) {
      return _buildEmptyState();
    }
    return _buildDocumentGrid();
  }

  Widget _buildUploadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text('Uploading Document...',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.doc_text_search,
              size: 100, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text('Your locker is empty',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600])),
          const SizedBox(height: 10),
          Text("Tap the '+' button to add your first document.",
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildDocumentGrid() {
    return RefreshIndicator(
      onRefresh: _fetchDocuments,
      color: Colors.red,
      child: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.8,
        ),
        itemCount: _documents.length,
        itemBuilder: (context, index) {
          return _buildDocumentCard(_documents[index]);
        },
      ),
    );
  }

  Widget _buildDocumentCard(Document doc) {
    return Card(
      elevation: 5,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          InkWell(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DocumentViewPage(document: doc))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: doc.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        Image.asset('assets/images/app_logo.png'),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  color: Colors.black.withOpacity(0.7),
                  child: Text(
                    doc.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                onPressed: () => _deleteDocument(doc.id),
                tooltip: 'Delete Document',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showNameDialog() {
    final TextEditingController nameController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Name Your Document'),
        content: TextField(
            controller: nameController,
            autofocus: true,
            decoration:
                const InputDecoration(hintText: 'e.g., Passport, ID Card')),
        actions: [
          TextButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.pop(context)),
          ElevatedButton(
              child: const Text('SAVE'),
              onPressed: () => Navigator.pop(context, nameController.text)),
        ],
      ),
    );
  }

  void _showImageSourceActionSheet(
      BuildContext context, Function(ImageSource) onSelectSource) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Select Document Source'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
              child: const Text('Gallery'),
              onPressed: () {
                Navigator.pop(context);
                onSelectSource(ImageSource.gallery);
              })
        ],
        cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
      ),
    );
  }
}

// ===================================================================
// ** MODIFIED SECTION: DocumentViewPage with Share & Download **
// ===================================================================

class DocumentViewPage extends StatefulWidget {
  final Document document;
  const DocumentViewPage({super.key, required this.document});

  @override
  State<DocumentViewPage> createState() => _DocumentViewPageState();
}

class _DocumentViewPageState extends State<DocumentViewPage> {
  bool _isProcessing = false;

  /// Saves the document image to the device's gallery.
  Future<void> _downloadDocument() async {
    setState(() => _isProcessing = true);
    try {
      final success =
          await GallerySaver.saveImage(widget.document.imageUrl, toDcim: true);

      if (success ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Document saved to gallery.'),
          backgroundColor: Colors.green,
        ));
      } else {
        throw Exception('Failed to save document.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error downloading document: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// Downloads the image to a temporary file and shares it.
  Future<void> _shareDocument() async {
    setState(() => _isProcessing = true);
    try {
      final uri = Uri.parse(widget.document.imageUrl);
      final response = await http.get(uri);
      final bytes = response.bodyBytes;

      final tempDir = await getTemporaryDirectory();
      // Create a safe filename
      final fileName =
          '${widget.document.name.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_')}.jpg';
      final path = '${tempDir.path}/$fileName';

      await File(path).writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(path)],
        text: 'Sharing my document: ${widget.document.name}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error sharing document: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.document.name),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isProcessing ? null : _downloadDocument,
            icon: const Icon(Icons.download),
            tooltip: 'Download',
          ),
          IconButton(
            onPressed: _isProcessing ? null : _shareDocument,
            icon: const Icon(Icons.share),
            tooltip: 'Share',
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: PhotoView(
              imageProvider: NetworkImage(widget.document.imageUrl),
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 2,
              initialScale: PhotoViewComputedScale.contained,
              loadingBuilder: (context, event) => const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
              heroAttributes: PhotoViewHeroAttributes(tag: widget.document.id),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Processing...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
