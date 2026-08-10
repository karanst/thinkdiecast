import 'package:flutter/material.dart';
import 'manage_entity_screen.dart';

class ScaleScreen extends StatelessWidget {
  const ScaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ManageEntityScreen(
      endpoint: '/Scales',
      entityLabel: 'SCALES',
      tag: 'scales',
      hasImage:  false,
    );
  }
}
