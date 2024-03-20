import 'dart:convert';

import 'package:xml2json/xml2json.dart';

/// A sealed class responsible for converting XML data to a JSON-like map.
///
/// This class uses the `Xml2Json` library to parse XML strings and convert them
/// into a map structure that can be easily manipulated in Dart. The conversion
/// process relies on the Parker convention, which is a specific way of
/// converting XML data into JSON format. The class provides a single static
/// method `adapter` that performs this conversion.
///
/// Usage:
/// The `adapter` method is designed to be used statically and takes an XML
/// string as input. It parses the XML data and returns a map that represents
/// the JSON-like structure of the original XML content. This map can then be
/// used for further processing or data extraction in Dart.
///
/// Example:
/// ```dart
/// String xmlData = "<note><to>Tove</to><from>Jani</from></note>";
/// Map<String, dynamic> jsonData = XmlToJsonAdapter.adapter(xmlData);
/// print(jsonData); // Output: {"note": {"to": "Tove", "from": "Jani"}}
/// ```
///
/// Limitations:
/// - The class is sealed, meaning it cannot be instantiated or extended. It is
///   intended solely for the purpose of XML to JSON conversion.
/// - The conversion might not handle all XML structures, especially those with
///   complex attributes or nested elements. It is optimized for straightforward
///   XML data.
///
/// Note:
/// The `Xml2Json` library must be included in the project dependencies to use
/// this adapter. It is a third-party library that facilitates the parsing and
/// conversion process.
sealed class XmlToJsonAdapter {
  /// Converts an XML string to a JSON-like map structure using the Xml2Json
  /// library.
  ///
  /// Parameters:
  ///   - xml: A string containing the XML data to be converted.
  ///
  /// Returns a map representing the JSON-like structure derived from the XML
  /// data. This map can be used for further data processing or extraction.
  ///
  /// Throws:
  ///   - Exception if the XML parsing or conversion process fails. This ensures
  ///     that any issues during the conversion are reported back to the caller.
  static Map<String, dynamic> adapter(String xml) {
    var xmlParser = Xml2Json();
    xmlParser.parse(xml);
    return json.decode(xmlParser.toParker());
  }
}
