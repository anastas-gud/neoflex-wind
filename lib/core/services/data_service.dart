import 'package:http/http.dart' as http;
import '../constants/strings.dart';

class DataService {
  Future<bool> initializeData() async {
    final response = await http
        .post(Uri.parse('${AppStrings.baseUrl}/data'))
        .timeout(Duration(seconds: 10));
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}
