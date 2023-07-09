import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:primeiro_app/auth.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:primeiro_app/firebase_options.dart';
import 'package:primeiro_app/auth.dart';
import 'package:primeiro_app/widget_tree.dart';
import 'package:primeiro_app/page/Primeira_Page.dart';
import 'package:primeiro_app/page/Segunda_Page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  const HomePage({Key? key}) : super(key: key);
  _HomePageState createState() => _HomePageState();
}

final User? user = Auth().currentUser;

Future<void> signOut() async {
  await Auth().signOut();
}

Widget _title() {
  return const Text('Minha Planta');
}

Widget _userUid() {
  return Text(user?.email ?? 'Email do usuário');
}

Widget _signOutButton() {
  return ElevatedButton(onPressed: signOut, child: const Text('Sair'));
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Containers Clicáveis',
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFc4e3cd)),
      initialRoute: '/',
      routes: {
        '/': (context) => Primeira(),
        '/detail': (context) => DetailPage(),
      },
    );
  }
}

class Primeira extends StatefulWidget {
  @override
  const Primeira({Key? key}) : super(key: key);
  _Primeira createState() => _Primeira();
}

class _Primeira extends State<Primeira> {
  final databaseReference = FirebaseDatabase.instance.ref();
  bool _valorSwitch = false;
  bool _valorSwitch2 = false;
  bool _girash = false;
  bool _girasah = false;
  double _temperatura = 0.0;
  int _humidade = 0;
  int _luminosidade = 0;
  double _solo = 0.0;
  double _valorroda = 0.0;

  void initState() {
    super.initState();
    databaseReference.child('/Umidade').onValue.listen((event) {
      setState(() {
        _humidade = event.snapshot.value as int;
      });
    });
    databaseReference.child('/Luminosidade').onValue.listen((event) {
      setState(() {
        _luminosidade = event.snapshot.value as int;
      });
    });
    databaseReference.child('/Temperatura').onValue.listen((event) {
      setState(() {
        _temperatura = event.snapshot.value as double;
      });
    });
    databaseReference.child('/Umidade do solo').onValue.listen((event) {
      setState(() {
        _solo = event.snapshot.value as double;
        _valorroda = _solo / 100;
      });
    });
    databaseReference.child('/led/verde').onValue.listen((event) {
      setState(() {
        _valorSwitch = event.snapshot.value as bool;
      });
    });
    databaseReference.child('/led/amarelo').onValue.listen((event) {
      setState(() {
        _valorSwitch2 = event.snapshot.value as bool;
      });
    });
  }

  bool _alterarValor(bool variavel, String path) {
    databaseReference.child(path).set(!variavel);
    return !variavel;
  }

  void motor_tempo_horario(bool novoSinal) {
    setState(() {
      _girash = novoSinal;
    });
    databaseReference
        .child('/motor/horario')
        .set(_girash); // Envie o sinal para o Firebase
    Future.delayed(Duration(seconds: 6), () {
      setState(() {
        _girash = !novoSinal; // Volte ao sinal anterior
      });
      databaseReference
          .child('/motor/horario')
          .set(_girash); // Envie o sinal atualizado para o Firebase
    });
  }

  void motor_tempo_antihorario(bool novoSinal2) {
    setState(() {
      _girasah = novoSinal2;
    });
    databaseReference
        .child('/motor/anti')
        .set(_girasah); // Envie o sinal para o Firebase
    Future.delayed(Duration(seconds: 6), () {
      setState(() {
        _girasah = !novoSinal2; // Volte ao sinal anterior
      });
      databaseReference
          .child('/motor/anti')
          .set(_girasah); // Envie o sinal atualizado para o Firebase
    });
  }

  Color _buttonColor = Colors.green;

  void _onButtonPressed() {
    setState(() {
      _buttonColor = Colors.red;
    });
    Timer(Duration(seconds: 15), () {
      setState(() {
        _buttonColor = Colors.green;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/detail',
                  arguments: DetailArguments(
                    title: 'Umidade do solo : $_solo',
                    description:
                        'Irrigação: ${_valorSwitch ? 'Ligado' : 'Desligado'}',
                    color: Color(0xff005eba),
                  ),
                );
              },
              child: Container(
                height: 165.0,
                width: 350.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  gradient: LinearGradient(
                    colors: [Color(0xff128231), Color(0xff44bc5d)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      CircularProgressIndicator(
                        value: _valorroda,
                        strokeWidth: 8,
                        backgroundColor: Colors.white,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF349fdf)),
                      ),
                      SizedBox(height: 30),
                      Text(
                        'Umidade do solo $_solo%',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Irrigação : ${_valorSwitch ? 'Ligado' : 'Desligado'}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                          Switch(
                              value: _valorSwitch,
                              onChanged: (value) {
                                setState(() {
                                  _valorSwitch =
                                      _alterarValor(_valorSwitch, '/led/verde');
                                });
                              }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/detail',
                  arguments: DetailArguments(
                    title: '',
                    description: 'Descrição do Container 2',
                    color: Color(0xffca0d00),
                  ),
                );
              },
              child: Container(
                height: 150.0,
                width: 350.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  gradient: LinearGradient(
                    colors: [Color(0xff001527), Color(0xff005eab)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Text(
                        'Temperatura  $_temperatura°C',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      SizedBox(height: 60),
                      Text(
                        'Umidade Atmosférica $_humidade%',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/detail',
                  arguments: DetailArguments(
                    title: 'Luminosidade: $_luminosidade LUX',
                    description: 'Descrição do Container 3',
                    color: Color(0xffd0bc00),
                  ),
                );
              },
              child: Container(
                height: 180.0,
                width: 350.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  gradient: LinearGradient(
                    colors: [Color(0xff44bc5d), Color(0xff001527)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Text(
                        'Luminosidade: $_luminosidade Lux',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                motor_tempo_horario(!_girash);
                                _onButtonPressed();
                              });
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  _buttonColor),
                              textStyle: MaterialStateProperty.all<TextStyle>(
                                TextStyle(fontSize: 16),
                              ),
                              elevation: MaterialStateProperty.all<double>(10),
                            ),
                            child: Text('Fechar Sombreiro'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                motor_tempo_antihorario(!_girasah);
                                _onButtonPressed();
                              });
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  _buttonColor),
                              textStyle: MaterialStateProperty.all<TextStyle>(
                                TextStyle(fontSize: 16),
                              ),
                              elevation: MaterialStateProperty.all<double>(10),
                            ),
                            child: Text('Abrir sombreiro'),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Lâmpada : ${_valorSwitch2 ? 'Ligado' : 'Desligado'}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                          Switch(
                              value: _valorSwitch2,
                              onChanged: (value2) {
                                setState(() {
                                  _valorSwitch2 = _alterarValor(
                                      _valorSwitch2, '/led/amarelo');
                                });
                              }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _signOutButton()
          ],
        ),
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  @override
  const DetailPage({Key? key}) : super(key: key);
  _DetailPage createState() => _DetailPage();
}

class _DetailPage extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    final DetailArguments arguments =
        ModalRoute.of(context)!.settings.arguments as DetailArguments;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: arguments.color,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                arguments.title,
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                arguments.description,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailArguments {
  final String title;
  final String description;
  final Color color;

  DetailArguments({
    required this.title,
    required this.description,
    required this.color,
  });
}
