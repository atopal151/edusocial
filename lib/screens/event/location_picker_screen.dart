import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/user_appbar/back_appbar.dart';
import '../../services/language_service.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final LanguageService languageService = Get.find<LanguageService>();
  
  GoogleMapController? mapController;
  LatLng? selectedLocation;
  String selectedAddress = '';
  bool isLoading = false;
  Set<Marker> markers = {};
  
  // İstanbul varsayılan lokasyon
  static const LatLng defaultLocation = LatLng(41.0082, 28.9784);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Konum izinlerini kontrol et
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setDefaultLocation();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setDefaultLocation();
        return;
      }

      // Mevcut konumu al
      Position position = await Geolocator.getCurrentPosition();
      final currentLocation = LatLng(position.latitude, position.longitude);
      
      setState(() {
        selectedLocation = currentLocation;
      });
      
      _addMarker(currentLocation);
      _getAddressFromLocation(currentLocation);
      
      // Haritayı mevcut konuma götür
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(currentLocation, 15),
        );
      }
    } catch (e) {
      debugPrint('Konum alırken hata: $e');
      _setDefaultLocation();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _setDefaultLocation() {
    setState(() {
      selectedLocation = defaultLocation;
      isLoading = false;
    });
    _addMarker(defaultLocation);
    _getAddressFromLocation(defaultLocation);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (selectedLocation != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(selectedLocation!, 15),
      );
    }
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      selectedLocation = location;
    });
    _addMarker(location);
    _getAddressFromLocation(location);
  }

  void _addMarker(LatLng location) {
    setState(() {
      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: location,
          infoWindow: InfoWindow(
            title: languageService.tr("event.locationPicker.selectedLocation"),
            snippet: selectedAddress,
          ),
        ),
      );
    });
  }

  Future<void> _getAddressFromLocation(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          selectedAddress = [
            place.name,
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.country,
          ].where((part) => part != null && part.isNotEmpty).join(', ');
        });
      }
    } catch (e) {
      debugPrint('Adres alırken hata: $e');
      setState(() {
        selectedAddress = '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
      });
    }
  }

  void _confirmLocation() {
    if (selectedLocation != null) {
      Get.back(result: {
        'latitude': selectedLocation!.latitude,
        'longitude': selectedLocation!.longitude,
        'address': selectedAddress,
        'googleMapsUrl': 'https://maps.google.com/?q=${selectedLocation!.latitude},${selectedLocation!.longitude}',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: BackAppBar(
        iconBackgroundColor: Color(0xffffffff),
        title: languageService.tr("event.locationPicker.title"),
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            onTap: _onMapTapped,
            initialCameraPosition: CameraPosition(
              target: selectedLocation ?? defaultLocation,
              zoom: 15,
            ),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            zoomControlsEnabled: false,
          ),

          // Loading Indicator
          if (isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xfffb535c),
                ),
              ),
            ),

          // Bottom Info Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Color(0xff9ca3ae),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Title
                    Text(
                      languageService.tr("event.locationPicker.selectedLocation"),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff414751),
                      ),
                    ),
                    SizedBox(height: 8),

                    // Address
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xfff5f6f7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Color(0xfffb535c),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedAddress.isEmpty 
                                  ? languageService.tr("event.locationPicker.tapToSelect")
                                  : selectedAddress,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: selectedAddress.isEmpty 
                                    ? Color(0xff9ca3ae) 
                                    : Color(0xff414751),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // Buttons
                    Column(
                      children: [
                        // Current Location Button
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: languageService.tr("event.locationPicker.currentLocation"),
                            height: 45,
                            borderRadius: 12,
                            onPressed: _getCurrentLocation,
                            isLoading: RxBool(isLoading),
                            backgroundColor: Color(0xffffffff),
                            textColor: Color(0xff414751),
                          ),
                        ),
                        SizedBox(height: 12),
                        
                        // Confirm Button
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: languageService.tr("event.locationPicker.confirmLocation"),
                            height: 45,
                            borderRadius: 12,
                            onPressed: selectedLocation != null ? _confirmLocation : () {},
                            isLoading: RxBool(false),
                            backgroundColor: selectedLocation != null 
                                ? Color(0xfffb535c) 
                                : Color(0xff9ca3ae),
                            textColor: Color(0xffffffff),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
