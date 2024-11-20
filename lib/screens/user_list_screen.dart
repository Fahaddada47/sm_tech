import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sm_task/controller/user_controller.dart';
import 'package:sm_task/screens/map_screen.dart';
import 'package:sm_task/service/network_connectivity.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final UserController _userController = Get.find<UserController>();
  final NetworkConnectivityService _networkConnectivityService = Get.find<NetworkConnectivityService>();

  Future<void> _refreshUserList() async {
    if (_networkConnectivityService.isOnline == true) {
      await _userController.fetchUsers(fetchFromApi: true);
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          TextButton(
            onPressed: () {
              Get.to(() => const MapScreen());
            },
            child: const Text("Map",),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUserList,
        child: Obx(() {
          if (_userController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_userController.users.isEmpty) {
            return const Center(
              child: Text('No data available.'),
            );
          }

          return ListView.builder(
            itemCount: _userController.users.length,
            itemBuilder: (context, index) {
              final user = _userController.users[index];
              return ListTile(
                title: Text(user.name ?? 'Unknown'),
                subtitle: Text(user.email ?? 'No email'),
              );
            },
          );
        }),
      ),
    );
  }
}
