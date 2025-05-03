import 'package:flutter/material.dart';

class DeviceTypeSelection extends StatelessWidget {
  final List<String> deviceTypes;
  final List<String> selectedDeviceTypes;
  final Function(String) onAdd;
  final Function(String) onRemove;
  final TextEditingController customDeviceController;

  const DeviceTypeSelection({
    super.key,
    required this.deviceTypes,
    required this.selectedDeviceTypes,
    required this.onAdd,
    required this.onRemove,
    required this.customDeviceController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gerätetyp',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Gerät auswählen',
              ),
              items: deviceTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onAdd(val);
              },
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: selectedDeviceTypes.map((type) {
                return Chip(
                  label: Text(type),
                  onDeleted: () => onRemove(type),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: customDeviceController,
              decoration: InputDecoration(
                labelText: 'Weitere Gerätetyp (Optional)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final custom = customDeviceController.text.trim();
                    if (custom.isNotEmpty) {
                      onAdd(custom);
                      customDeviceController.clear();
                    }
                  },
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
