import 'package:flutter/material.dart';
import 'package:primeiro_app/pages/home_page.dart';
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

class SegundaPage extends StatefulWidget {
  @override
  const SegundaPage({Key? key}) : super(key: key);
  _SegundaPage createState() => _SegundaPage();
}

Widget _signOutButton() {
  return ElevatedButton(onPressed: signOut, child: const Text('Sair'));
}

class _SegundaPage extends State<SegundaPage> {
  final databaseReference = FirebaseDatabase.instance.ref();
  bool _valorSwitch = false;
  bool _valorSwitch2 = false;
  bool _girash = false;
  bool _girasah = false;

  bool _alterarValor(bool variavel, String path) {
    databaseReference.child(path).set(!variavel);
    return !variavel;
  }

  void initState() {
    super.initState();
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
      body: Column(children: [
        Expanded(
          child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: 30),
              Text(
                'Irrigação: ${_valorSwitch ? 'Ligado' : 'Desligado'}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Switch(
                value: _valorSwitch,
                onChanged: (value) {
                  setState(() {
                    _valorSwitch = _alterarValor(_valorSwitch, '/led/verde');
                  });
                  ;
                },
              ),
              Text(
                'Lâmpada : ${_valorSwitch2 ? 'Ligado' : 'Desligado'}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Switch(
                  value: _valorSwitch2,
                  onChanged: (value2) {
                    setState(() {
                      _valorSwitch2 =
                          _alterarValor(_valorSwitch2, '/led/amarelo');
                    });
                  }),
              const SizedBox(height: 20),
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
                      backgroundColor:
                          MaterialStateProperty.all<Color>(_buttonColor),
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
                      backgroundColor:
                          MaterialStateProperty.all<Color>(_buttonColor),
                      textStyle: MaterialStateProperty.all<TextStyle>(
                        TextStyle(fontSize: 16),
                      ),
                      elevation: MaterialStateProperty.all<double>(10),
                    ),
                    child: Text('Abrir sombreiro'),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _signOutButton()
            ]),
          ),
        ),
      ]),
    );
  }
}
