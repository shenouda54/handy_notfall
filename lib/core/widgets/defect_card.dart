import 'package:flutter/material.dart';
import 'package:handy_notfall/core/widgets/custom_input_field.dart';
import 'package:handy_notfall/core/widgets/issue_selection.dart';

// Helper class to manage state for each defect card
class DefectCardState {
  final List<String> selectedIssues = [];
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(text: '1');
}

class DefectCard extends StatefulWidget {
  final int index;
  final DefectCardState cardState;
  final List<String> issueOptions;
  final TextEditingController customIssueController;
  final VoidCallback onDelete;
  final Function(String) onAddIssue;
  final Function(String) onRemoveIssue;
  final bool isLocked;
  final bool showDelete;

  const DefectCard({
    super.key,
    required this.index,
    required this.cardState,
    required this.issueOptions,
    required this.customIssueController,
    required this.onDelete,
    required this.onAddIssue,
    required this.onRemoveIssue,
    this.isLocked = false,
    this.showDelete = true,
  });

  @override
  State<DefectCard> createState() => _DefectCardState();
}

class _DefectCardState extends State<DefectCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Problem ${widget.index + 1}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (widget.showDelete)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: widget.isLocked ? null : widget.onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Issue Selection
            IssueSelection(
              issueOptions: widget.issueOptions,
              selectedIssues: widget.cardState.selectedIssues,
              customIssueController: widget.customIssueController,
              onAddIssue: (issue) {
                if (widget.isLocked) return;
                widget.onAddIssue(issue);
              },
              onRemoveIssue: (issue) {
                if (widget.isLocked) return;
                widget.onRemoveIssue(issue);
              },
              enabled: !widget.isLocked,
            ),
            const SizedBox(height: 12),
            // Price and Quantity in a Row
            Row(
              children: [
                Expanded(
                  child: CustomInputField(
                    controller: widget.cardState.priceController,
                    label: 'Preis *',
                    keyboardType: TextInputType.number,
                    enabled: !widget.isLocked,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomInputField(
                    controller: widget.cardState.quantityController,
                    label: 'Menge *',
                    keyboardType: TextInputType.number,
                    enabled: !widget.isLocked,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
