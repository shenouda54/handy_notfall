import 'package:flutter/material.dart';
import 'package:handy_notfall/service/storage_service.dart';

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
            Stack(
              alignment: Alignment.centerRight,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Gerät auswählen',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: 'Forschung über ein Gerät ',// بحث عن نوع جهاز
                      onPressed: () async {
                        final selected = await showDialog<String>(
                          context: context,
                          builder: (context) {
                            String search = '';
                            List<String> filtered = List.from(deviceTypes);
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  title: const Text('Forschung über ein Gerät  '),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        decoration: const InputDecoration(
                                          labelText: 'Forschung', //بحث
                                          prefixIcon: Icon(Icons.search),
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            search = val;
                                            filtered = deviceTypes
                                                .where((e) => e.toLowerCase().contains(search.toLowerCase()))
                                                .toList();
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        height: 200,
                                        width: 300,
                                        child: filtered.isEmpty
                                            ? const Center(child: Text('Es gibt keine Ergebnisse')) //لا يوجد نتائج
                                            : ListView.builder(
                                                itemCount: filtered.length,
                                                itemBuilder: (context, idx) {
                                                  return ListTile(
                                                    title: Text(filtered[idx]),
                                                    trailing: IconButton(
                                                      icon: const Icon(Icons.delete, color: Colors.red),
                                                      tooltip: 'Löschen', //حذف
                                                      onPressed: () async {
                                                        await StorageService.deleteDeviceType(filtered[idx]);
                                                        setState(() {
                                                          deviceTypes.remove(filtered[idx]);
                                                          filtered.removeAt(idx);
                                                        });
                                                      },
                                                    ),
                                                    onTap: () {
                                                      Navigator.of(context).pop(filtered[idx]);
                                                    },
                                                  );
                                                },
                                              ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Abschluss'),//إغلاق
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                        if (selected != null && selected.isNotEmpty) {
                          if (!selectedDeviceTypes.contains(selected)) {
                            onAdd(selected);
                          }
                        }
                      },
                    ),
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
                  menuMaxHeight: 250,
                ),
              ],
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
