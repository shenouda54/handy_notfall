import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:handy_notfall/screens/search_screen.dart';
import 'data_telpone_screen.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  void _signOut() async {
    await FirebaseAuth.instance.signOut(); // ✅ تسجيل الخروج من Firebase
    // سيتم التحويل تلقائيًا إلى `LoginScreen` بفضل `StreamBuilder` في `main.dart`
  }
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  bool isSearching = false;

  @override
  void dispose() {
    firstNameController.dispose();
    addressController.dispose();
    cityController.dispose();
    phoneController.dispose();
    emailController.dispose();
    postalCodeController.dispose();
    searchController.dispose();
    super.dispose();
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
            onPressed: _signOut, //  تسجيل الخروج عند الضغط
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'Vor- und Nachname *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        // const SizedBox(width: 16),
                        // Expanded(
                        //   child: TextFormField(
                        //     controller: lastNameController,
                        //     decoration: const InputDecoration(
                        //       labelText: 'Last Name *',
                        //       border: OutlineInputBorder(),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: addressController,
                            decoration: const InputDecoration(
                              labelText: 'PLZ & Wohnort  *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        // const SizedBox(width: 16),
                        // Expanded(
                        //   child: TextFormField(
                        //     controller: postalCodeController,
                        //     decoration: const InputDecoration(
                        //       labelText: 'Postal Code *',
                        //       border: OutlineInputBorder(),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: cityController,
                      decoration: const InputDecoration(
                        labelText: 'Straße & Hausnummer *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Telefonnummer  *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: 'E-Mail des Empfängers *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DataTelponeScreen(
                                  firstName: firstNameController.text,
                                  address: addressController.text,
                                  city: cityController.text,
                                  phoneNumber: phoneController.text,
                                  emailAddress: emailController.text,
                                ),
                              ),
                            );
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
