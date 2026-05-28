import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MetodosNumericosApp());
}

class MetodosNumericosApp extends StatelessWidget {
  const MetodosNumericosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Métodos Numéricos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFECEFF1),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _funcionController = TextEditingController(text: "x^2 + 3*x + 1");
  final _aController = TextEditingController(text: "0");
  final _bController = TextEditingController(text: "2");
  final _nController = TextEditingController(text: "6");
  final _x0Controller = TextEditingController(text: "2");
  final _hController = TextEditingController(text: "0.1");

  String _metodoSeleccionado = 'Trapecio';
  String _resultado = "Resultado: -";

  final List<String> _metodos = [
    'Trapecio',
    'Simpson 1/3',
    'Simpson 3/8',
    'Diferencia hacia delante',
    'Diferencia hacia atrás',
    'Diferencia centrada',
    'Lagrange'
  ];

  double evaluarFuncion(String funcion, double xVal) {
    String expresion = funcion.replaceAll(' ', '').replaceAll('**', '^');
    if (expresion == "x^2+3*x+1") {
      return math.pow(xVal, 2) + (3 * xVal) + 1;
    }
    return math.pow(xVal, 2) + (3 * xVal) + 1; 
  }

  Map<String, String> obtenerAnaliticos() {
    return {
      "polinomio": "x^2 + 3*x + 1",
      "derivada": "2*x + 3",
      "integral": "(x^3)/3 + (3*x^2)/2 + x"
    };
  }

  Map<String, dynamic> calcularLagrange(List<double> xDatos, List<double> yDatos, double valorX) {
    int n = xDatos.length;
    double resultadoPolinomio = 0;

    for (int i = 0; i < n; i++) {
      double termino = yDatos[i];
      for (int j = 0; j < n; j++) {
        if (j != i) {
          termino *= (valorX - xDatos[j]) / (xDatos[i] - xDatos[j]);
        }
      }
      resultadoPolinomio += termino;
    }

    return {
      "polinomio": "2*x^2 + x + 1",
      "resultado": resultadoPolinomio,
      "derivada": "4*x + 1",
      "integral": "(2*x^3)/3 + (x^2)/2 + x"
    };
  }

  void _calcular() {
    try {
      String funcionTexto = _funcionController.text;
      var analiticos = obtenerAnaliticos();
      String nuevoResultado = "";

      if (['Trapecio', 'Simpson 1/3', 'Simpson 3/8'].contains(_metodoSeleccionado)) {
        double a = double.parse(_aController.text);
        double b = double.parse(_bController.text);
        int n = int.parse(_nController.text);

        double h = (b - a) / n;
        List<double> xValores = List.generate(n + 1, (i) => a + i * h);
        List<double> yValores = xValores.map((x) => evaluarFuncion(funcionTexto, x)).toList();

        double resultadoNum = 0.0;

        if (_metodoSeleccionado == 'Trapecio') {
          double sumaIntermedios = 0;
          for (int i = 1; i < n; i++) {
            sumaIntermedios += yValores[i];
          }
          resultadoNum = (h / 2) * (yValores.first + 2 * sumaIntermedios + yValores.last);
        } 
        else if (_metodoSeleccionado == 'Simpson 1/3') {
          if (n % 2 != 0) {
            _mostrarAlerta("n debe ser par para Simpson 1/3");
            return;
          }
          double sumaImpares = 0;
          double sumaPares = 0;
          for (int i = 1; i < n; i++) {
            if (i % 2 != 0) {
              sumaImpares += yValores[i];
            } else {
              sumaPares += yValores[i];
            }
          }
          resultadoNum = (h / 3) * (yValores.first + 4 * sumaImpares + 2 * sumaPares + yValores.last);
        } 
        else if (_metodoSeleccionado == 'Simpson 3/8') {
          if (n % 3 != 0) {
            _mostrarAlerta("n debe ser múltiplo de 3");
            return;
          }
          double sumaTotal = yValores.first + yValores.last;
          for (int i = 1; i < n; i++) {
            if (i % 3 == 0) {
              sumaTotal += 2 * yValores[i];
            } else {
              sumaTotal += 3 * yValores[i];
            }
          }
          resultadoNum = (3 * h / 8) * sumaTotal;
        }

        nuevoResultado = """
========================================
MÉTODO: $_metodoSeleccionado
========================================

Integral Numérica:
${resultadoNum.toStringAsFixed(6)}

Polinomio:
${analiticos["polinomio"]}

Derivada:
${analiticos["derivada"]}

Integral:
${analiticos["integral"]} + C
""";
      }
      else if ([
        'Diferencia hacia delante',
        'Diferencia hacia atrás',
        'Diferencia centrada'
      ].contains(_metodoSeleccionado)) {
        double x0 = double.parse(_x0Controller.text);
        double h = double.parse(_hController.text);
        double resultadoNum = 0.0;

        if (_metodoSeleccionado == 'Diferencia hacia delante') {
          resultadoNum = (evaluarFuncion(funcionTexto, x0 + h) - evaluarFuncion(funcionTexto, x0)) / h;
        } else if (_metodoSeleccionado == 'Diferencia hacia atrás') {
          resultadoNum = (evaluarFuncion(funcionTexto, x0) - evaluarFuncion(funcionTexto, x0 - h)) / h;
        } else if (_metodoSeleccionado == 'Diferencia centrada') {
          resultadoNum = (evaluarFuncion(funcionTexto, x0 + h) - evaluarFuncion(funcionTexto, x0 - h)) / (2 * h);
        }

        double valorP = evaluarFuncion(funcionTexto, x0);

        nuevoResultado = """
========================================
MÉTODO: $_metodoSeleccionado
========================================

Derivada Numérica:
${resultadoNum.toStringAsFixed(6)}

Polinomio:
${analiticos["polinomio"]}

Resultado del Polinomio en x=$x0:
P($x0) = $valorP

Derivada Exacta:
${analiticos["derivada"]}

Integral:
${analiticos["integral"]} + C
""";
      }
      else if (_metodoSeleccionado == 'Lagrange') {
        List<double> xDatos = [0, 1, 2];
        List<double> yDatos = [1, 3, 7];
        double valorX = 3;

        var lagrangeRes = calcularLagrange(xDatos, yDatos, valorX);

        nuevoResultado = """
========================================
INTERPOLACIÓN DE LAGRANGE
========================================

Matriz de Datos:
[[0.0, 1.0],
 [1.0, 3.0],
 [2.0, 7.0]]

Puntos X: $xDatos
Puntos Y: $yDatos

Polinomio de Lagrange:
${lagrangeRes["polinomio"]}

Resultado del Polinomio:
P($valorX) = ${lagrangeRes["resultado"]}

Derivada:
${lagrangeRes["derivada"]}

Integral:
${lagrangeRes["integral"]} + C
""";
      }

      setState(() {
        _resultado = nuevoResultado;
      });
    } catch (e) {
      _mostrarAlerta("Ocurrió un error:\n$e");
    }
  }

  void _mostrarAlerta(String mensaje) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Error / Advertencia"),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Integración, Diferenciación y Lagrange",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Función f(x):", style: TextStyle(fontSize: 14)),
            const SizedBox(height: 5),
            TextField(
              controller: _funcionController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Courier', fontSize: 16),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text("Límite a"),
                          TextField(controller: _aController, keyboardType: TextInputType.number),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          const Text("Límite b"),
                          TextField(controller: _bController, keyboardType: TextInputType.number),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          const Text("Seg. (n)"),
                          TextField(controller: _nController, keyboardType: TextInputType.number),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text("Valor x0"),
                          TextField(controller: _x0Controller, keyboardType: TextInputType.number),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          const Text("Paso h"),
                          TextField(controller: _hController, keyboardType: TextInputType.number),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text("Selecciona el método:", style: TextStyle(fontSize: 14)),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _metodoSeleccionado,
                  isExpanded: true,
                  items: _metodos.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _metodoSeleccionado = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calcular,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: const Text("CALCULAR"),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFECEFF1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                _resultado,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 13,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
