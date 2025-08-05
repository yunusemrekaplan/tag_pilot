import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/app_constants.dart';
import '../../domain/services/database_service.dart';

/// Firestore Database Service Implementation
/// SOLID: Dependency Inversion - DatabaseService interface'ini implement eder
/// SOLID: Single Responsibility - Sadece Firestore operations
class FirestoreDatabaseService implements DatabaseService {
  final FirebaseFirestore _firestore;

  FirestoreDatabaseService() : _firestore = FirebaseFirestore.instance {
    _configureFirestore();
  }

  // Constructor for testing with mock firestore
  FirestoreDatabaseService.withInstance(this._firestore) {
    _configureFirestore();
  }

  void _configureFirestore() {
    try {
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('⚠️ Firestore configuration warning: $e');
      }
    }
  }

  // ============================================================================
  // COLLECTION OPERATIONS
  // ============================================================================

  @override
  CollectionReference getCollection(String collectionPath) {
    return _firestore.collection(collectionPath);
  }

  @override
  DocumentReference getDocument(String documentPath) {
    return _firestore.doc(documentPath);
  }

  @override
  CollectionReference getUserCollection(String userId, String collection) {
    return _firestore
        .collection(DatabaseConstants.usersCollection)
        .doc(userId)
        .collection(collection);
  }

  @override
  DocumentReference getUserDocument(String userId) {
    return _firestore.collection(DatabaseConstants.usersCollection).doc(userId);
  }

  // ============================================================================
  // QUERY OPERATIONS
  // ============================================================================

  @override
  Future<DocumentSnapshot> getDocumentById(String path) async {
    try {
      return await _firestore.doc(path).get();
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Get document by ID error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<QuerySnapshot> getDocuments(String collectionPath) async {
    try {
      return await _firestore.collection(collectionPath).get();
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Get documents error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<QuerySnapshot> getDocumentsWhere(
    String collectionPath,
    String field,
    dynamic value,
  ) async {
    try {
      return await _firestore
          .collection(collectionPath)
          .where(field, isEqualTo: value)
          .get();
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Get documents where error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<QuerySnapshot> getDocumentsWhereRange(
    String collectionPath,
    String field,
    dynamic startValue,
    dynamic endValue,
  ) async {
    try {
      return await _firestore
          .collection(collectionPath)
          .where(field, isGreaterThanOrEqualTo: startValue)
          .where(field, isLessThan: endValue)
          .get();
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Get documents where range error: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // WRITE OPERATIONS
  // ============================================================================

  @override
  Future<DocumentReference?> setDocument(String path, Map<String, dynamic> data,
      {bool merge = false}) async {
    try {
      await _firestore.doc(path).set(data, SetOptions(merge: merge));
      return _firestore.doc(path);
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Set document error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<DocumentReference> addDocument(
      String collectionPath, Map<String, dynamic> data) async {
    try {
      return await _firestore.collection(collectionPath).add(data);
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Add document error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> updateDocument(String path, Map<String, dynamic> data) async {
    try {
      await _firestore.doc(path).update(data);
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Update document error: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteDocument(String path) async {
    try {
      await _firestore.doc(path).delete();
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Delete document error: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // BATCH OPERATIONS
  // ============================================================================

  @override
  WriteBatch getBatch() {
    return _firestore.batch();
  }

  @override
  Future<void> commitBatch(WriteBatch batch) async {
    try {
      await batch.commit();
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Commit batch error: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // TRANSACTION OPERATIONS
  // ============================================================================

  @override
  Future<T> runTransaction<T>(TransactionHandler<T> updateFunction) async {
    try {
      return await _firestore.runTransaction(updateFunction);
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Run transaction error: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // REAL-TIME OPERATIONS
  // ============================================================================

  @override
  Stream<DocumentSnapshot> watchDocument(String path) {
    try {
      return _firestore.doc(path).snapshots();
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Watch document error: $e');
      }
      rethrow;
    }
  }

  @override
  Stream<QuerySnapshot> watchCollection(String collectionPath) {
    try {
      return _firestore.collection(collectionPath).snapshots();
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Watch collection error: $e');
      }
      rethrow;
    }
  }

  @override
  Stream<QuerySnapshot> watchCollectionWhere(
    String collectionPath,
    String field,
    dynamic value,
  ) {
    try {
      return _firestore
          .collection(collectionPath)
          .where(field, isEqualTo: value)
          .snapshots();
    } catch (e) {
      if (AppConstants.enableLogging) {
        print('🔥 Watch collection where error: $e');
      }
      rethrow;
    }
  }

  // ============================================================================
  // UTILITY OPERATIONS
  // ============================================================================

  @override
  FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  @override
  FieldValue arrayUnion(List<dynamic> elements) =>
      FieldValue.arrayUnion(elements);

  @override
  FieldValue arrayRemove(List<dynamic> elements) =>
      FieldValue.arrayRemove(elements);

  @override
  FieldValue increment(num value) => FieldValue.increment(value);

  @override
  FieldValue get delete => FieldValue.delete();

  // ============================================================================
  // CONNECTION STATUS
  // ============================================================================

  @override
  Future<bool> isConnected() async {
    try {
      await _firestore.doc('health/check').get();
      return true;
    } catch (e) {
      return false;
    }
  }
}
