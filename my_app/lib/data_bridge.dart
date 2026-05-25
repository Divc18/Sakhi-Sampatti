import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class UploadedDocument {
  final String documentType;
  final String fileName;
  final String? base64Data;

  UploadedDocument({
    required this.documentType,
    required this.fileName,
    required this.base64Data,
  });

  Map<String, dynamic> toJson() {
    return {
      'documentType': documentType,
      'fileName': fileName,
      'base64Data': base64Data,
    };
  }

  factory UploadedDocument.fromJson(Map<String, dynamic> json) {
    return UploadedDocument(
      documentType: json['documentType'],
      fileName: json['fileName'],
      base64Data: json['base64Data'],
    );
  }

  Uint8List? get bytes {
    if (base64Data == null) return null;
    return base64Decode(base64Data!);
  }
}

class BusinessRequest {
  final String businessName;
  final String category;
  final String description;
  final List<UploadedDocument> documents;
  final String userName;  // Add this
  final String userMobile; // Add this
  final DateTime timestamp;
  bool approved;

  BusinessRequest({
    required this.businessName,
    required this.category,
    required this.description,
    required this.documents,
    required this.userName,  // Make required
    required this.userMobile, // Make required
    this.approved = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'category': category,
      'description': description,
      'documents': documents.map((d) => d.toJson()).toList(),
      'userName': userName,
      'userMobile': userMobile,
      'approved': approved,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory BusinessRequest.fromJson(Map<String, dynamic> json) {
    return BusinessRequest(
      businessName: json['businessName'],
      category: json['category'],
      description: json['description'],
      documents: (json['documents'] as List)
          .map((e) => UploadedDocument.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      userName: json['userName'] ?? 'Unknown User',
      userMobile: json['userMobile'] ?? 'Not provided',
      approved: json['approved'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class DataBridge {
  // Temporary in-memory storage
  static List<BusinessRequest> _temporaryStorage = [];

  static Future<void> saveRequest(BusinessRequest request) async {
    _temporaryStorage.add(request);
    print('Request saved in memory: ${request.businessName} by ${request.userName}');
  }

  static Future<List<BusinessRequest>> readAllRequests() async {
    return _temporaryStorage;
  }

  static Future<List<BusinessRequest>> getPendingRequests() async {
    final all = await readAllRequests();
    return all.where((r) => !r.approved).toList();
  }

  static Future<List<BusinessRequest>> getApprovedRequests() async {
    final all = await readAllRequests();
    return all.where((r) => r.approved).toList();
  }

  static Future<void> approveRequest(int index) async {
    try {
      // Note: This approves the request at the given index in the pending list
      // You might need to adjust this logic based on your needs
      final pending = await getPendingRequests();
      if (index >= 0 && index < pending.length) {
        final request = pending[index];

        // Find and update the request in main storage
        for (var i = 0; i < _temporaryStorage.length; i++) {
          if (_temporaryStorage[i].businessName == request.businessName &&
              _temporaryStorage[i].userName == request.userName &&
              _temporaryStorage[i].timestamp == request.timestamp) {
            _temporaryStorage[i].approved = true;
            print('Request approved: ${request.businessName} by ${request.userName}');
            break;
          }
        }
      }
    } catch (e) {
      print('Error approving: $e');
    }
  }
}
