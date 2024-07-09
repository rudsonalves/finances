// Copyright (C) 2024 rudson
//
// This file is part of finances.
//
// finances is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// finances is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances. If not, see <https://www.gnu.org/licenses/>.

import 'dart:convert';

import 'package:finances/packages/ofx/lib/src/adapter/date_time_adapter.dart';
import 'package:finances/packages/ofx/lib/src/adapter/xml_to_json_adapter.dart';
import 'package:finances/packages/ofx/lib/src/models/ofx_financial_institution.dart';
import 'package:finances/packages/ofx/lib/src/models/ofx_status.dart';
import 'package:finances/packages/ofx/lib/src/models/ofx_transaction.dart';

/// Represents financial data in Open Financial Exchange (OFX) format.
///
/// This class encapsulates the various components of OFX data, including
/// transaction details, account information, and financial institution
/// data. It provides methods to serialize and deserialize OFX data from
/// and to both JSON and XML formats, supporting integration with different
/// data sources and services.
class Ofx {
  final OfxStatus statusOfx;
  final DateTime server;
  final DateTime serverLocal;
  final String language;
  final OfxFinancialInstitution financialInstitution;
  final String transactionUniqueID;
  final OfxStatus statusTransaction;
  final String currency;
  final String bankID;
  final String accountID;
  final String accountType;
  final DateTime start;
  final DateTime startLocal;
  final DateTime end;
  final DateTime endLocal;
  final List<OfxTransaction> transactions;

  /// Represents an Open Financial Exchange (OFX) data structure.
  ///
  /// The OFX format is used for electronic exchange of financial information
  /// between institutions, clients, and personal financial management software.
  /// This class encapsulates various details of an OFX response, including
  /// status, server times, transaction details, and more.
  ///
  /// Parameters:
  /// - `statusOfx`: The overall status of the OFX response, indicating success
  ///   or specific types of failures.
  /// - `server`: The timestamp provided by the server, representing the time of
  ///   the response in UTC.
  /// - `serverLocal`: The server timestamp adjusted to the local timezone, to
  ///   facilitate easier understanding and processing of the date/time values.
  /// - `language`: The language of the OFX response, usually as per the
  ///   preferences set in the user's financial software or by the financial
  ///   institution.
  /// - `financialInstitution`: Detailed information about the financial
  ///   institution that issued the OFX response, including its name, ID, and
  ///   other identifiers.
  /// - `transactionUniqueID`: A unique identifier for this set of transactions
  ///   or financial statement, ensuring the ability to differentiate between
  ///   different statements or responses.
  /// - `statusTransaction`: The status of the transaction processing,
  ///   indicating whether transactions were processed successfully or if there
  ///   were issues.
  /// - `currency`: The currency used for the transactions within the OFX
  ///   response, crucial for accurate financial tracking across different
  ///   currencies.
  /// - `bankID`: The identifier for the bank, specific to the financial
  ///   institution's system, often required for transactions and inquiries.
  /// - `accountID`: The specific account identifier, unique to the user's
  ///   account within the financial institution.
  /// - `accountType`: The type of account, such as checking, savings, credit
  ///   card, investment, etc.
  /// - `start` and `startLocal`: The start date of the statement period,
  ///   provided both in UTC and adjusted to the local timezone.
  /// - `end` and `endLocal`: The end date of the statement period, also
  ///   provided in both UTC and the local timezone format.
  /// - `transactions`: A list of individual transaction details included in the
  ///   statement, each containing various pieces of transaction-specific
  ///   information.
  ///
  /// Usage:
  /// This class is typically instantiated with data parsed from an OFX file or
  /// response string. The various fields provide a comprehensive overview of
  /// the financial data communicated in the OFX format.
  Ofx({
    required this.statusOfx,
    required this.server,
    required this.serverLocal,
    required this.language,
    required this.financialInstitution,
    required this.transactionUniqueID,
    required this.statusTransaction,
    required this.currency,
    required this.bankID,
    required this.accountID,
    required this.accountType,
    required this.start,
    required this.startLocal,
    required this.end,
    required this.endLocal,
    required this.transactions,
  });

