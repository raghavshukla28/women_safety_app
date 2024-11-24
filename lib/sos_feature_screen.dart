import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:io';

class SOSFeatureScreen extends StatefulWidget {
  @override
  _SOSFeatureScreenState createState() => _SOSFeatureScreenState();
}

class _SOSFeatureScreenState extends State<SOSFeatureScreen> with SingleTickerProviderStateMixin {
  FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  bool _isRecording = false;
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  Timer? _fakeCallTimer;
  bool _isFakeCallActive = false;
  String? _recordingPath;
  bool _isLocationEnabled = false;

  final List<Map<String, dynamic>> _emergencyContacts = [
    {
      'name': 'Police',
      'number': '911',
      'icon': CupertinoIcons.shield_fill,
      'color': Color(0xFF2196F3),
    },
    {
      'name': 'Women Helpline',
      'number': '1091',
      'icon': CupertinoIcons.phone_circle_fill,
      'color': Color(0xFFE91E63),
    },
    {
      'name': 'Ambulance',
      'number': '102',
      'icon': CupertinoIcons.heart_fill,
      'color': Color(0xFF4CAF50),
    },
  ];

  final List<Map<String, dynamic>> _safetyTips = [
    {
      'tip': 'Stay calm and assess the situation',
      'icon': CupertinoIcons.heart_circle_fill,
    },
    {
      'tip': 'Move to a well-lit or populated area if possible',
      'icon': CupertinoIcons.light_max,
    },
    {
      'tip': 'Keep your emergency contacts informed',
      'icon': CupertinoIcons.person_2_fill,
    },
    {
      'tip': 'Use main roads and avoid shortcuts',
      'icon': CupertinoIcons.map_fill,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _setupAnimations();
    _checkLocationStatus();
  }

  Future<void> _checkLocationStatus() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    setState(() {
      _isLocationEnabled = serviceEnabled;
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.location,
      Permission.storage,
    ].request();

    if (statuses[Permission.location]!.isPermanentlyDenied) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Location Permission Required'),
          content: Text('Please enable location permissions in settings for emergency features to work properly.'),
          actions: [
            CupertinoDialogAction(
              child: Text('Open Settings'),
              onPressed: () {
                openAppSettings();
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _initializeRecorder() async {
    await _requestPermissions();
    await _audioRecorder.openRecorder();
  }

  Future<void> _onSOSActivated() async {
    if (!_isRecording) {
      await _startRecording();
    } else {
      await _stopRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      Directory tempDir = Directory.systemTemp;
      _recordingPath = '${tempDir.path}/sos_recording_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _audioRecorder.startRecorder(
        toFile: _recordingPath,
        codec: Codec.aacADTS,
      );

      setState(() {
        _isRecording = true;
      });

      if (_isLocationEnabled) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high
        );
        _showLocationAlert(position);
      }

    } catch (e) {
      _showErrorAlert('Error starting recording: $e');
    }
  }

  void _showLocationAlert(Position position) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Location Captured'),
        content: Column(
          children: [
            SizedBox(height: 10),
            Text('Your current location has been recorded.'),
            SizedBox(height: 10),
            Text(
              'Lat: ${position.latitude.toStringAsFixed(4)}\nLong: ${position.longitude.toStringAsFixed(4)}',
              style: TextStyle(fontFamily: 'Courier'),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showErrorAlert(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stopRecorder();
      setState(() {
        _isRecording = false;
      });

      // Show success message
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Recording Saved'),
          content: Text('Your emergency recording has been saved successfully.'),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );

    } catch (e) {
      _showErrorAlert('Error stopping recording: $e');
    }
  }

  void _triggerFakeCall() {
    setState(() {
      _isFakeCallActive = true;
    });

    Future.delayed(Duration(seconds: 3), () {
      showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildFakeCallDialog(),
      );
    });
  }

  Widget _buildFakeCallDialog() {
    return CupertinoAlertDialog(
      title: Text("Incoming Call"),
      content: Column(
        children: [
          SizedBox(height: 16),
          Icon(CupertinoIcons.person_crop_circle_fill,
              size: 50,
              color: CupertinoColors.activeBlue),
          SizedBox(height: 8),
          Text("Mom",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text("Mobile",
              style: TextStyle(color: CupertinoColors.systemGrey)),
          SizedBox(height: 16),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          child: Text("Decline"),
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
            setState(() => _isFakeCallActive = false);
          },
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          child: Text("Accept"),
          onPressed: () {
            Navigator.pop(context);
            _showFakeCallScreen();
          },
        ),
      ],
    );
  }

  Widget _buildSafetyResourcesPanel() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _isExpanded ? 300 : 0,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildSectionTitle('Emergency Contacts'),
            ..._buildEmergencyContactCards(),
            _buildSectionTitle('Safety Tips'),
            ..._buildSafetyTipCards(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEmergencyContactCards() {
    return _emergencyContacts.map((contact) => Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onPressed: () {
          // Implement call functionality
        },
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: contact['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(contact['icon'],
                  color: contact['color'],
                  size: 24),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      )),
                  Text(contact['number'],
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                      )),
                ],
              ),
            ),
            Icon(CupertinoIcons.phone_fill,
                color: CupertinoColors.systemGreen),
          ],
        ),
      ),
    )).toList();
  }

  List<Widget> _buildSafetyTipCards() {
    return _safetyTips.map((tip) => Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(tip['icon'],
              color: CupertinoColors.activeBlue,
              size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(tip['tip'],
                style: TextStyle(
                  color: CupertinoColors.label,
                  fontSize: 14,
                )),
          ),
        ],
      ),
    )).toList();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: CupertinoColors.activeBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Emergency SOS',
            style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(_isExpanded ?
          CupertinoIcons.chevron_up :
          CupertinoIcons.chevron_down),
          onPressed: () => setState(() => _isExpanded = !_isExpanded),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildSafetyResourcesPanel(),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      CupertinoColors.systemGrey6,
                      CupertinoColors.white,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: AnimatedSOSButton(
                        onSOSActivated: _onSOSActivated,
                        isRecording: _isRecording,
                      ),
                    ),
                    SizedBox(height: 32),
                    _buildQuickActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButtons() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: CupertinoIcons.phone_fill,
            label: 'Fake Call',
            onPressed: _isFakeCallActive ? null : _triggerFakeCall,
            isActive: _isFakeCallActive,
            color: CupertinoColors.systemGreen,
          ),
          _buildActionButton(
            icon: CupertinoIcons.map_fill,
            label: 'Safe Route',
            onPressed: () {
              // Implement safe route navigation
            },
          ),
          _buildActionButton(
            icon: CupertinoIcons.book_fill,
            label: 'Guide',
            onPressed: _showEmergencyGuide,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isActive = false,
  }) {
    return CupertinoButton(
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ?
              CupertinoColors.activeBlue :
              CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isActive ?
              CupertinoColors.white :
              CupertinoColors.systemGrey,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ?
              CupertinoColors.activeBlue :
              CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  void _showEmergencyGuide() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => EmergencyGuideScreen(),
    );
  }

  @override
  void dispose() {
    _audioRecorder.closeRecorder();
    _animationController.dispose();
    _fakeCallTimer?.cancel();
    super.dispose();
  }
}

