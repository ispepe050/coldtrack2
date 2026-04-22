import 'package:carnitrack2/models/alert.dart';
import 'package:flutter/material.dart';

// En AlertsScreen
class AlertsScreen extends StatefulWidget {
  final List<AppAlert> alerts;
  const AlertsScreen({super.key, required this.alerts});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        backgroundColor: const Color(0xFF00ACC1),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.alerts.length,
        itemBuilder: (context, index) {
          final alert = widget.alerts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: alert.color.withOpacity(0.15),
                child: Icon(alert.icon, color: alert.color),
              ),
              title: Text(alert.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(alert.subtitle),
              trailing: Text(alert.time, style: const TextStyle(fontSize: 12)),
              onTap: () {
                setState(() {
                  alert.isRead = true;
                });
                // Mostrar detalle
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(alert.title),
                    content: Text(alert.subtitle),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ignore: unused_element
class _AlertCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final String priority;
  final IconData icon;
  final Color color;

  const _AlertCard({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.priority,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        trailing: Text(
          priority,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        onTap: () {
          // Aquí puedes abrir detalle de la alerta
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(title),
              content: Text(subtitle),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