  /// Creates a copy of this `Ofx` instance with modified fields.
  ///
  /// This method allows for creating a new `Ofx` instance that is identical to
  /// the current one, except for the fields that are explicitly provided with
  /// new values. Any field not provided will retain its value from the current
  /// `Ofx` instance.
  ///
  /// Parameters:
  /// - `statusOfx`: Optionally, the new status of the OFX response.
  /// - `server`: Optionally, the new server timestamp in UTC.
  /// - `serverLocal`: Optionally, the new server timestamp adjusted for local
  ///   timezone.
  /// - `language`: Optionally, the new language of the OFX response.
  /// - `financialInstitution`: Optionally, new information about the financial
  ///   institution.
  /// - `transactionUniqueID`: Optionally, the new unique identifier for the
  ///   transaction.
  /// - `statusTransaction`: Optionally, the new status of the transaction.
  /// - `currency`: Optionally, the new currency of the account.
  /// - `bankID`: Optionally, the new bank ID.
  /// - `accountID`: Optionally, the new account ID.
  /// - `accountType`: Optionally, the new account type.
  /// - `start` and `startLocal`: Optionally, the new start date of the
  ///   statement period, both in UTC and local timezone.
  /// - `end` and `endLocal`: Optionally, the new end date of the statement
  ///   period, both in UTC and local timezone.
  /// - `transactions`: Optionally, the new list of transactions in the
  ///   statement.
  ///
  /// Returns a new `Ofx` instance with updated values for the specified fields.
  ///
  /// Example:
  /// ```dart
  /// Ofx newOfx = ofx.copyWith(language: "EN", currency: "USD");
  /// ```
  Ofx copyWith({
    OfxStatus? statusOfx,
    DateTime? server,
    DateTime? serverLocal,
    String? language,
    OfxFinancialInstitution? financialInstitution,
    String? transactionUniqueID,
    OfxStatus? statusTransaction,
    String? currency,
    String? bankID,
    String? accountID,
    String? accountType,
    DateTime? start,
    DateTime? startLocal,
    DateTime? end,
    DateTime? endLocal,
    List<OfxTransaction>? transactions,
  }) {
    return Ofx(
      statusOfx: statusOfx ?? this.statusOfx,
      server: server ?? this.server,
      serverLocal: serverLocal ?? this.serverLocal,
      language: language ?? this.language,
      financialInstitution: financialInstitution ?? this.financialInstitution,
      transactionUniqueID: transactionUniqueID ?? this.transactionUniqueID,
      statusTransaction: statusTransaction ?? this.statusTransaction,
      currency: currency ?? this.currency,
      bankID: bankID ?? this.bankID,
      accountID: accountID ?? this.accountID,
      accountType: accountType ?? this.accountType,
      start: start ?? this.start,
      startLocal: startLocal ?? this.startLocal,
      end: end ?? this.end,
      endLocal: endLocal ?? this.endLocal,
      transactions: transactions ?? this.transactions,
    );
  }

