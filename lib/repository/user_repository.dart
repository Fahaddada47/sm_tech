import 'package:hive/hive.dart';
import 'package:sm_task/interceptor/network_response.dart';
import 'package:sm_task/model/user_model.dart';
import 'package:sm_task/interceptor/network_interceptor.dart';

class UserRepository {
  final String boxName = 'userBox';

  Future<NetworkResponse> fetchUsers({bool fetchFromApi = false}) async {
    final box = await Hive.openBox<UserModel>(boxName);

    final cachedUsers = box.values.toList();
    if (!fetchFromApi && cachedUsers.isNotEmpty) {
      return NetworkResponse.success(cachedUsers, 200);
    }

    const String path = 'https://jsonplaceholder.typicode.com/users';
    try {
      final response = await NetworkCaller.getRequest(path);
      if (response.isSuccess) {
        final List<UserModel> users = (response.data as List)
            .map((user) => UserModel.fromJson(user))
            .toList();

        await box.clear();
        await box.addAll(users);

        return NetworkResponse.success(users, 200);
      } else {
        return NetworkResponse.failure(response.message ?? 'Failed to fetch users');
      }
    } catch (e) {
      return NetworkResponse.failure('Failed to fetch users: $e');
    }
  }
}
