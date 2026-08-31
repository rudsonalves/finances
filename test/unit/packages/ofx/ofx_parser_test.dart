import 'dart:io';

import 'package:finances/packages/ofx/lib/ofx.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const fixturePath = 'test/helpers/fixtures/ofx/valid_bank_xml_v2.ofx';

  group('Ofx.fromString - OFX XML 2.x', () {
    late Ofx ofx;

    setUpAll(() {
      final source = File(fixturePath).readAsStringSync();
      ofx = Ofx.fromString(source);
    });

    test('extrai os dados da instituição e da conta', () {
      expect(ofx.financialInstitution.organization, 'BANCO TESTE');
      expect(ofx.financialInstitution.financialInstitutionID, '999');
      expect(ofx.bankID, '999');
      expect(ofx.accountID, '123456-7');
      expect(ofx.accountType, 'CHECKING');
      expect(ofx.currency, 'BRL');
    });

    test('extrai o período do extrato', () {
      expect(ofx.start, DateTime.utc(2026, 8, 1));
      expect(
        ofx.end,
        DateTime.utc(2026, 8, 31, 23, 59, 59),
      );
    });

    test('extrai todas as transações', () {
      expect(ofx.transactions, hasLength(2));
    });

    test('preserva o sinal negativo de uma transação de débito', () {
      final transaction = ofx.transactions[0];

      expect(transaction.type, 'DEBIT');
      expect(
        transaction.posted,
        DateTime.utc(2026, 8, 10, 10, 30),
      );
      expect(transaction.amount, -125.45);
      expect(
        transaction.financialInstitutionID,
        'transaction-debit-001',
      );
      expect(transaction.referenceNumber, 'reference-001');
      expect(transaction.memo, 'Compra no supermercado');
    });

    test('preserva o sinal positivo de uma transação de crédito', () {
      final transaction = ofx.transactions[1];

      expect(transaction.type, 'CREDIT');
      expect(
        transaction.posted,
        DateTime.utc(2026, 8, 15, 14),
      );
      expect(transaction.amount, 2500.00);
      expect(
        transaction.financialInstitutionID,
        'transaction-credit-001',
      );
      expect(transaction.referenceNumber, 'reference-002');
      expect(transaction.memo, 'Pagamento recebido');
    });
  });

  group('Ofx.fromString - uma única transação', () {
    test('aceita STMTTRN representado como um único objeto', () {
      const fixturePath = 'test/helpers/fixtures/ofx/'
          'valid_bank_xml_single_transaction.ofx';

      final source = File(fixturePath).readAsStringSync();
      final ofx = Ofx.fromString(source);

      expect(ofx.transactions, hasLength(1));

      final transaction = ofx.transactions.single;

      expect(transaction.type, 'DEBIT');
      expect(
        transaction.posted,
        DateTime.utc(2026, 9, 1, 10, 30),
      );
      expect(transaction.amount, -42.90);
      expect(
        transaction.financialInstitutionID,
        'single-transaction-001',
      );
      expect(transaction.referenceNumber, 'single-reference-001');
      expect(transaction.memo, 'Compra única');
    });
  });

  group('Ofx.fromString - extrato sem transações', () {
    test('retorna uma lista vazia quando STMTTRN não existe', () {
      const fixturePath = 'test/helpers/fixtures/ofx/'
          'valid_bank_xml_empty_statement.ofx';

      final source = File(fixturePath).readAsStringSync();
      final ofx = Ofx.fromString(source);

      expect(ofx.bankID, '999');
      expect(ofx.accountID, '123456-7');
      expect(ofx.transactions, isEmpty);
    });
  });

  group('Ofx.fromMap - reconstrução do formato interno', () {
    test('reconstrói todos os dados produzidos por Ofx.toMap', () {
      const fixturePath = 'test/helpers/fixtures/ofx/valid_bank_xml_v2.ofx';

      final source = File(fixturePath).readAsStringSync();
      final original = Ofx.fromString(source);
      final reconstructed = Ofx.fromMap(original.toMap());

      expect(reconstructed.statusOfx.code, original.statusOfx.code);
      expect(
        reconstructed.statusOfx.severity,
        original.statusOfx.severity,
      );
      expect(reconstructed.server, original.server);
      expect(reconstructed.serverLocal, original.serverLocal);
      expect(reconstructed.language, original.language);
      expect(
        reconstructed.financialInstitution.organization,
        original.financialInstitution.organization,
      );
      expect(
        reconstructed.financialInstitution.financialInstitutionID,
        original.financialInstitution.financialInstitutionID,
      );
      expect(
        reconstructed.transactionUniqueID,
        original.transactionUniqueID,
      );
      expect(
        reconstructed.statusTransaction.code,
        original.statusTransaction.code,
      );
      expect(
        reconstructed.statusTransaction.severity,
        original.statusTransaction.severity,
      );
      expect(reconstructed.currency, original.currency);
      expect(reconstructed.bankID, original.bankID);
      expect(reconstructed.accountID, original.accountID);
      expect(reconstructed.accountType, original.accountType);
      expect(reconstructed.start, original.start);
      expect(reconstructed.startLocal, original.startLocal);
      expect(reconstructed.end, original.end);
      expect(reconstructed.endLocal, original.endLocal);

      expect(reconstructed.transactions, hasLength(2));

      final originalDebit = original.transactions[0];
      final reconstructedDebit = reconstructed.transactions[0];

      expect(reconstructedDebit.type, originalDebit.type);
      expect(reconstructedDebit.posted, originalDebit.posted);
      expect(reconstructedDebit.postedLocal, originalDebit.postedLocal);
      expect(reconstructedDebit.amount, originalDebit.amount);
      expect(
        reconstructedDebit.financialInstitutionID,
        originalDebit.financialInstitutionID,
      );
      expect(
        reconstructedDebit.referenceNumber,
        originalDebit.referenceNumber,
      );
      expect(reconstructedDebit.memo, originalDebit.memo);

      final originalCredit = original.transactions[1];
      final reconstructedCredit = reconstructed.transactions[1];

      expect(reconstructedCredit.type, originalCredit.type);
      expect(reconstructedCredit.posted, originalCredit.posted);
      expect(reconstructedCredit.postedLocal, originalCredit.postedLocal);
      expect(reconstructedCredit.amount, originalCredit.amount);
      expect(
        reconstructedCredit.financialInstitutionID,
        originalCredit.financialInstitutionID,
      );
      expect(
        reconstructedCredit.referenceNumber,
        originalCredit.referenceNumber,
      );
      expect(reconstructedCredit.memo, originalCredit.memo);
    });
  });

  group('Ofx.fromString - descrição da transação', () {
    test('usa NAME quando MEMO não existe', () {
      const fixturePath = 'test/helpers/fixtures/ofx/'
          'valid_bank_xml_transaction_without_memo.ofx';

      final source = File(fixturePath).readAsStringSync();
      final ofx = Ofx.fromString(source);

      expect(ofx.transactions, hasLength(1));
      expect(ofx.transactions.single.memo, 'LOJA TESTE');
    });

    test('usa uma string vazia quando MEMO e NAME não existem', () {
      const fixturePath = 'test/helpers/fixtures/ofx/'
          'valid_bank_xml_transaction_without_description.ofx';

      final source = File(fixturePath).readAsStringSync();
      final ofx = Ofx.fromString(source);

      expect(ofx.transactions, hasLength(1));
      expect(ofx.transactions.single.memo, isEmpty);
      expect(ofx.transactions.single.memo, isNot('null'));
    });
  });

  group('Ofx.fromString - referência da transação', () {
    test('usa uma string vazia quando REFNUM não existe', () {
      const fixturePath = 'test/helpers/fixtures/ofx/'
          'valid_bank_xml_transaction_without_refnum.ofx';

      final source = File(fixturePath).readAsStringSync();
      final ofx = Ofx.fromString(source);

      expect(ofx.transactions, hasLength(1));

      final transaction = ofx.transactions.single;

      expect(
        transaction.financialInstitutionID,
        'single-transaction-001',
      );
      expect(transaction.referenceNumber, isEmpty);
      expect(transaction.referenceNumber, isNot('null'));
      expect(transaction.memo, 'Compra única');
    });
  });

  group('Ofx.fromString - identificador da transação', () {
    test('rejeita uma transação sem FITID', () {
      const fixturePath = 'test/helpers/fixtures/ofx/'
          'invalid_bank_xml_transaction_without_fitid.ofx';

      final source = File(fixturePath).readAsStringSync();

      expect(
        () => Ofx.fromString(source),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            'Transação OFX sem FITID.',
          ),
        ),
      );
    });
  });

  group('Ofx.fromString - valor da transação', () {
    test('rejeita uma transação sem TRNAMT', () {
      const fixturePath = 'test/helpers/fixtures/ofx/'
          'invalid_bank_xml_transaction_without_amount.ofx';

      final source = File(fixturePath).readAsStringSync();

      expect(
        () => Ofx.fromString(source),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            'Transação OFX sem TRNAMT.',
          ),
        ),
      );
    });

    test('rejeita um TRNAMT que não seja numérico', () {
      const fixturePath = 'test/helpers/fixtures/ofx/'
          'invalid_bank_xml_transaction_with_invalid_amount.ofx';

      final source = File(fixturePath).readAsStringSync();

      expect(
        () => Ofx.fromString(source),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            'Valor inválido em TRNAMT: valor-invalido.',
          ),
        ),
      );
    });
  });

  group('Ofx.fromString - data da transação', () {
    test('rejeita uma transação sem DTPOSTED', () {
      const fixturePath = 'test/helpers/fixtures/ofx/'
          'invalid_bank_xml_transaction_without_posted_date.ofx';

      final source = File(fixturePath).readAsStringSync();

      expect(
        () => Ofx.fromString(source),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            'Transação OFX sem DTPOSTED.',
          ),
        ),
      );
    });

    test('rejeita um DTPOSTED truncado', () {
      const fixturePath = 'test/helpers/fixtures/ofx/'
          'invalid_bank_xml_transaction_with_truncated_date.ofx';

      final source = File(fixturePath).readAsStringSync();

      expect(
        () => Ofx.fromString(source),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            'Valor inválido em DTPOSTED: 20260901.',
          ),
        ),
      );
    });
  });
}
