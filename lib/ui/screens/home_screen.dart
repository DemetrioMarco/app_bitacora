import 'package:flutter/material.dart';
import 'bitacoras_list.dart';

// dentro de tu build:
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Home')),
    body: const BitacorasListScreen(), // integra aquí
  );
}