  /// Converts an `Ofx` instance into a map of key/value pairs.
  ///
  /// This method serializes the `Ofx` instance into a `Map<String, dynamic>`,
  /// suitable for JSON encoding, database storage, or other forms of
  /// serialization where `Ofx` needs to be represented as a collection of
  /// key/value pairs.
  ///
  /// The `toMap` method includes all fields present in the `Ofx` instance,
  /// converting complex objects to maps themselves, and dates to their
  /// millisecond epoch representation for consistency in serialization.
  ///
  /// Returns:
  /// A map representation of the `Ofx` instance, with keys corresponding to the
  /// property names and values formatted as described.
  ///
  /// Example usage:
  /// ```dart
  /// Map<String, dynamic> ofxMap = ofx.toMap();
  /// ```
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status_ofx': statusOfx.toMap(),
      'server': server.millisecondsSinceEpoch,
      'server_local': serverLocal.millisecondsSinceEpoch,
      'language': language,
      'financial_institution': financialInstitution.toMap(),
      'transaction_unique_id': transactionUniqueID,
      'status_transaction': statusTransaction.toMap(),
      'currency': currency,
      'bank_id': bankID,
      'account_id': accountID,
      'account_type': accountType,
      'start': start.millisecondsSinceEpoch,
      'start_local': startLocal.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
      'end_local': endLocal.millisecondsSinceEpoch,
      'transactions': transactions.map((x) => x.toMap()).toList(),
    };
  }

  /// Constructs an `Ofx` object from an OFX format XML string.
  ///
  /// This factory constructor parses an XML string representing OFX (Open
  /// Financial Exchange) data and extracts relevant information to instantiate
  /// an `Ofx` object. It leverages the `XmlToJsonAdapter` to convert XML to a
  /// Map, and then extracts and converts data for each field of the `Ofx`
  /// class.
  ///
  /// Parameters:
  /// - `xml`: A string containing the XML data in OFX format.
  ///
  /// Returns:
  /// - An instance of `Ofx` populated with data extracted from the provided XML
  ///   string.
  ///
  /// Usage:
  /// Given an OFX format XML string, this method allows for easy creation of an
  /// `Ofx` object without manually parsing the XML. This can be particularly
  /// useful when dealing with financial data exchanged in the OFX format.
  ///
  /// Example:
  /// ```dart
  /// String ofxXmlString = "..."; // Your OFX XML data as a string
  /// Ofx ofx = Ofx.fromString(ofxXmlString);
  /// ```
  ///
  /// Note:
  /// The XML string must conform to the OFX standard, including specific tags
  /// and structures. Incorrect or malformed XML may result in incomplete or
  /// incorrect data being loaded into the `Ofx` object.
  factory Ofx.fromString(String xml) {
    final map = XmlToJsonAdapter.adapter(xml);
    final Map<String, dynamic> ofx = map['OFX'];

    if (ofx.containsKey('BANKMSGSRSV1')) {
      return _processBankAccountOfx(ofx);
    } else if (ofx.containsKey('CREDITCARDMSGSRSV1')) {
      return _processCreditCardOfx(ofx);
    } else {
      throw Exception('Tipo de OFX não suportado.');
    }
  }

  /// Constructs an `Ofx` object from an Credit Card OFX format XML string.
  ///
  /// This factory constructor parses an XML string representing OFX (Open
  /// Financial Exchange) data and extracts relevant information to instantiate
  /// an `Ofx` object. It leverages the `XmlToJsonAdapter` to convert XML to a
  /// Map, and then extracts and converts data for each field of the `Ofx`
  /// class.
  ///
  /// Parameters:
  /// - `xml`: A string containing the XML data in OFX format.
  ///
  /// Returns:
  /// - An instance of `Ofx` populated with data extracted from the provided XML
  ///   string.
  ///
  /// Note:
  /// The XML string must conform to the OFX standard, including specific tags
  /// and structures. Incorrect or malformed XML may result in incomplete or
  /// incorrect data being loaded into the `Ofx` object.
  static Ofx _processCreditCardOfx(Map<String, dynamic> ofx) {
    var signon = ofx['SIGNONMSGSRSV1']['SONRS'];
    var statement = ofx['CREDITCARDMSGSRSV1']['CCSTMTTRNRS'];
    var statementTransaction = statement['CCSTMTRS'];
    var bank = statementTransaction['CCACCTFROM'];
    var bankTransactions = statementTransaction['BANKTRANLIST'];

    return Ofx(
      statusOfx: OfxStatus.fromMapOfx(
        signon['STATUS'] as Map<String, dynamic>,
      ),
      server: DateTimeAdapter.stringToDateTime(signon['DTSERVER']),
      serverLocal: DateTimeAdapter.stringDateTimeInTimeZoneLocal(
        signon['DTSERVER'],
      ),
      language: signon['LANGUAGE'].toString(),
      financialInstitution: signon.containsKey('FI')
          ? OfxFinancialInstitution.fromMapOfx(signon['FI'])
          : OfxFinancialInstitution(
              organization: '***',
              financialInstitutionID: '****',
            ),
      transactionUniqueID: statement['TRNUID'].toString(),
      statusTransaction: OfxStatus.fromMapOfx(
        statement['STATUS'] as Map<String, dynamic>,
      ),
      currency: statementTransaction['CURDEF'].toString(),
      bankID: bank['BANKID'].toString(),
      accountID: bank['ACCTID'].toString(),
      accountType:
          bank['ACCTTYPE'] != null ? bank['ACCTTYPE'].toString() : 'CREDITLINE',
      start: DateTimeAdapter.stringToDateTime(bankTransactions['DTSTART']),
      startLocal: DateTimeAdapter.stringDateTimeInTimeZoneLocal(
          bankTransactions['DTSTART']),
      end: DateTimeAdapter.stringToDateTime(bankTransactions['DTEND']),
      endLocal: DateTimeAdapter.stringDateTimeInTimeZoneLocal(
          bankTransactions['DTEND']),
      transactions: List<OfxTransaction>.from(
        (bankTransactions['STMTTRN'] as List<dynamic>).map<OfxTransaction>(
          (x) => OfxTransaction.fromMapOfx(x),
        ),
      ),
    );
  }

  /// Constructs an `Ofx` object from an Bank Account OFX format XML string.
  ///
  /// This factory constructor parses an XML string representing OFX (Open
  /// Financial Exchange) data and extracts relevant information to instantiate
  /// an `Ofx` object. It leverages the `XmlToJsonAdapter` to convert XML to a
  /// Map, and then extracts and converts data for each field of the `Ofx`
  /// class.
  ///
  /// Parameters:
  /// - `xml`: A string containing the XML data in OFX format.
  ///
  /// Returns:
  /// - An instance of `Ofx` populated with data extracted from the provided XML
  ///   string.
  ///
  /// Note:
  /// The XML string must conform to the OFX standard, including specific tags
  /// and structures. Incorrect or malformed XML may result in incomplete or
  /// incorrect data being loaded into the `Ofx` object.
  static Ofx _processBankAccountOfx(Map<String, dynamic> ofx) {
    var signon = ofx['SIGNONMSGSRSV1']['SONRS'];
    var statement = ofx['BANKMSGSRSV1']['STMTTRNRS'];
    var statementTransaction = statement['STMTRS'];
    var bank = statementTransaction['BANKACCTFROM'];
    var bankTransactions = statementTransaction['BANKTRANLIST'];

    return Ofx(
      statusOfx: OfxStatus.fromMapOfx(
        signon['STATUS'] as Map<String, dynamic>,
      ),
      server: DateTimeAdapter.stringToDateTime(signon['DTSERVER']),
      serverLocal: DateTimeAdapter.stringDateTimeInTimeZoneLocal(
        signon['DTSERVER'],
      ),
      language: signon['LANGUAGE'].toString(),
      financialInstitution: signon.containsKey('FI')
          ? OfxFinancialInstitution.fromMapOfx(signon['FI'])
          : OfxFinancialInstitution(
              organization: '***',
              financialInstitutionID: '****',
            ),
      transactionUniqueID: statement['TRNUID'].toString(),
      statusTransaction: OfxStatus.fromMapOfx(
        statement['STATUS'] as Map<String, dynamic>,
      ),
      currency: statementTransaction['CURDEF'].toString(),
      bankID: bank['BANKID'].toString(),
      accountID: bank['ACCTID'].toString(),
      accountType:
          bank['ACCTTYPE'] != null ? bank['ACCTTYPE'].toString() : 'CHECKING',
      start: DateTimeAdapter.stringToDateTime(bankTransactions['DTSTART']),
      startLocal: DateTimeAdapter.stringDateTimeInTimeZoneLocal(
          bankTransactions['DTSTART']),
      end: DateTimeAdapter.stringToDateTime(bankTransactions['DTEND']),
      endLocal: DateTimeAdapter.stringDateTimeInTimeZoneLocal(
          bankTransactions['DTEND']),
      transactions: List<OfxTransaction>.from(
        (bankTransactions['STMTTRN'] as List<dynamic>).map<OfxTransaction>(
          (x) => OfxTransaction.fromMapOfx(x),
        ),
      ),
    );
  }

  /// Creates an `Ofx` instance from a string containing XML data.
  ///
  /// This factory constructor parses an OFX (Open Financial Exchange) XML
  /// string, extracts relevant information, and creates an instance of the
  /// `Ofx` class representing the financial data contained within the XML.
  ///
  /// The parsing process involves converting the XML string to a map structure,
  /// then navigating through the nested elements of the OFX format to extract
  /// information such as sign-on status, server dates, language, financial
  /// institution details, account information, and transaction details.
  ///
  /// Parameters:
  ///   - xml: A string containing the OFX XML data.
  ///
  /// Returns an `Ofx` instance populated with the extracted data, including:
  ///   - Sign-on status and server information.
  ///   - Language of the OFX data.
  ///   - Financial institution details.
  ///   - Account information such as bank ID, account ID, and account type.
  ///   - Transaction list with details for each transaction.
  ///
  /// Throws:
  ///   - Exception if the XML parsing or data extraction fails at any point.
  ///     This ensures that callers are aware of any issues in the OFX data
  ///     format or content that prevent successful parsing.
  ///
  /// Note: The method uses the `XmlToJsonAdapter` for converting XML to a map,
  /// and `DateTimeAdapter` for parsing date strings in the OFX data.
  factory Ofx.fromMap(Map<String, dynamic> map) {
    return Ofx(
      statusOfx:
          OfxStatus.fromMapOfx(map['status_ofx'] as Map<String, dynamic>),
      server: DateTime.fromMillisecondsSinceEpoch(map['server'] as int),
      serverLocal:
          DateTime.fromMillisecondsSinceEpoch(map['server_local'] as int),
      language: map['language'] as String,
      financialInstitution: OfxFinancialInstitution.fromMapOfx(
          map['financial_institution'] as Map<String, dynamic>),
      transactionUniqueID: map['transaction_unique_id'] as String,
      statusTransaction: OfxStatus.fromMapOfx(
          map['status_transaction'] as Map<String, dynamic>),
      currency: map['currency'] as String,
      bankID: map['bank_id'] as String,
      accountID: map['account_id'] as String,
      accountType: map['account_type'] as String,
      start: DateTime.fromMillisecondsSinceEpoch(map['start'] as int),
      startLocal:
          DateTime.fromMillisecondsSinceEpoch(map['start_local'] as int),
      end: DateTime.fromMillisecondsSinceEpoch(map['end'] as int),
      endLocal: DateTime.fromMillisecondsSinceEpoch(map['end_local'] as int),
      transactions: List<OfxTransaction>.from(
        (map['transactions'] as List<dynamic>).map<OfxTransaction>(
          (x) => OfxTransaction.fromMapOfx(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  /// Converts a JSON string into an `Ofx` object.
  ///
  /// This factory constructor decodes a JSON string into a Map, and then
  /// utilizes `Ofx.fromMap` to create an `Ofx` instance. This method
  /// facilitates the instantiation of `Ofx` objects from JSON data, which is
  /// common in web APIs and data exchange processes.
  ///
  /// Parameters:
  /// - `source`: The JSON string containing the serialized `Ofx` data.
  ///
  /// Returns:
  /// - An `Ofx` instance populated with data extracted from the JSON string.
  factory Ofx.fromJson(String source) =>
      Ofx.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Converts the `Ofx` object into a JSON string.
  ///
  /// This method serializes the `Ofx` object into a JSON-formatted string,
  /// making it suitable for storage or data exchange in JSON format.
  ///
  /// Returns:
  /// - A string containing the JSON representation of the `Ofx` object.
  String toJson() => json.encode(toMap());

  /// Returns a string representation of the `Ofx` object.
  ///
  /// This method provides a detailed string representation of the `Ofx` object,
  /// including all its fields. It can be useful for debugging or logging
  /// purposes to quickly inspect the content of an `Ofx` instance.
  ///
  /// Returns:
  /// - A string detailing the contents of the `Ofx` object.
  @override
  String toString() {
    return 'Ofx('
        ' statusOfx: $statusOfx,'
        ' server: $server,'
        ' serverLocal: $serverLocal,'
        ' language: $language,'
        ' financialInstitution: $financialInstitution,'
        ' transactionUniqueID: $transactionUniqueID,'
        ' statusTransaction: $statusTransaction,'
        ' currency: $currency,'
        ' bankID: $bankID,'
        ' accountID: $accountID,'
        ' accountType: $accountType,'
        ' start: $start,'
        ' startLocal: $startLocal,'
        ' end: $end,'
        ' endLocal: $endLocal,'
        ' transactions: $transactions'
        ')';
  }
}
