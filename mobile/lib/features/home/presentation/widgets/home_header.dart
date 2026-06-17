import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          'Pantau & Prediksi',
          style: Theme.of(
            context,
          ).textTheme.displayLarge?.copyWith(fontSize: 28),
        ),
        Text(
          'Harga bahan pokok hari ini di Indonesia',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
