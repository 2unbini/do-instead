import 'package:do_instead/presentation/dashboard/widgets/report_card.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
