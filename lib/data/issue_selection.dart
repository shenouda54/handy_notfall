import 'package:flutter/material.dart';

class IssueSelection extends StatelessWidget {
  final List<String> issueOptions;
  final List<String> selectedIssues;
  final Function(String) onAddIssue;
  final Function(String) onRemoveIssue;
  final TextEditingController customIssueController;

  const IssueSelection({
    super.key,
    required this.issueOptions,
    required this.selectedIssues,
    required this.onAddIssue,
    required this.onRemoveIssue,
    required this.customIssueController,
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
            const Text('Fehler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Problem wählen'),
              items: issueOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) {
                if (val != null) onAddIssue(val);
              },
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: selectedIssues.map((issue) => Chip(
                label: Text(issue),
                onDeleted: () => onRemoveIssue(issue),
              )).toList(),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: customIssueController,
              decoration: InputDecoration(
                labelText: 'Weitere Fehler (Optional)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
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
