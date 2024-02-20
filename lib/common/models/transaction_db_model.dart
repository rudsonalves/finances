import 'dart:convert';

import '../../locator.dart';
import '../../repositories/transaction/abstract_transaction_repository.dart';
import './extends_date.dart';

enum TransStatus {
  transactionNotChecked,
  transactionChecked,
}

class TransactionDbModel {
  int? transId;
  String transDescription;
  int transCategoryId;
  double transValue;
  TransStatus transStatus;
  int? transTransferId;
  ExtendedDate transDate;

  TransactionDbModel({
    this.transId,
    required this.transDescription,
    required this.transCategoryId,
    required this.transValue,
    this.transStatus = TransStatus.transactionNotChecked,
    this.transTransferId,
    required this.transDate,
  });

  bool get ischecked => transStatus == TransStatus.transactionChecked;

  void _toggleStatus() {
    transStatus = transStatus == TransStatus.transactionChecked
        ? TransStatus.transactionNotChecked
        : TransStatus.transactionChecked;
  }

  Future<void> toggleTransStatus() async {
    _toggleStatus();
    await locator
        .get<AbstractTransactionRepository>()
        .updateTransactionStatus(transId!, transStatus);
  }

  static List<TransactionDbModel> listOfTransactions(
      List<Map<String, dynamic>> listMap) {
    List<TransactionDbModel> listTransaction = [];

    for (Map<String, dynamic> map in listMap) {
      listTransaction.add(TransactionDbModel.fromMap(map));
    }

    return listTransaction;
  }

  TransactionDbModel copyToTransfer() {
    return TransactionDbModel(
      transDescription: transDescription,
      transCategoryId: transCategoryId,
      transValue: -transValue,
      transStatus: transStatus,
      transTransferId: transTransferId,
      transDate: transDate,
    );
  }

  TransactionDbModel copy() {
    return TransactionDbModel(
      transDescription: transDescription,
      transCategoryId: transCategoryId,
      transValue: transValue,
      transStatus: transStatus,
      transTransferId: transTransferId,
      transDate: transDate,
    );
  }

  @override
  String toString() {
    return 'Transaction('
        ' Id: $transId;'
        ' Category: $transCategoryId;'
        ' Description: "$transDescription";'
        ' Value: $transValue;'
        ' Status: ${transStatus.name};'
        ' TransferId: $transTransferId;'
        ' Date: $transDate'
        ')';
  }

  Map<String, dynamic> toMap() {
    // if (transId != null) {
    return <String, dynamic>{
      'transId': transId,
      'transDescription': transDescription,
      'transCategoryId': transCategoryId,
      'transValue': transValue,
      'transStatus': transStatus.index,
      'transTransferId': transTransferId,
      'transDate': transDate.millisecondsSinceEpoch,
    };
  }

  factory TransactionDbModel.fromMap(Map<String, dynamic> map) {
    return TransactionDbModel(
      transId: map['transId'] != null ? map['transId'] as int : null,
      transDescription: map['transDescription'] as String,
      transCategoryId: map['transCategoryId'] as int,
      transValue: map['transValue'] as double,
      transStatus: TransStatus.values[map['transStatus'] as int],
      transTransferId:
          map['transTransferId'] != null ? map['transTransferId'] as int : null,
      transDate:
          ExtendedDate.fromMillisecondsSinceEpoch(map['transDate'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory TransactionDbModel.fromJson(String source) =>
      TransactionDbModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Future<void> updateTransaction() async {
    await locator<AbstractTransactionRepository>().updateTrans(this);
  }
}
