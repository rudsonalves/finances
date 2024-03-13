import 'dart:io';

import 'package:finances/packages/ofx/lib/ofx.dart';
import 'package:flutter/material.dart';

import 'ofx_page_state.dart';

class OfxPageController extends ChangeNotifier {
  OfxPageState _state = OfxPageStateInitial();

  late Ofx? _ofx;
  final List<OfxTransaction> _ofxTransactions = [];

  void _changeState(OfxPageState newState) {
    _state = newState;
    notifyListeners();
  }

  OfxPageState get state => _state;
  Ofx? get ofx => _ofx;
  List<OfxTransaction> get ofxTransactions => _ofx?.transactions ?? [];

  Future<void> loadOfxs(File ofxFile) async {
    try {
      _changeState(OfxPageStateLoading());
      final ofxString = await ofxFile.readAsString();
      _ofx = _parserOfxSXml(ofxString);
      _changeState(OfxPageStateSuccess());
    } catch (err) {
      _ofx = null;
      _ofxTransactions.clear();
      _changeState(OfxPageStateError());
    }
  }

  Future<Ofx?> processOfx(File ofxFile) async {
    try {
      final ofxString = await ofxFile.readAsString();
      final ofx = _parserOfxSXml(ofxString);
      return ofx;
    } catch (err) {
      return null;
    }
  }

  Ofx _parserOfxSXml(String xml) {
    // First try to parser xml
    Ofx? ofx = _attemptParseXml(xml);

    // if the parser fails, try fixing xml and parser again
    if (ofx == null) {
      String fixedXml = _fixingXml(xml);
      ofx = _attemptParseXml(fixedXml);
    }

    if (ofx == null) {
      throw Exception('parseOfxString: Ofx XML can not be fixed.');
    }

    return ofx;
  }

  Ofx? _attemptParseXml(String xml) {
    try {
      final ofx = Ofx.fromString(xml);
      return ofx;
    } catch (err) {
      // log('XML parsing error: $err');
      return null;
    }
  }

  String _fixingXml(String xml) {
    String newXml = '';
    final lines = xml.split('\n');

    final completTag = RegExp(r'^<([a-zA-Z\d]+)>([^<>]+)</([a-zA-Z\d]+)>$');
    final halfTag = RegExp(r'^<([a-zA-Z\d]+)>([^<>]+)$');

    for (final line in lines) {
      final trimLine = line.trim();
      // remove empty lines
      if (trimLine.isEmpty) continue;
      // check complet tags match
      final completMatch = completTag.firstMatch(trimLine);
      if (completMatch != null) {
        if (completMatch.group(1) != completMatch.group(3)) {
          newXml +=
              '<${completMatch.group(1)}>${completMatch.group(2)}</${completMatch.group(1)}>\n';
          newXml += '</${completMatch.group(3)}>\n';
        } else {
          newXml += '$line\n';
        }
        continue;
      }
      // check half tags match
      final halfMatch = halfTag.firstMatch(line);
      if (halfMatch != null) {
        newXml += '$line</${halfMatch.group(1)}>\n';
      } else {
        newXml += '$line\n';
      }
    }

    // RegExp xmlLine = RegExp(r'^<([a-zA-Z\d]+)>([^<>]+)$');

    // for (final line in lines) {
    //   final trimLine = line.trim();
    //   // remove empty lines
    //   if (trimLine.isEmpty) continue;
    //   final match = xmlLine.firstMatch(trimLine);
    //   if (match != null) {
    //     // Fix the line if it finds a match
    //     newXml += '$line</${match.group(1)}>\n';
    //   } else {
    //     // Keeps the line as is if no match is found
    //     newXml += '$line\n';
    //   }
    // }

    return newXml;
  }
}
