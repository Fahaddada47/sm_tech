import 'dart:convert';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:hive/hive.dart';
import 'package:sm_task/repository/map_repository.dart';

class HomeMapController extends GetxController {
  var locationData = Rxn<LocationData>();
  var addressInfo = 'Getting location info'.obs;
  var directions = ''.obs;

  final Location location = Location();
  final MapRepository mapRepository;
  MapLibreMapController? maplibreMapController;

  HomeMapController({required this.mapRepository});

  @override
  void onInit() {
    super.onInit();
    retrieveLastLocation();
    requestLocationPermission();
  }

  Future<void> retrieveLastLocation() async {
    final box = await Hive.openBox('locationBox');
    final lastLatitude = box.get('latitude');
    final lastLongitude = box.get('longitude');
    final lastAddress = box.get('address');

    if (lastLatitude != null && lastLongitude != null) {
      locationData.value = LocationData.fromMap({
        'latitude': lastLatitude,
        'longitude': lastLongitude,
      });
      addressInfo.value = lastAddress ?? 'Address not available';
    }
  }

  Future<void> saveLocationToHive(double latitude, double longitude, String address) async {
    final box = await Hive.openBox('locationBox');
    await box.put('latitude', latitude);
    await box.put('longitude', longitude);
    await box.put('address', address);
  }

  Future<void> requestLocationPermission() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
    }

    if (permissionGranted == PermissionStatus.granted) {
      updateMapLocation();
    }
  }

  Future<void> updateMapLocation() async {
    locationData.value = await location.getLocation();
    if (locationData.value != null && maplibreMapController != null) {
      final latitude = locationData.value!.latitude!;
      final longitude = locationData.value!.longitude!;

      maplibreMapController!.animateCamera(
        CameraUpdate.newLatLng(LatLng(latitude, longitude)),
      );

      getAddressFromCoordinates(latitude, longitude);
    }
  }

  Future<void> getAddressFromCoordinates(double latitude, double longitude) async {
    addressInfo.value = "Fetching address...";
    final response = await mapRepository.fetchAddress(latitude, longitude);

    if (response.statusCode == 200) {
      try {
        final data = response.data is String
            ? json.decode(response.data)
            : response.data;

        if (data != null && data['place'] != null) {
          final address = data['place']['address'] ?? 'Address not available';
          addressInfo.value = address;

          // Save to Hive
          saveLocationToHive(latitude, longitude, address);
        } else {
          addressInfo.value = "Invalid data format";
        }
      } catch (e) {
        addressInfo.value = "Error parsing address data: ${e.toString()}";
      }
    } else {
      addressInfo.value = "Error: ${response.message}";
    }
  }
}
