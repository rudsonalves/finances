import 'dart:developer';
import 'dart:io';

import 'package:finances/packages/ofx/lib/ofx.dart';
import 'package:flutter/material.dart';

import '../../common/models/ofx_account_model.dart';
import '../../common/models/ofx_relationship_model.dart';
import '../../manager/ofx_account_manager.dart';
import '../../manager/ofx_relationship_manager.dart';
import 'ofx_page_state.dart';

class OfxPageController extends ChangeNotifier {
  OfxPageState _state = OfxPageStateInitial();

  final List<OfxAccountModel> _ofxAccounts = [];

  void _changeState(OfxPageState newState) {
    _state = newState;
    notifyListeners();
  }

  OfxPageState get state => _state;
  List<OfxAccountModel> get ofxAccounts => _ofxAccounts;

  Future<void> init() async {
    loadOfxAccounts();
  }

  Future<void> loadOfxAccounts() async {
    try {
      _changeState(OfxPageStateLoading());

      await OfxAccountManager.getAll(_ofxAccounts);

      _changeState(OfxPageStateSuccess());
    } catch (err) {
      log('OfxPageController.loadOfxAccounts: $err');
      _changeState(OfxPageStateError());
    }
  }

  Future<bool> addOfxAccount({
    required OfxAccountModel ofxAccount,
    required OfxRelationshipModel ofxRelation,
  }) async {
    try {
      if (ofxRelation.id == null) {
        // Save a new ofx file relationship between accountID
        // bankAccountId and accountId
        ofxRelation.bankName = ofxAccount.bankName;
        await OfxRelationshipManager.add(ofxRelation);
      } else if (ofxAccount.bankName != ofxRelation.bankName) {
        // update ofxRelationship
        await OfxRelationshipManager.update(ofxRelation);
      }
      // Register ofxAccount file
      ofxAccount.accountId = ofxRelation.accountId;
      final ok = await OfxAccountManager.add(ofxAccount);

      // await OfxAccountManager.getAll(_ofxAccounts);

      return ok;
    } catch (err) {
      log('OfxPageController.addOfxAccount: $err');
      _changeState(OfxPageStateError());
      return false;
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

    return newXml;
  }
}
