import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/material_model.dart';
import '../models/request_model.dart';
import '../models/notification_model.dart';
import '../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Static list of realistic demo materials for instant offline/fallback display
  static List<MaterialModel> getDemoMaterials() {
    return [
      MaterialModel(
        id: 'demo_mat_1',
        name: 'Metal Sheet Offcuts',
        category: 'Metal',
        description:
            'Small metal sheet pieces left from workshop cutting. Suitable for student projects, prototypes, and small fabrication work.',
        quantity: '12',
        unit: 'Pieces',
        condition: 'Usable',
        availabilityType: AppConstants.availabilityFree,
        price: 0.0,
        imageUrl: 'https://images.unsplash.com/photo-1504917595217-d4dc5ebe6122?w=500',
        location: 'Small Industrial Estate, Gujranwala',
        supplierId: 'demo_supplier_1',
        supplierName: 'Ali Workshop',
        supplierPhone: '03001234567',
        status: AppConstants.materialStatusAvailable,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        updatedAt: DateTime.now(),
      ),
      MaterialModel(
        id: 'demo_mat_2',
        name: 'Wooden Packaging Scraps',
        category: 'Wood',
        description:
            'Durable pine wood scraps and crate offcuts from manufacturing unit. Ideal for DIY woodwork, arts, and model building.',
        quantity: '8',
        unit: 'Kg',
        condition: 'Good',
        availabilityType: AppConstants.availabilityFree,
        price: 0.0,
        imageUrl: 'https://images.unsplash.com/photo-1513836279014-a89f7a76ae86?w=500',
        location: 'G.T. Road Industrial Zone, Gujranwala',
        supplierId: 'demo_supplier_2',
        supplierName: 'Gujranwala Woodcrafts',
        supplierPhone: '03129876543',
        status: AppConstants.materialStatusAvailable,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        updatedAt: DateTime.now(),
      ),
      MaterialModel(
        id: 'demo_mat_3',
        name: 'Cardboard Packaging Boxes',
        category: 'Packaging',
        description:
            'Heavy-duty corrugated cardboard boxes in excellent condition. Perfect for storage, shipping, or recycling projects.',
        quantity: '20',
        unit: 'Box',
        condition: 'Good',
        availabilityType: AppConstants.availabilityFree,
        price: 0.0,
        imageUrl: 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=500',
        location: 'Climax Town, Gujranwala',
        supplierId: 'demo_supplier_1',
        supplierName: 'Ali Workshop',
        supplierPhone: '03001234567',
        status: AppConstants.materialStatusAvailable,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      ),
      MaterialModel(
        id: 'demo_mat_4',
        name: 'Small Machine Parts & Bearings',
        category: 'Machine Parts',
        description:
            'Assorted gears, bearings, and bolts left over from machinery assembly. Suitable for robotics or mechanical engineering designs.',
        quantity: '15',
        unit: 'Pieces',
        condition: 'Good',
        availabilityType: AppConstants.availabilityPaid,
        price: 350.0,
        imageUrl: 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=500',
        location: 'Sialkot Bypass, Gujranwala',
        supplierId: 'demo_supplier_3',
        supplierName: 'Precision Engineering Co.',
        supplierPhone: '03215556677',
        status: AppConstants.materialStatusAvailable,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // ---------------- USER OPERATIONS ----------------

  Future<void> saveUserData(UserModel user) async {
    try {
      await _db.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      // Non-blocking save
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _db
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 4));
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Stream<UserModel?> streamUserData(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }

  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .update({'role': role})
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      // Non-blocking
    }
  }

  // ---------------- MATERIAL OPERATIONS ----------------

  Future<String> addMaterial(MaterialModel material) async {
    try {
      DocumentReference docRef = await _db.collection('materials').add(material.toMap());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw 'Failed to list material. Please try again.';
    }
  }

  Future<void> updateMaterial(MaterialModel material) async {
    try {
      await _db.collection('materials').doc(material.id).update(material.toMap());
    } catch (e) {
      throw 'Failed to update material listing.';
    }
  }

  Future<void> deleteMaterial(String materialId) async {
    try {
      await _db.collection('materials').doc(materialId).delete();
    } catch (e) {
      throw 'Failed to delete material.';
    }
  }

  Stream<List<MaterialModel>> getAvailableMaterials({
    String category = 'All',
    String searchQuery = '',
    String availability = 'All',
  }) {
    return _db
        .collection('materials')
        .where('status', isNotEqualTo: AppConstants.materialStatusInactive)
        .snapshots()
        .map((snapshot) {
      List<MaterialModel> list = snapshot.docs.map((doc) {
        return MaterialModel.fromMap(doc.data(), doc.id);
      }).toList();

      // If database has no entries yet, fallback to instant demo materials
      if (list.isEmpty) {
        list = getDemoMaterials();
      }

      // Filter by category
      if (category != 'All') {
        list = list.where((item) => item.category.toLowerCase() == category.toLowerCase()).toList();
      }

      // Filter by availability
      if (availability != 'All') {
        list = list
            .where((item) => item.availabilityType.toLowerCase() == availability.toLowerCase())
            .toList();
      }

      // Filter by search query
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        list = list.where((item) {
          return item.name.toLowerCase().contains(query) ||
              item.description.toLowerCase().contains(query) ||
              item.category.toLowerCase().contains(query) ||
              item.location.toLowerCase().contains(query);
        }).toList();
      }

      // Sort newest first
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<MaterialModel>> getSupplierListings(String supplierId) {
    return _db
        .collection('materials')
        .where('supplierId', isEqualTo: supplierId)
        .snapshots()
        .map((snapshot) {
      List<MaterialModel> list = snapshot.docs.map((doc) {
        return MaterialModel.fromMap(doc.data(), doc.id);
      }).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // ---------------- REQUEST OPERATIONS ----------------

  Future<String> sendMaterialRequest(RequestModel request) async {
    try {
      DocumentReference docRef = await _db.collection('requests').add(request.toMap());
      await docRef.update({'id': docRef.id});

      // Send notification to supplier
      await createNotification(
        NotificationModel(
          id: '',
          userId: request.supplierId,
          title: 'New Request Received',
          message: '${request.makerName} requested ${request.requestedQuantity} of ${request.materialName}.',
          type: 'request',
          createdAt: DateTime.now(),
        ),
      );

      return docRef.id;
    } catch (e) {
      throw 'Failed to send request. Please try again.';
    }
  }

  Future<void> updateRequestStatus(String requestId, String status, RequestModel request) async {
    try {
      await _db.collection('requests').doc(requestId).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Notify maker about status update
      String title = 'Request Updated';
      String msg = 'Your request for ${request.materialName} is now $status.';
      if (status == AppConstants.requestAccepted) {
        title = 'Request Accepted! 🎉';
        msg = 'Your request for ${request.materialName} was accepted by ${request.supplierName}. Contact them for collection.';
      } else if (status == AppConstants.requestRejected) {
        title = 'Request Declined';
        msg = 'Your request for ${request.materialName} was declined.';
      } else if (status == AppConstants.requestCompleted) {
        title = 'Material Collected ✅';
        msg = 'Your request for ${request.materialName} has been marked as completed.';

        // Update material status as collected if completed
        await _db.collection('materials').doc(request.materialId).update({
          'status': AppConstants.materialStatusCollected,
        });
      }

      await createNotification(
        NotificationModel(
          id: '',
          userId: request.makerId,
          title: title,
          message: msg,
          type: status,
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      throw 'Failed to update request status.';
    }
  }

  Stream<List<RequestModel>> getMakerRequests(String makerId) {
    return _db
        .collection('requests')
        .where('makerId', isEqualTo: makerId)
        .snapshots()
        .map((snapshot) {
      List<RequestModel> list = snapshot.docs.map((doc) {
        return RequestModel.fromMap(doc.data(), doc.id);
      }).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<RequestModel>> getSupplierRequests(String supplierId) {
    return _db
        .collection('requests')
        .where('supplierId', isEqualTo: supplierId)
        .snapshots()
        .map((snapshot) {
      List<RequestModel> list = snapshot.docs.map((doc) {
        return RequestModel.fromMap(doc.data(), doc.id);
      }).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // ---------------- FAVORITES OPERATIONS ----------------

  Future<void> toggleFavorite(String userId, String materialId) async {
    try {
      final docRef = _db.collection('favorites').doc('${userId}_$materialId');
      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.delete();
      } else {
        await docRef.set({
          'userId': userId,
          'materialId': materialId,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      // Non-critical
    }
  }

  Stream<bool> isFavorite(String userId, String materialId) {
    return _db
        .collection('favorites')
        .doc('${userId}_$materialId')
        .snapshots()
        .map((doc) => doc.exists);
  }

  Stream<List<String>> getUserFavoriteMaterialIds(String userId) {
    return _db
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => d['materialId'] as String).toList());
  }

  // ---------------- NOTIFICATIONS ----------------

  Future<void> createNotification(NotificationModel notification) async {
    try {
      DocumentReference ref = await _db.collection('notifications').add(notification.toMap());
      await ref.update({'id': ref.id});
    } catch (e) {
      // Non-critical background task
    }
  }

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      List<NotificationModel> list = snapshot.docs.map((doc) {
        return NotificationModel.fromMap(doc.data(), doc.id);
      }).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // ---------------- SEED DEMO DATA IF EMPTY ----------------

  Future<void> seedDemoDataIfEmpty() async {
    try {
      final snapshot = await _db
          .collection('materials')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 3));

      if (snapshot.docs.isNotEmpty) return;

      final demoMaterials = getDemoMaterials();

      // Run parallel additions with timeout
      await Future.wait(
        demoMaterials.map((item) async {
          DocumentReference ref = await _db.collection('materials').add(item.toMap());
          await ref.update({'id': ref.id});
        }),
      ).timeout(const Duration(seconds: 4));
    } catch (e) {
      // Fast non-blocking exit
    }
  }
}
