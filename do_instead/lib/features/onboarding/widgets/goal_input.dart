import 'package:flutter/material.dart';

class GoalInput extends StatefulWidget {
  const GoalInput({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<GoalInput> createState() => _GoalInputState();
}

class _GoalInputState extends State<GoalInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      widget.onChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        labelText: 'e.g., Read a book, exercise...',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }
}
