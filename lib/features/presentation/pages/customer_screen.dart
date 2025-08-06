import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:handy_notfall/features/domain/entities/customer_entity.dart';
import 'package:handy_notfall/features/domain/usecases/go_to_data_screen_usecase.dart';
import 'package:handy_notfall/features/presentation/pages/search_screen.dart';

import '../../../data/custom_input_field.dart';
import '../../auth/presentation/login/login.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final GoToDataScreenUseCase _goToDataScreenUseCase = GoToDataScreenUseCase();
  bool isSearching = false;

  @override
  void dispose() {
    firstNameController.dispose();
    addressController.dispose();
    cityController.dispose();
    phoneController.dispose();
    emailController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _clearForm() {
    firstNameController.clear();
    addressController.clear();
    cityController.clear();
    phoneController.clear();
    emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: !isSearching
            ? const Text('Kunden Daten')
            : TextField(
          controller: searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            print('Searching for: $value');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Abmelden"),
                  actions: [
                    TextButton(
                      child: const Text("Abmelden"),
                      onPressed: () async {
                        Navigator.pop(context);
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()), // عدل اسم الصفحة حسب تطبيقك
                              (route) => false,
                        );
                        },
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: isSearching
          ? const Center(
        child: Text(
          'Searching...',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomInputField(controller: firstNameController, label: "Vor- und Nachname"),
              CustomInputField(controller:cityController, label: 'Straße & Hausnummer *'),
              CustomInputField(controller:addressController,label: 'PLZ & Wohnort  *'),
              Row(
                children: [
                  Expanded(
                    child:CustomInputField(controller:phoneController,label:  'Telefonnummer  *'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomInputField(controller:emailController,label:  'E-Mail des Empfängers *'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final customer = CustomerEntity(
                        firstName: firstNameController.text,
                        address: addressController.text,
                        city: cityController.text,
                        phoneNumber: phoneController.text,
                        emailAddress: emailController.text,
                      );

                      final result = await _goToDataScreenUseCase(context, customer);
                      if (result == true) {
                        _clearForm();
                        setState(() {});
                      }
                    }
                  },
                  child: const Text('Weiter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
