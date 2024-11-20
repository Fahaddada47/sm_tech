import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sm_task/controller/map_controller.dart';
import 'package:sm_task/service/network_connectivity.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    final HomeMapController mapController = Get.find<HomeMapController>();
    final NetworkConnectivityService _networkConnectivityService = Get.find<NetworkConnectivityService>();

    Future<void> submit() async {
      if (_networkConnectivityService.isOnline == true) {
        await mapController.requestLocationPermission();
        mapController.updateMapLocation();
      } else {
        Get.snackbar(
          'No Internet',
          'Cannot update location without an internet connection.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          Obx(() {
            if (mapController.locationData.value != null) {
              return MapLibreMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    mapController.locationData.value!.latitude!,
                    mapController.locationData.value!.longitude!,
                  ),
                  zoom: 8,
                ),
                onMapCreated: (map) {
                  mapController.maplibreMapController = map;
                },
                annotationOrder: const [AnnotationType.circle],
                myLocationEnabled: true,
                compassEnabled: true,
                myLocationTrackingMode: MyLocationTrackingMode.tracking,
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  topLeft: Radius.circular(8),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  Obx(() {
                    return Text(
                      mapController.addressInfo.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      submit();
                    },
                    child: const Text('Show Current Address'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
