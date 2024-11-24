import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:tflite_flutter/tflite_flutter.dart';

class SafetyScoreService {
  static const String OPENCAGE_API_KEY = "bba679dd12da4342ac1fb4a72b7959bc";

  Future<Map<String, dynamic>> getCoordinatesFromAddress(String address) async {
    try {
      final url = Uri.parse(
          'https://api.opencagedata.com/geocode/v1/json?q=${Uri.encodeComponent(address)}&key=$OPENCAGE_API_KEY'
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results']?.isNotEmpty ?? false) {
          return {
            'lat': data['results'][0]['geometry']['lat'],
            'lng': data['results'][0]['geometry']['lng']
          };
        }
      }
      throw Exception('Location not found');
    } catch (e) {
      throw Exception('Failed to get coordinates: $e');
    }
  }
}

class SafetyScoreScreen extends StatefulWidget {
  @override
  _SafetyScoreScreenState createState() => _SafetyScoreScreenState();
}

class _SafetyScoreScreenState extends State<SafetyScoreScreen> with SingleTickerProviderStateMixin {
  final _safetyService = SafetyScoreService();
  final _addressController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;
  double? _safetyScore;
  String? _recommendation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String _getSafetyRecommendation(double score) {
    if (score >= 0.8) return "This place is generally safe.";
    if (score >= 0.5) return "This place is moderately safe. Exercise caution.";
    return "This place is unsafe. Avoid if possible.";
  }

  Color _getSafetyColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.5) return Colors.orange;
    return Colors.red;
  }

  Future<void> _checkSafety() async {
    if (_addressController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _safetyScore = null;
      _recommendation = null;
    });

    try {
      final coordinates = await _safetyService.getCoordinatesFromAddress(_addressController.text);
      await Future.delayed(Duration(seconds: 2));
      double mockScore = 0.75;

      setState(() {
        _safetyScore = mockScore;
        _recommendation = _getSafetyRecommendation(mockScore);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Safety Score',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              labelText: 'Enter Location',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Icon(Icons.location_on),
                            ),
                          ),
                          SizedBox(height: 16),
                          AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) => Transform.scale(
                              scale: _scaleAnimation.value,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _checkSafety,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: _isLoading
                                    ? CircularProgressIndicator(color: Colors.white)
                                    : Text(
                                  'Check Safety Score',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  if (_safetyScore != null)
                    AnimatedOpacity(
                      opacity: _safetyScore != null ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 500),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Safety Score',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getSafetyColor(_safetyScore!),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getSafetyColor(_safetyScore!).withOpacity(0.3),
                                      blurRadius: 12,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '${(_safetyScore! * 100).toInt()}%',
                                    style: GoogleFonts.poppins(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                _recommendation!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}