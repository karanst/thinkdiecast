import 'package:flutter/material.dart';
import 'manage_entity_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ManageEntityScreen(
      endpoint: '/Categories',
      entityLabel: 'CATEGORIES',
      tag: 'categories',
      hasImage: false,
    );
  }
}
