import 'package:flutter/material.dart';
import 'package:handy_notfall/service/storage_service.dart';

class IssueSelection extends StatelessWidget {
  final List<String> issueOptions;
  final List<String> selectedIssues;
  final Function(String) onAddIssue;
  final Function(String) onRemoveIssue;
  final TextEditingController customIssueController;
  final double? menuMaxHeight;

  const IssueSelection({
    super.key,
    required this.issueOptions,
    required this.selectedIssues,
    required this.onAddIssue,
    required this.onRemoveIssue,
    required this.customIssueController,
    this.menuMaxHeight,
    this.enabled = true,
  });

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Fehler',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Stack(
              alignment: Alignment.centerRight,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Problem wählen',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: 'Forschung über ein Gerät ',
                      onPressed: !enabled ? null : () async {
                        final selected = await showDialog<String>(
                          context: context,
                          builder: (context) {
                            String search = '';
                            List<String> filtered = List.from(issueOptions);
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  title: const Text('Forschung über ein Gerät '),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        decoration: const InputDecoration(
                                          labelText: 'Forschung',
                                          prefixIcon: Icon(Icons.search),
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            search = val;
                                            filtered = issueOptions
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
                                            ? const Center(child: Text('Es gibt keine Ergebnisse'))
                                            : ListView.builder(
                                                itemCount: filtered.length,
                                                itemBuilder: (context, idx) {
                                                  return ListTile(
                                                    title: Text(filtered[idx]),
                                                    trailing: IconButton(
                                                      icon: const Icon(Icons.delete, color: Colors.red),
                                                      tooltip: 'Löschen',
                                                      onPressed: () async {
                                                        await StorageService.deleteIssue(filtered[idx]);
                                                        setState(() {
                                                          issueOptions.remove(filtered[idx]);
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
                                      child: const Text('Abschluss'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                        if (selected != null && selected.isNotEmpty) {
                          if (!selectedIssues.contains(selected)) {
                            onAddIssue(selected);
                          }
                        }
                      },
                    ),
                  ),
                  items: issueOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) onAddIssue(val);
                  },
                  menuMaxHeight: menuMaxHeight ?? 250,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: selectedIssues
                  .map((issue) => Chip(
                        label: Text(issue),
                        onDeleted: !enabled ? null : () => onRemoveIssue(issue),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            TextFormField(
              enabled: enabled,
              controller: customIssueController,
              decoration: InputDecoration(
                labelText: 'Weitere Fehler (Optional)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: !enabled ? null : () {
                    if (customIssueController.text.isNotEmpty) {
                      onAddIssue(customIssueController.text);
                      customIssueController.clear();
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
