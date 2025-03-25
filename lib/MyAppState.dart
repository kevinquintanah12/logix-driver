import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';


class MyAppState extends ChangeNotifier{
  var current = WordPair.random();
  var history = <WordPair>[];
  var token= "";
  var username= "";
  GlobalKey? historyListKey;
  var favorites = <WordPair>[];
  
  final String folio = '';
  final String fechainicio = '';
  final String fechafin =  '';
  final int idOperador = 0;
  final int idtransportista = 0;
  final int idremolque = 0;
  final int iddolly = 0;
  final int idvehiculo = 0;


}