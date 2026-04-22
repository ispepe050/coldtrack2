import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SensoresScreen extends StatefulWidget {
  const SensoresScreen({super.key});

  @override
  State<SensoresScreen> createState() => _SensoresScreenState();
}

class _SensoresScreenState extends State<SensoresScreen> {
  final DatabaseReference _sensoresRef = FirebaseDatabase.instance
      .ref()
      .child('sensores')
      .child('refrigerador')
      .child('lecturas');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<DatabaseEvent>(
        stream: _sensoresRef.orderByChild('Timestamp').limitToLast(50).onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar datos: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.snapshot.value == null ||
              (snapshot.data!.snapshot.value as Map?)?.isEmpty == true) {
            return const Center(
              child: Text(
                'No hay lecturas registradas aún.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final dataMap =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final lecturasList = dataMap.entries.toList()
            ..sort((a, b) {
              // Orden descendente por Timestamp (más reciente primero)
              final tsA = (a.value as Map)['Timestamp']?.toString() ?? '';
              final tsB = (b.value as Map)['Timestamp']?.toString() ?? '';
              return tsB.compareTo(tsA);
            });

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: lecturasList.length,
            itemBuilder: (context, index) {
              final entry = lecturasList[index];
              final id = entry.key as String;
              final d = entry.value as Map<dynamic, dynamic>;

              final compressor = d['CompressorStatus']?.toString() ?? 'N/A';
              final consumo = d['ConsumoElectrico']?.toString() ?? 'N/A';
              final door = d['DoorStatus']?.toString() ?? 'N/A';
              final inHumid = d['InHumid']?.toString() ?? 'N/A';
              final power = d['PowerStatus']?.toString() ?? 'N/A';
              final vibration = d['Vibration']?.toString() ?? 'N/A';
              final flagMant = d['flag_mantenimiento']?.toString() ?? 'N/A';
              final inTemp = d['inTemp']?.toString() ?? 'N/A';
              final outHumid = d['outHumid']?.toString() ?? 'N/A';
              final outTemp = d['outTemp']?.toString() ?? 'N/A';

              String fecha = 'Sin fecha';
              final tsRaw = d['Timestamp']?.toString();
              if (tsRaw != null && tsRaw.isNotEmpty) {
                try {
                  // Limpieza y parseo robusto del timestamp
                  final cleaned = tsRaw
                      .replaceAll(RegExp(r'^[A-Za-z]+ '), '')
                      .trim();
                  final date = DateFormat(
                    'dd.MM.yyyy -- HH:mm:ss',
                  ).parse(cleaned);
                  fecha = DateFormat('dd/MM/yyyy HH:mm').format(date);
                } catch (e) {
                  fecha = tsRaw; // fallback: mostrar el string original
                }
              }

              final doorColor = door == 'DoorCLOSED'
                  ? Colors.green
                  : Colors.red;
              final compColor = compressor == 'CompressorOFF'
                  ? Colors.blue
                  : Colors.orange;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Lectura $id',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            children: [
                              Chip(
                                label: Text(door.toUpperCase()),
                                backgroundColor: doorColor.withOpacity(0.15),
                                labelStyle: TextStyle(
                                  color: doorColor,
                                  fontSize: 12,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              Chip(
                                label: Text(compressor.toUpperCase()),
                                backgroundColor: compColor.withOpacity(0.15),
                                labelStyle: TextStyle(
                                  color: compColor,
                                  fontSize: 12,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      _InfoRow(Icons.power_settings_new, 'Power Status', power),
                      _InfoRow(
                        Icons.thermostat,
                        'Temp. Interior',
                        '$inTemp °C',
                      ),
                      _InfoRow(
                        Icons.thermostat_outlined,
                        'Temp. Exterior',
                        '$outTemp °C',
                      ),
                      _InfoRow(Icons.water_drop, 'Hum. Interior', '$inHumid %'),
                      _InfoRow(
                        Icons.water_drop_outlined,
                        'Hum. Exterior',
                        '$outHumid %',
                      ),
                      _InfoRow(Icons.electric_bolt, 'Consumo', '$consumo'),
                      _InfoRow(Icons.vibration, 'Vibración', vibration),
                      _InfoRow(Icons.door_back_door, 'Puerta', door),
                      _InfoRow(Icons.build, 'Mantenimiento', flagMant),
                      const SizedBox(height: 8),
                      Text(
                        'Actualizado: $fecha',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _InfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00ACC1), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
