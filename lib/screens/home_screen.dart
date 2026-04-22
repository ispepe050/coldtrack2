import 'package:carnitrack2/screens/alerts_screen.dart';
import 'package:carnitrack2/screens/login_screen.dart';
import 'package:carnitrack2/screens/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carnitrack2/sensores_screen.dart';
import 'package:carnitrack2/models/alert.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Lista de alertas dinámicas
  final List<AppAlert> _alerts = [
    AppAlert(
      id: '1',
      title: 'Puerta abierta',
      subtitle: 'Refrigerador Principal - Abierta por 8 minutos',
      time: 'Hace 12 min',
      priority: 'Alta',
      icon: Icons.door_back_door,
      color: Colors.red,
    ),
    AppAlert(
      id: '2',
      title: 'Temperatura crítica',
      subtitle: 'Congelador Trasero - 6.8°C (fuera de rango)',
      time: 'Hace 25 min',
      priority: 'Crítica',
      icon: Icons.thermostat,
      color: Colors.orange,
    ),
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const DashboardContent(),
      const SensoresScreen(),
      AlertsScreen(alerts: _alerts),

      const SettingsScreen(),
    ];
  }

  int get unreadAlerts => _alerts.where((a) => !a.isRead).length;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Cierra el drawer al seleccionar una opción
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 26, 139, 161),
        foregroundColor: Colors.white,
        elevation: 2,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(),
              child: Image.asset(
                'assets/icon/coldtrack.png',
                height: 86,
                width: 56,
              ),
            ),
            const SizedBox(width: 3), // Reducido para que quede más pegado
            const Text(
              'ColdTrack',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, size: 28),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                  // Punto rojo si hay alertas
                  if (unreadAlerts > 0)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF00ACC1)),
              child: Text(
                'Menú',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              selected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historial'),
              selected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Alertas'),
              selected: _selectedIndex == 2,
              trailing: unreadAlerts > 0
                  ? Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadAlerts.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : null,
              onTap: () => _onItemTapped(2),
            ),

            ExpansionTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ajustes'),
              childrenPadding: const EdgeInsets.only(left: 20),
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Mi Perfil'),
                  onTap: () {
                    Navigator.pop(context); // Cierra el drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    Navigator.pop(context); // Cierra el drawer
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
    );
  }
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  final List<Map<String, dynamic>> mockRefrigeradores = const [
    {
      'nombre': 'Refrigerador Principal',
      'tempInterior': '4.7',
      'consumo': '38.14',
      'mantenimiento': '0',
      'puerta': 'CLOSED',
      'compresor': 'OFF',
      'power': 'ON',
      'color': Colors.green,
    },
    {
      'nombre': 'Congelador Trasero',
      'tempInterior': '1.8',
      'consumo': '127.8',
      'mantenimiento': '0',
      'puerta': 'OPEN',
      'compresor': 'ON',
      'power': 'ON',
      'color': Colors.orange,
    },
    {
      'nombre': 'Cámara Maduración 1',
      'tempInterior': '-14.0',
      'consumo': '65.2',
      'mantenimiento': '1',
      'puerta': 'CLOSED',
      'compresor': 'OFF',
      'power': 'ON',
      'color': Colors.blueGrey,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mis Refrigeradores',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.65, // Ajustado para evitar overflow vertical
            ),
            itemCount: mockRefrigeradores.length,
            itemBuilder: (context, index) {
              final refri = mockRefrigeradores[index];
              final temp = double.tryParse(refri['tempInterior']) ?? 0.0;
              final estadoColor = temp >= 0 && temp <= 4
                  ? Colors.green
                  : temp > 4
                  ? Colors.red
                  : Colors.blue;

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    12,
                    12,
                    12,
                    8,
                  ), // menos padding inferior
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        refri['nombre'],
                        style: const TextStyle(
                          fontSize: 13.5, // reducido para nombres largos
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        // ← evita que la temperatura desborde
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${refri['tempInterior']}°C',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: estadoColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Consumo: ${refri['consumo']}',
                        style: const TextStyle(fontSize: 12.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Mantto: ${refri['mantenimiento']}',
                        style: const TextStyle(fontSize: 12.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            Icons.door_back_door,
                            color: refri['puerta'] == 'CLOSED'
                                ? Colors.green
                                : Colors.red,
                            size: 22,
                          ),
                          Icon(
                            Icons.settings,
                            color: refri['compresor'] == 'OFF'
                                ? Colors.blue
                                : Colors.orange,
                            size: 22,
                          ),
                          Icon(
                            Icons.power_settings_new,
                            color: refri['power'] == 'ON'
                                ? Colors.green
                                : Colors.red,
                            size: 22,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Gráfico',
                              style: TextStyle(fontSize: 11.5),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Config',
                              style: TextStyle(fontSize: 11.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 100), // espacio final para scroll cómodo
        ],
      ),
    );
  }
}
