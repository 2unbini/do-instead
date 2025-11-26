import 'package:do_instead/features/reports/widgets/report_card.dart';
import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Summary'),
      ),
      body: ListView(
        children: const [
          ReportCard(
            title: 'Succeed',
            description: 'Here\'s a summary of your succeed.',
          ),
          ReportCard(
            title: 'Failure',
            description: 'Here\'s a summary of your failure.',
          ),
        ],
      ),
    );
  }
}
