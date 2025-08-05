import 'package:cloud_firestore/cloud_firestore.dart';

/// Database Service Interface
/// SOLID: Interface Segregation - Sadece database operasyonları
/// SOLID: Dependency Inversion - High-level modules buna bağımlı olacak
abstract class DatabaseService {
  // Collection operations
  CollectionReference getCollection(String collectionPath);
  DocumentReference getDocument(String documentPath);

  // User-specific operations
  CollectionReference getUserCollection(String userId, String collection);
  DocumentReference getUserDocument(String userId);

  // Query operations
  Future<DocumentSnapshot> getDocumentById(String path);
  Future<QuerySnapshot> getDocuments(String collectionPath);
  Future<QuerySnapshot> getDocumentsWhere(
    String collectionPath,
    String field,
    dynamic value,
  );
  Future<QuerySnapshot> getDocumentsWhereRange(
    String collectionPath,
    String field,
    dynamic startValue,
    dynamic endValue,
  );

  // Write operations
  Future<DocumentReference?> setDocument(String path, Map<String, dynamic> data,
      {bool merge = false});
  Future<DocumentReference> addDocument(
      String collectionPath, Map<String, dynamic> data);
  Future<void> updateDocument(String path, Map<String, dynamic> data);
  Future<void> deleteDocument(String path);

  // Batch operations
  WriteBatch getBatch();
  Future<void> commitBatch(WriteBatch batch);

  // Transaction operations
  Future<T> runTransaction<T>(TransactionHandler<T> updateFunction);

  // Real-time operations
  Stream<DocumentSnapshot> watchDocument(String path);
  Stream<QuerySnapshot> watchCollection(String collectionPath);
  Stream<QuerySnapshot> watchCollectionWhere(
    String collectionPath,
    String field,
    dynamic value,
  );

  // Utility operations
  FieldValue get serverTimestamp;
  FieldValue arrayUnion(List<dynamic> elements);
  FieldValue arrayRemove(List<dynamic> elements);
  FieldValue increment(num value);
  FieldValue get delete;

  // Connection status
  Future<bool> isConnected();
}
