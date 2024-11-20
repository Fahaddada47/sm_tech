import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkConnectivityService extends GetxController {
  var isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnectivity();

    Connectivity().onConnectivityChanged.listen((results) {
      _handleConnectivityResults(results);
    });
  }

  void _checkInitialConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectivityStatus(result as ConnectivityResult);
  }

  void _handleConnectivityResults(List<ConnectivityResult> results) {
    if (results.isNotEmpty) {
      _updateConnectivityStatus(results.first);
    }
  }

  void _updateConnectivityStatus(ConnectivityResult result) {
    final online = result != ConnectivityResult.none;
    isOnline.value = online;

    if (online) {
      Get.closeCurrentSnackbar();
    }
    else {
      Get.showSnackbar(const GetSnackBar(
        // title: 'No internet!',
        message: 'Please check your internet connectivity',
        isDismissible: false,
      ));
    }

  }
}