// import 'dart:math';

// import '../common/constants/models/transaction_model.dart';
// import './transaction_repository.dart';

// class MockTransactionRepository implements TransactionRepository {
//   @override
//   Future<void> addTransaction(TransactionModel transaction) {
//     // TODO: implement addTransaction
//     throw UnimplementedError();
//   }

//   @override
//   Future<List<TransactionModel>> getAllTransactions() async {
//     await Future.delayed(const Duration(seconds: 2));

//     List<TransactionModel> transactions = [];

//     transactions
//       ..add(
//         TransactionModel(
//           userId: '1',
//           title: 'Salário Destefani',
//           description: 'Salário Destefani',
//           value: 12345.34,
//           category: 'Salário',
//           status: true,
//           date: DateTime.now().subtract(const Duration(days: 2)),
//         ),
//       )
//       ..add(
//         TransactionModel(
//           userId: '2',
//           title: 'Salário Vale',
//           description: 'Salário Vale',
//           value: 18234.56,
//           category: 'Salário',
//           status: true,
//           date: DateTime.now().subtract(const Duration(days: 5)),
//         ),
//       )
//       ..add(
//         TransactionModel(
//           userId: '2',
//           title: 'Aluguel',
//           description: 'Aluguel residencial',
//           value: -1856.34,
//           category: 'Contas',
//           status: true,
//           date: DateTime.now().subtract(Duration(days: Random().nextInt(10))),
//         ),
//       )
//       ..add(
//         TransactionModel(
//           userId: '2',
//           title: 'Conta Edp',
//           description: 'Conta de Energia EDP',
//           value: -345.67,
//           category: 'Contas',
//           status: true,
//           date: DateTime.now().subtract(Duration(days: Random().nextInt(10))),
//         ),
//       )
//       ..add(
//         TransactionModel(
//           userId: '2',
//           title: 'Aluguel',
//           description: 'Aluguel residencial',
//           value: -1856.34,
//           category: 'Contas',
//           status: true,
//           date: DateTime.now().subtract(Duration(days: Random().nextInt(10))),
//         ),
//       )
//       ..add(
//         TransactionModel(
//           userId: '1',
//           title: 'Viaguem',
//           description: 'Viagem a Paris',
//           value: -10234.94,
//           category: 'Lazer',
//           status: true,
//           date: DateTime.now().subtract(Duration(days: Random().nextInt(10))),
//         ),
//       )
//       ..add(
//         TransactionModel(
//           userId: '1',
//           title: 'Aluguel Loja',
//           description: 'Aluguel Loja',
//           value: -8268.93,
//           category: 'Contas',
//           status: true,
//           date: DateTime.now().subtract(Duration(days: Random().nextInt(10))),
//         ),
//       )
//       ..add(
//         TransactionModel(
//           userId: '2',
//           title: 'Padaria',
//           description: 'Padaria Nova República',
//           value: -45.34,
//           category: 'Alimentação',
//           status: true,
//           date: DateTime.now().subtract(Duration(days: Random().nextInt(10))),
//         ),
//       )
//       ..add(
//         TransactionModel(
//           userId: '1',
//           title: 'Conta Condomínio',
//           description: 'Condomínio Praia da Costa Hotel',
//           value: -589.94,
//           category: 'Contas',
//           status: true,
//           date: DateTime.now().subtract(Duration(days: Random().nextInt(10))),
//         ),
//       )
//       ..add(
//         TransactionModel(
//           userId: '1',
//           title: 'Escola',
//           description: 'Novo Universo Educação',
//           value: -845.34,
//           category: 'Contas',
//           status: true,
//           date: DateTime.now().subtract(Duration(days: Random().nextInt(10))),
//         ),
//       );

//     return transactions;
//   }

//   @override
//   Future<TransactionModel?> getTransactionId(int id) {
//     // TODO: implement getTransactionId
//     throw UnimplementedError();
//   }

//   @override
//   Future<int> updateTransaction(TransactionModel transaction) {
//     // TODO: implement updateTransaction
//     throw UnimplementedError();
//   }

//   @override
//   Future<void> deleteTransaction(TransactionModel transaction) {
//     // TODO: implement deleteTransaction
//     throw UnimplementedError();
//   }
// }
