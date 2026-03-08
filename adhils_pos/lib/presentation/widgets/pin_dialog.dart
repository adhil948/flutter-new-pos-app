import 'package:flutter/material.dart';

class PinDialog extends StatefulWidget {
  final bool isSetup;

  const PinDialog({super.key, required this.isSetup});

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isSetup ? "Set Reports PIN" : "Enter PIN"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            decoration: const InputDecoration(
              labelText: "PIN (4 digits)",
              border: OutlineInputBorder(),
            ),
          ),
          if (widget.isSetup) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: "Confirm PIN",
                border: OutlineInputBorder(),
              ),
            ),
          ]
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (widget.isSetup) {
              if (_pinController.text.length == 4 && 
                  _pinController.text == _confirmPinController.text) {
                Navigator.pop(context, _pinController.text);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("PINs must match and be 4 digits.")),
                );
              }
            } else {
              if (_pinController.text.length == 4) {
                Navigator.pop(context, _pinController.text);
              }
            }
          },
          child: const Text("Submit"),
        )
      ],
    );
  }
}
