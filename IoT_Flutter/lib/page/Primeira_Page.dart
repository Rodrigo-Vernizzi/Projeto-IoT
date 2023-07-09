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
import 'package:cloud_firestore/cloud_firestore.dart';

class PrimeiraPage extends StatefulWidget {
  @override
  const PrimeiraPage({Key? key}) : super(key: key);
  _PrimeiraPage createState() => _PrimeiraPage();
}

class _PrimeiraPage extends State<PrimeiraPage> {
  final databaseReference = FirebaseDatabase.instance.ref();
  double _temperatura = 0.0;
  int _humidade = 0;
  int _luminosidade = 0;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Text(
                  'Temperatura: $_temperatura',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 25),
                Text(
                  'Umidade: $_humidade',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 25),
                Text(
                  'Luminosidade: $_luminosidade',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