class AnimatedSOSButton extends StatelessWidget {
  final VoidCallback onSOSActivated;
  final bool isRecording;

  const AnimatedSOSButton({
    required this.onSOSActivated,
    required this.isRecording,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSOSActivated,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isRecording ?
          CupertinoColors.destructiveRed :
          CupertinoColors.systemRed,
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemRed.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            isRecording ?
            CupertinoIcons.stop_fill :
            CupertinoIcons.sos,
            color: CupertinoColors.white,
            size: 50,
          ),
        ),
      ),
    );
  }
}

class FakeCallScreen extends StatefulWidget {
  final VoidCallback onEnd;

  const FakeCallScreen({required this.onEnd});

  @override
  _FakeCallScreenState createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  Timer? _callTimer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _callTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() => _seconds++);
    });
  }

  String get _formattedTime {
    int minutes = _seconds ~/ 60;
    int remainingSeconds = _seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Mom',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 32,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _formattedTime,
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCallButton(
                    icon: CupertinoIcons.speaker_2_fill,
                    label: 'Speaker',
                  ),
                  _buildCallButton(
                    icon: CupertinoIcons.mic_off,
                    label: 'Mute',
                  ),
                  _buildCallButton(
                    icon: CupertinoIcons.phone_down_fill,
                    label: 'End',
                    color: CupertinoColors.destructiveRed,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onEnd();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required String label,
    Color? color,
    VoidCallback? onTap,
  }) {
    return CupertinoButton(
      onPressed: onTap ?? () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color ?? CupertinoColors.darkBackgroundGray,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: CupertinoColors.white),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }
}

class EmergencyGuideScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
          children: [
      Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey4,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    ),
    Expanded(
    child: CupertinoScrollbar(
    child: ListView(
    padding: EdgeInsets.all(16),
    children: [
    _buildGuideSection(
    title: 'If you feel unsafe:',
    items: [
      'Share your location with trusted contacts.',
      'Avoid walking alone in isolated areas.',
      'Keep your phone and emergency numbers handy.',
      'Learn basic self-defense techniques.',
    ],
    ),
    ],
    ),
    ),
    ),
          ],
      ),
    );
  }

  Widget _buildGuideSection({required String title, required List<String> items}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
          SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.circle_fill,
                  size: 8,
                  color: CupertinoColors.systemGrey,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}