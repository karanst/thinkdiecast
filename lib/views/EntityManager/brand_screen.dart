import 'package:flutter/material.dart';
import 'manage_entity_screen.dart';


class BrandScreen extends StatelessWidget {
  const BrandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ManageEntityScreen(
      endpoint: '/Brands',
      entityLabel: 'BRANDS',
      tag: 'brands',
      hasImage: true,
    );
  }
}
