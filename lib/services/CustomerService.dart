import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:odoosaleapp/models/cart/CartReponseModel.dart';
import 'package:odoosaleapp/models/order/OrderApiResoponseModel.dart';
import 'package:odoosaleapp/models/customer/CustomerApiResponse.dart';

import '../helpers/SessionManager.dart';
import '../models/cart/CustomerDropListModel.dart';
import '../models/customer/CountryResponseModel.dart';
import '../models/customer/CustomersDetailResponseModel.dart';

// CartService Class
class CustomerService {

  final String _baseUrl =
      'https://apiodootest.nametech.be/Api/customers/list';
  final String _detailUrl =
      'https://apiodootest.nametech.be/Api/customers/detail';
  final String _btwControlUrl =
      'https://apiodootest.nametech.be/Api/customers/btwControl';
  final String _countryListUrl =
      'https://apiodootest.nametech.be/Api/customers/GetCountry';
  final String _adorUpdateCustomerUrl =
      'https://apiodootest.nametech.be/Api/customers/Add';

  Future<CustomerApiResponse?> fetchCustomers(
      {required String sessionId,required String searchKey}) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId,'searchKey':searchKey}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
          var jsonData = data['Data'];
          final customerData = CustomerApiResponse.fromJson(jsonData);
          return customerData;
        } else {
          var msg = data['Message'];
          throw Exception(msg);
        }
      } else {
        throw Exception('Failed to load cart data');
      }
    } catch (e) {
      print('Error fetching cart: $e');
      return null;
    }
  }
  Future<dynamic> btwControl(
      {required String sessionId,required String btw}) async {
    try {
      final response = await http.post(
        Uri.parse(_btwControlUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId,'BtwNumber':btw}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
          var jsonData = data['Data'];
        //  final customerData = CustomerApiResponse.fromJson(jsonData);
          return jsonData;
        } else {
          return null;
        }
      } else {
        throw Exception('Failed to load cart data');
      }
    } catch (e) {
      print('Error fetching cart: $e');
      return null;
    }
  }

  Future<CustomersDetailResponseModel?> fetchCustomerDetail(
      {required String sessionId,required int customerId}) async {
    try {
      final response = await http.post(
        Uri.parse(_detailUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId,'Id':customerId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
          var jsonData = data['Data']['CustomerDetail'];
          final customerData = CustomersDetailResponseModel.fromJson(jsonData);
          return customerData;
        } else {
          var msg = data['Message'];
          throw Exception(msg);
        }
      } else {
        throw Exception('Failed to load customer data');
      }
    } catch (e) {
      print('Error fetching customer: $e');
      return null;
    }
  }
  Future<List<CountryResponseModel>?> fetchCountryList({
    required String sessionId,
    String searchKey = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_countryListUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId, 'searchKey': searchKey}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
          var jsonData = data['Data'] as List;
          List<CountryResponseModel> countryList = jsonData
              .map((item) => CountryResponseModel.fromJson(item))
              .toList();
          return countryList;
        } else {
          var msg = data['Message'] ?? 'Hata oluştu.';
          throw Exception(msg);
        }
      } else {
        throw Exception('Ülke bilgileri alınamadı.');
      }
    } catch (e) {
      print('Ülke bilgileri getirilirken hata oluştu: $e');
      return null;
    }
  }
  /*
  * public string SessionId { get; set; }
public string BtwNumber { get; set; }
public string CompanyName { get; set; }
public string Language { get; set; }
public string Email { get; set; }
public string Address { get; set; }
public string City { get; set; }
public string PostCode { get; set; }
public string PhoneNumber { get; set; }
public int CountryId { get; set; } = 20;*/
  Future<bool> add(
      {required String sessionId,
        required String BtwNumber,
        required String CompanyName,
        required String Language,
        required String Email,
        required String Address,
        required String City,
        required String PostCode,
        required String PhoneNumber,
        required int CountryId
      }) async {
    try {
      final response = await http.post(
        Uri.parse(_adorUpdateCustomerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sessionId': sessionId,
          'BtwNumber': BtwNumber,
          'CompanyName': CompanyName,
          'Language': Language,
          'Email': Email,
          'Address': Address,
          'City': City,
          'PostCode': PostCode,
          'PhoneNumber': PhoneNumber,
          'CountryId': CountryId
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
          return true;
        } else {
          var msg = data['Message'];
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
