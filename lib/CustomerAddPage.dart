import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:odoosaleapp/services/CustomerService.dart';
import 'package:odoosaleapp/theme.dart';

import 'helpers/SessionManager.dart';
import 'models/customer/CountryResponseModel.dart';
//import 'package:fluttertoast/fluttertoast.dart';

class CustomerAddPage extends StatefulWidget {
  const CustomerAddPage({super.key});

  @override
  State<CustomerAddPage> createState() => _CustomerAddPageState();
}

class _CustomerAddPageState extends State<CustomerAddPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController btwController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController languageController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  List<CountryResponseModel> countryList = [];
  CountryResponseModel? selectedCountry;
  late Future<List<CountryResponseModel>?> dropListFuture = Future.value([]);
  bool isLoading = false;

  String? validateCompanyName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Company Name required';
    }
    return null;
  }
  String _getSessionId() {
    return SessionManager().sessionId ?? "";
  }

  Future<List<CountryResponseModel>?> _fetchCountryList(String query) async {
    try {
      String sessionId = _getSessionId(); // Oturum ID'sini al
      return await CustomerService().fetchCountryList(sessionId: sessionId,searchKey: query);
    } catch (e) {
      print("Ülkeler getirilirken hata: $e");
      return null;
    }
  }


  Future<void> checkBTW() async {
    String btw = btwController.text;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(btw)),
    );
  //  String sessionId = "session_id_degeri"; // SessionId buraya eklenmeli

    if (btw.isEmpty) return;

    try {
      var res = await CustomerService().btwControl(sessionId: _getSessionId(),btw: btw);

      if (res !=null) {
        var data = res;
        setState(() {
          companyNameController.text = data['CompanyName'] ?? '';
          addressController.text = data['Address'] ?? '';
          cityController.text = data['City'] ?? '';
          postalCodeController.text = data['PostCode'] ?? '';
        });
      //  Fluttertoast.showToast(msg: "Bilgiler başarıyla yüklendi.");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(btw + ' not found.')),
        );
      }
    } catch (e) {
     // Fluttertoast.showToast(msg: "Bağlantı hatası: $e");
    }
  }

  Future<void> handleSave() async {
    if (_formKey.currentState!.validate()) {

      setState(() {
        isLoading = true;
      });

      var res = await CustomerService().add(sessionId: _getSessionId(),
          BtwNumber: btwController.text,
          CompanyName: companyNameController.text,
          Language: languageController.text,
          Email: emailController.text,
          Address: addressController.text,
          City: cityController.text,
          PostCode: postalCodeController.text,
          PhoneNumber: phoneController.text,
          CountryId: selectedCountry != null ? selectedCountry!.id : 0
      );
      setState(() {
        isLoading = false;
      });
      if(res)
        {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Customer added successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          await Future.delayed(const Duration(seconds: 2));
          Navigator.pop(context); // Önceki sayfaya dön
        }
      else
        {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(' An error occured')),
          );
        }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Customer'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(children: [
                  Expanded(child:  TextFormField(
                    controller: btwController,
                    decoration: const InputDecoration(labelText: 'BTW'),
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus(); // Klavyeyi kapatır
                      checkBTW();
                    },
                  ),),

                  ElevatedButton(
                    onPressed: () {
                      checkBTW();
                    },
                    style: AppButtonStyles.confimButton,
                    child: const Center(
                      child: Text(
                        'Control',
                        style: AppTextStyles.buttonTextWhite,
                      ),
                    ),
                  ),
                ]
                ),
                FutureBuilder<List<CountryResponseModel>?>(
                  future: dropListFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final dropList = snapshot;
                    if (dropList == null || !dropList.hasData) {
                      return const Center(
                          child: Text('No customers available.'));
                    }

                    return DropdownSearch<CountryResponseModel>(
                      selectedItem: selectedCountry,
                      popupProps: PopupProps.dialog(
                        showSearchBox: true, // Arama kutusunu gösterir
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            labelText: "Search Customer",
                            hintText: "Type to search",
                          ),
                        ),
                      ),
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: "Select Country",
                          hintText: "Search Country",
                        ),
                      ),
                      asyncItems: (String filter) async {
                        // Filtreyi kullanarak veriyi dinamik olarak çek
                        final filteredList = await _fetchCountryList(filter);
                        return filteredList!;
                      },
                      itemAsString: (CountryResponseModel customer) => customer.countryName,
                      onChanged: (value) {
                        setState(() {
                         // selectedMethodId = value != null ? value!.id : 0;
                          selectedCountry = value;
                        });
                      },
                    );
                  },
                ),

                TextFormField(
                  controller: countryController,
                  decoration: const InputDecoration(labelText: 'Country'),
                ),
                TextFormField(
                  controller: languageController,
                  decoration: const InputDecoration(labelText: 'Language'),
                ),
                TextFormField(
                  controller: companyNameController,
                  decoration: const InputDecoration(labelText: 'Company Name'),
                  validator: validateCompanyName,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                TextFormField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
                TextFormField(
                  controller: streetController,
                  decoration: const InputDecoration(labelText: 'Street'),
                ),
                TextFormField(
                  controller: postalCodeController,
                  decoration: const InputDecoration(labelText: 'Postal Code'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : handleSave, // Butonu devre dışı bırak
                    child: isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white, // Yüklenme animasyonu rengi
                        strokeWidth: 2,
                      ),
                    )
                        : const Text('Save', style: AppTextStyles.buttonTextWhite),
                    style: AppButtonStyles.primaryButton,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
