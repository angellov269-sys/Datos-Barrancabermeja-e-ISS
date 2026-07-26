import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main(List<String> args) {
  runApp(MyFirstApp());
}

class MyFirstApp extends StatelessWidget {
  const MyFirstApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Clima e ISS",
      home: Principal(),
    );
  }
}

// Ancho máximo del contenido, para que en navegadores de escritorio
// la app no se estire y se vea sobredimensionada.
const double ANCHO_MAXIMO_CONTENIDO = 480;

Widget _contenidoLimitado(Widget hijo) {
  return Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: ANCHO_MAXIMO_CONTENIDO),
      child: hijo,
    ),
  );
}

// =====================================================
// WIDGET PRINCIPAL
// =====================================================

class Principal extends StatefulWidget {
  const Principal({Key? key}) : super(key: key);

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  String temperatura = "0";
  String humedad = "0";
  String presion = "0";
  String latitudClima = "0";
  String longitudClima = "0";

  String latitudISS = "0";
  String longitudISS = "0";

  String apiClima =
      "https://api.openweathermap.org/data/2.5/weather?q=Barrancabermeja,co&appid=ab03f85822c986649f50bcd1a1cfb259&units=metric";

  String apiISS = "https://api.wheretheiss.at/v1/satellites/25544";

  Future obtenerClima() async {
    try {
      final respuesta = await http.get(Uri.parse(apiClima));
      final datos = jsonDecode(respuesta.body);
      setState(() {
        temperatura = datos["main"]["temp"].toString();
        humedad = datos["main"]["humidity"].toString();
        presion = datos["main"]["pressure"].toString();
        latitudClima = datos["coord"]["lat"].toString();
        longitudClima = datos["coord"]["lon"].toString();
      });
    } catch (error) {
      print(error);
    }
  }

  Future obtenerISS() async {
    try {
      final respuesta = await http.get(Uri.parse(apiISS));
      final datos = jsonDecode(respuesta.body);
      setState(() {
        latitudISS = datos["latitude"].toString();
        longitudISS = datos["longitude"].toString();
      });
    } catch (error) {
      print(error);
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerClima();
    obtenerISS();
  }

  Widget tarjetaIlustrada(
    String titulo,
    String subtitulo,
    IconData icono,
    List<Color> colores,
    Widget pagina,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => pagina),
        );
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colores,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Icon(icono, size: 48, color: colores[2]),
            SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            Text(
              subtitulo,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F7FA),
      appBar: AppBar(
        title: Text("Clima y órbita en vivo"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: _contenidoLimitado(
        SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              tarjetaIlustrada(
                "Datos meteorológicos",
                "Temperatura, humedad y presión",
                Icons.cloud,
                [Colors.orange.shade100, Colors.white, Colors.orange],
                PaginaClima(
                  temperatura: temperatura,
                  humedad: humedad,
                  presion: presion,
                  latitud: latitudClima,
                  longitud: longitudClima,
                ),
              ),
              tarjetaIlustrada(
                "Ubicación ISS",
                "Latitud y longitud en vivo",
                Icons.satellite_alt,
                [Colors.indigo.shade100, Colors.white, Colors.indigo],
                PaginaISS(latitud: latitudISS, longitud: longitudISS),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// PAGINA CLIMA
// =====================================================

class PaginaClima extends StatelessWidget {
  final String temperatura;
  final String humedad;
  final String presion;
  final String latitud;
  final String longitud;

  const PaginaClima({
    Key? key,
    required this.temperatura,
    required this.humedad,
    required this.presion,
    required this.latitud,
    required this.longitud,
  }) : super(key: key);

  Widget dato(String titulo, String valor, IconData icono) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icono, color: Colors.orange),
        title: Text(titulo),
        subtitle: Text(
          valor,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meteorología de Barrancabermeja"),
        backgroundColor: Colors.orange,
      ),
      body: _contenidoLimitado(
        Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              dato("Temperatura", "$temperatura °C", Icons.thermostat),
              dato("Humedad", "$humedad %", Icons.water_drop),
              dato("Presión", "$presion hPa", Icons.speed),
              dato("Latitud", latitud, Icons.location_on),
              dato("Longitud", longitud, Icons.map),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// PAGINA ISS
// =====================================================

class PaginaISS extends StatelessWidget {
  final String latitud;
  final String longitud;

  const PaginaISS({Key? key, required this.latitud, required this.longitud})
      : super(key: key);

  Widget dato(String titulo, String valor, IconData icono) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icono, color: Colors.indigo),
        title: Text(titulo),
        subtitle: Text(
          valor,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ubicación ISS"),
        backgroundColor: Colors.indigo,
      ),
      body: _contenidoLimitado(
        Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              dato("Latitud ISS", latitud, Icons.public),
              dato("Longitud ISS", longitud, Icons.travel_explore),
            ],
          ),
        ),
      ),
    );
  }
}
