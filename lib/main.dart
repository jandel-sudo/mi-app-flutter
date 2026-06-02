import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

const int alarmId = 0;

@pragma('vm:entry-point')
void enviarUbicacion() async {
  try {
    bool servicio = await Geolocator.isLocationServiceEnabled();
    if (!servicio) {
      print("GPS apagado");
      return;
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied || permiso == LocationPermission.deniedForever) {
      print("Sin permisos de ubicación");
      return;
    }

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
    
    String fecha = DateTime.now().toString().substring(0, 19);
    String link = "https://www.google.com/maps?q=${pos.latitude},${pos.longitude}";
    String mensaje = "Ubicación Jandel $fecha: $link";
    
    print(mensaje);

  } catch (e) {
    print("Error al enviar ubicación: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitor Jandel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String estado = "Presiona INICIAR";
  bool corriendo = false;

  @override
  void initState() {
    super.initState();
    pedirPermisos();
  }

  Future<void> pedirPermisos() async {
    await Permission.location.request();
    await Permission.locationAlways.request();
    await Permission.notification.request();
    await Permission.ignoreBatteryOptimizations.request();
  }

  void iniciarMonitoreo() async {
    await AndroidAlarmManager.periodic(
      const Duration(minutes: 5),
      alarmId,
      enviarUbicacion,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
    
    setState(() {
      estado = "MONITOREANDO CADA 5 MIN";
      corriendo = true;
    });
    
    enviarUbicacion();
  }

  void detenerMonitoreo() async {
    await AndroidAlarmManager.cancel(alarmId);
    setState(() {
      estado = "DETENIDO";
      corriendo = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        title: const Text('Monitor Jandel', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              corriendo? Icons.gps_fixed : Icons.gps_off,
              size: 100,
              color: corriendo? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              estado,
              style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: corriendo? Colors.grey : Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              onPressed: corriendo? null : iniciarMonitoreo,
              child: const Text('INICIAR', style: TextStyle(fontSize: 24, color: Colors.white)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: corriendo? Colors.orange : Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              onPressed: corriendo? detenerMonitoreo : null,
              child: const Text('DETENER', style: TextStyle(fontSize: 24, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}