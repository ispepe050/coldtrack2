import 'package:flutter/material.dart';

class AppAlert {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final String priority; // 'Alta', 'Media', 'Baja'
  final IconData icon;
  final Color color;
  bool isRead;

  AppAlert({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.priority,
    required this.icon,
    required this.color,
    this.isRead = false,
  });
}