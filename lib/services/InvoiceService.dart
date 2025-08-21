import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:odoosaleapp/models/invoice/InvoiceApiResoponseModel.dart';
import 'package:odoosaleapp/models/invoice/PaymentLineTypeResponseModel.dart';

import '../helpers/SessionManager.dart';

// CartService Class
class InvoiceService {
  final String _baseUrl = SessionManager().baseUrl+'bills/List';
  final String _baseCutomerInvoiceUrl = SessionManager().baseUrl+'b2bsale/BillList';
  final String _getPaymentMethodsUrl = SessionManager().baseUrl+'bills/PaymentLineTypes';
  final String _addpaymentUrl = SessionManager().baseUrl+'bills/addpayment';
  final String _previewUrl = SessionManager().baseUrl+'b2bsale/BillPreview';
  final String _refundUrl = SessionManager().baseUrl+'bills/refund';


  Future<InvoiceApiResponseModel?> fetchInvoices(
      {required String sessionId,required String SearchKey}) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId,"SearchKey":SearchKey}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
          var jsonData = data['Data'];
          final cartData = InvoiceApiResponseModel.fromJson(jsonData);
          return cartData;
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

  Future<InvoiceApiResponseModel?> fetchCustomerInvoices(
      {
        required String sessionId,required String SearchKey,required int customerId
      }
      ) async {
    try {
      final response = await http.post(
        Uri.parse(_baseCutomerInvoiceUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId,"SearchKey":SearchKey,"CustomerId":customerId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
          var jsonData = data['Data'];
          final cartData = InvoiceApiResponseModel.fromJson(jsonData);
          return cartData;
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

  Future<PaymentLineTypeResponseModel?> fetchPaymentMethods(
      {required String sessionId}) async {
    try {
      final response = await http.post(
        Uri.parse(_getPaymentMethodsUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
          var jsonData = data['Data'];
          final lineData = PaymentLineTypeResponseModel.fromJson(jsonData);
          return lineData;
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

  Future<bool> addPayment(
      {required String sessionId,required int invoiceId,required int paymentType, required double amount}) async {
    try {
      final response = await http.post(
        Uri.parse(_addpaymentUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId,'invoiceId': invoiceId,'paymentType': paymentType,'amount': amount}),
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

  Future<String?> preview(
      {required String sessionId,required int invoiceId}) async {
    try {
      final response = await http.post(
        Uri.parse(_previewUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId,'invoiceId': invoiceId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Control'] == 1) {
          var pdfUrl = data['Data']['pdfUrl'];
          return pdfUrl;
        } else {
          var msg = data['Message'];
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
  Future<bool> refund(
      {required String sessionId,required int invoiceId}) async {
    try {
      final response = await http.post(
        Uri.parse(_refundUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId,'invoiceId': invoiceId}),
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
