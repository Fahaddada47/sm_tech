import 'package:get/get.dart';
import 'package:sm_task/controller/map_controller.dart';
import 'package:sm_task/controller/user_controller.dart';
import 'package:sm_task/repository/map_repository.dart';
import 'package:sm_task/repository/user_repository.dart';
import 'package:sm_task/service/network_connectivity.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    final userRepository = UserRepository();
    final mapRepository = MapRepository();
    Get.put(NetworkConnectivityService());
    Get.put(UserController(userRepository: userRepository));
    Get.put(HomeMapController(mapRepository: mapRepository));
  }
}
