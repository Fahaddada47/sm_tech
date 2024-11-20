
import 'package:sm_task/interceptor/network_interceptor.dart';
import 'package:sm_task/interceptor/network_response.dart';

class MapRepository {
  Future<NetworkResponse> fetchAddress(double latitude, double longitude) async {
    const apiKey = '12344';
    const path =
        'https://barikoi.xyz/v1/api/search/reverse/$apiKey/geocode';
    final queryParams = {
      'latitude': latitude,
      'longitude': longitude,
    };

    return await NetworkCaller.getRequest(path, queryParams: queryParams);
  }
}
