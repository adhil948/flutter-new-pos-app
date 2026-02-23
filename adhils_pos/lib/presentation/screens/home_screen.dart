import 'package:flutter/material.dart';
import 'products_screen.dart';
import 'new_bill_screen.dart';
import 'reports_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adhils POS'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
children: [
DashboardCard(
  title: "New Bill",
  icon: Icons.receipt_long,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NewBillScreen(),
      ),
    );
  },
),
  DashboardCard(
    title: "Products",
    icon: Icons.inventory,
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ProductsScreen(),
        ),
      );
    },
  ),
DashboardCard(
  title: "Reports",
  icon: Icons.bar_chart,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReportsScreen(),
      ),
    );
  },
),
  DashboardCard(
    title: "Expenses",
    icon: Icons.money,
    onTap: () {},
  ),
],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}