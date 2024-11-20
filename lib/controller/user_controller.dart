import 'package:get/get.dart';
import 'package:sm_task/model/user_model.dart';
import 'package:sm_task/repository/user_repository.dart';

class UserController extends GetxController {
  var users = <UserModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final UserRepository userRepository;

  UserController({required this.userRepository});

  @override
  void onInit() {
    super.onInit();
    fetchUsers(fetchFromApi: false);
  }

  Future<void> fetchUsers({bool fetchFromApi = true}) async {
    isLoading.value = true;
    errorMessage.value = '';

    final response = await userRepository.fetchUsers(fetchFromApi: fetchFromApi);

    if (response.isSuccess) {
      users.value = response.data as List<UserModel>;
    } else {
      errorMessage.value = response.message ?? 'Failed to fetch users';
    }

    isLoading.value = false;
  }
}
