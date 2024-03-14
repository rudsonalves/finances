import '../../common/models/ofx_relationship_model.dart';

/// An abstract class defining the repository for managing OFX relationships.
///
/// This repository provides an abstraction layer over the underlying storage
/// mechanism for OFX relationships, allowing for the insertion, update, query,
/// and deletion of OFX relationship data encapsulated in `OfxRelationshipModel`
/// objects.
///
/// Methods:
/// - `insert`: Adds a new OFX relationship to the repository.
/// - `update`: Updates an existing OFX relationship in the repository.
/// - `queryBankId`: Retrieves an OFX relationship by its associated bank ID.
/// - `deleteId`: Removes an OFX relationship from the repository by its ID.
///
/// The implementation of this abstract class should handle the specifics of
/// interacting with the data storage (e.g., database, in-memory, etc.), ensuring
/// that the OFX relationships are persistently managed according to the business
/// requirements.
///
/// Usage:
/// Implement this abstract class in a concrete repository class that defines
/// how OFX relationships are stored, retrieved, updated, and deleted. This
/// allows for flexibility in the choice of storage mechanism and encapsulates
/// the data access logic away from the application logic.
abstract class AbtractOfxRelationshipRepository {
  /// Inserts a new OFX relationship into the repository.
  ///
  /// This method takes an `OfxRelationshipModel` object, representing the OFX
  /// relationship to be added, and attempts to insert it into the underlying
  /// storage system. The `toMap` method of `OfxRelationshipModel` is used to
  /// convert the model to a map representation suitable for storage.
  ///
  /// Parameters:
  /// - `ofxRelationship`: The OFX relationship model to insert.
  ///
  /// Returns:
  /// - The ID of the newly inserted OFX relationship if the operation is
  ///   successful; otherwise, a negative value indicating failure.
  ///
  /// After insertion, the `id` property of the `ofxRelationship` model is
  /// updated with the ID returned by the storage system. If the insertion
  /// fails, an error log is generated with the negative return ID.
  ///
  /// Usage:
  /// To insert a new OFX relationship into the repository, create an instance
  /// of `OfxRelationshipModel` with the desired data, and call this method with
  /// it. Ensure to handle the case where the insertion might fail, indicated by
  /// a negative return ID.
  Future<int> insert(OfxRelationshipModel ofxRelationship);

  /// Updates an existing OFX relationship in the repository.
  ///
  /// This method accepts an `OfxRelationshipModel` object with updated fields
  /// for an existing OFX relationship. It then attempts to update the
  /// corresponding record in the storage system using the `update` method of
  /// the underlying store.
  ///
  /// Parameters:
  /// - `ofxRelationship`: The OFX relationship model with updated information.
  ///
  /// Returns:
  /// - The number of rows affected by the update operation. Typically, this
  ///   value should be 1 if the update is successful. If the operation affects
  ///   no rows or fails, an appropriate message is logged indicating the
  ///   outcome.
  ///
  /// Usage:
  /// To update an OFX relationship, first modify the fields of an existing
  /// `OfxRelationshipModel` object as needed. Then, pass this object to the
  /// method to persist the changes. Check the returned result to ensure the
  /// update was successful, as indicated by a return value of 1.
  Future<int> update(OfxRelationshipModel ofxRelationship);

  /// Queries an OFX relationship by its associated bank ID.
  ///
  /// This method searches for an OFX relationship in the repository based on
  /// the provided bank ID. If found, it returns an instance of
  /// `OfxRelationshipModel` populated with the retrieved data. Otherwise, it
  /// returns `null`.
  ///
  /// Parameters:
  /// - `bankId`: The bank ID associated with the OFX relationship to be
  ///   queried.
  ///
  /// Returns:
  /// - An `OfxRelationshipModel` instance representing the found OFX
  ///   relationship, or `null` if no matching relationship is found in the
  ///   repository.
  ///
  /// Usage:
  /// To query an OFX relationship by bank ID, call this method with the desired
  /// bank ID. Use the returned `OfxRelationshipModel` instance to access the
  /// details of the OFX relationship. If the method returns `null`, it
  /// indicates that no relationship associated with the provided bank ID exists
  /// in the repository.
  Future<OfxRelationshipModel?> queryBankAccountId(String bankId);

  /// Deletes an OFX relationship by its ID from the database.
  ///
  /// This method attempts to delete an OFX relationship entry based on its
  /// unique ID. If the operation is successful and exactly one record is
  /// deleted, it returns the number of records deleted. Otherwise, it logs an
  /// error and throws an exception indicating the failure of the operation.
  ///
  /// Parameters:
  /// - `id`: The unique identifier of the OFX relationship to delete.
  ///
  /// Returns:
  /// - The number of records deleted, expected to be 1 on successful deletion.
  ///
  /// Throws:
  /// - An exception if the deletion fails or does not delete exactly one
  ///   record.
  ///
  /// Usage:
  /// Call this method when you need to remove an OFX relationship from the
  /// database, typically when the relationship is no longer valid or needed.
  ///
  /// Example:
  /// ```dart
  /// int deletedRecords = await repository.deleteId(ofxRelationshipId);
  /// if (deletedRecords != 1) {
  ///   // Handle the error scenario
  /// }
  Future<int> deleteId(int id);
}
