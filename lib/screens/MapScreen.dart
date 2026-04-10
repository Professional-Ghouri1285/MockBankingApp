import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../app_state.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  GoogleMapController? _controller;

  final LatLng arfaPark = const LatLng(31.4760, 74.3429);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (Platform.isAndroid && state == AppLifecycleState.resumed) {
      _forceReRender();
    }
  }

  Future<void> _forceReRender() async {
    if (_controller != null) {
      try {
        await _controller!.setMapStyle('[]');
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Our Location',
          style: TextStyle(
            color: appState.darkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: IconThemeData(
          color: appState.darkMode ? Colors.white : Colors.black,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: arfaPark,
          zoom: 16,
        ),
        mapType: MapType.normal,
        markers: {
          Marker(
            markerId: const MarkerId("arfa_park"),
            position: arfaPark,
            infoWindow: const InfoWindow(
              title: "Arfa Software Technology Park",
              snippet: "Lahore, Pakistan",
            ),
          ),
        },
        onMapCreated: (controller) {
          _controller = controller;
        },
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
      ),
    );
  }
}
