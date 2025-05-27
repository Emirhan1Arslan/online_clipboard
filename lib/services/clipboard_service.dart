import 'dart:async';

import 'package:clipboard/clipboard.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myappon/models/clipboard_item.dart';
import 'package:uuid/uuid.dart';

class ClipboardService extends ChangeNotifier {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();
  
  List<ClipboardItem> _items = [];
  bool _isLoading = false;
  String? _lastClipboardText;
  String? _error;
  Timer? _clipboardCheckTimer;

  List<ClipboardItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  ClipboardService() {
    _init();
  }

  void _init() {
    // Start monitoring when user is logged in
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _startListening();
        _startClipboardMonitoring();
      } else {
        _stopListening();
        _stopClipboardMonitoring();
        _items = [];
        notifyListeners();
      }
    });
  }

  void _startListening() {
    if (_auth.currentUser == null) return;
    
    final userClipboardRef = _database
        .ref('clipboard/${_auth.currentUser!.uid}');
    
    userClipboardRef.onValue.listen((event) {
      try {
        _items = [];
        final data = event.snapshot.value;
        if (data != null && data is Map) {
          data.forEach((key, value) {
            if (value is Map) {
              final item = ClipboardItem.fromMap(
                value.cast<String, dynamic>(),
                key.toString(),
              );
              _items.add(item);
            }
          });
          
          // Sort by timestamp (newest first)
          _items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        }
        
        _error = null;
        notifyListeners();
      } catch (e) {
        _error = 'Failed to load clipboard items: ${e.toString()}';
        notifyListeners();
      }
    }, onError: (error) {
      _error = 'Database error: ${error.toString()}';
      notifyListeners();
    });
    notifyListeners();
    print('Fetched ${_items.length} items from Firebase: $_items');

  }

  void _stopListening() {
    // Implement if needed to remove listeners
  }

  void _startClipboardMonitoring() {
    // Check clipboard every few seconds
    _clipboardCheckTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _checkClipboard(),
    );
    
    // Also check immediately
    _checkClipboard();
  }

  void _stopClipboardMonitoring() {
    _clipboardCheckTimer?.cancel();
    _clipboardCheckTimer = null;
  }

  Future<void> _checkClipboard() async {
    if (_auth.currentUser == null) return;
    
    try {
      final clipboardText = await FlutterClipboard.paste();
      
      // If text hasn't changed or is empty, do nothing
      if (clipboardText.isEmpty || clipboardText == _lastClipboardText) {
        return;
      }
      
      _lastClipboardText = clipboardText;
      
      // Add to Firebase
      await addClipboardItem(clipboardText);
    } catch (e) {
      _error = 'Failed to read clipboard: ${e.toString()}';
      notifyListeners();
      
    }

  }

  Future<void> addClipboardItem(String text) async {
    if (_auth.currentUser == null) return;
    if (text.isEmpty) return;
    
    try {
      final itemId = _uuid.v4();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      final item = ClipboardItem(
        id: itemId,
        text: text,
        timestamp: timestamp,
      );
      print('Veri yazılıyor: ${item.toMap()}');

      print(item.toString());
      
      await _database
          .ref('clipboard/${_auth.currentUser!.uid}/$itemId')
          .set(item.toMap());
          
      // No need to update local items as the database listener will handle it
    } catch (e) {
      _error = 'Failed to save clipboard item: ${e.toString()}';
      notifyListeners();
    };
    notifyListeners();
        print('Kullanıcı UID: ${_auth.currentUser?.uid}');
  }

  Future<void> deleteItem(String id) async {
    if (_auth.currentUser == null) return;
    
    try {
      await _database
          .ref('clipboard/${_auth.currentUser!.uid}/$id')
          .remove();
          
      // No need to update local items as the database listener will handle it
    } catch (e) {
      _error = 'Failed to delete clipboard item: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> clearAll() async {
    if (_auth.currentUser == null) return;
    
    try {
      await _database
          .ref('clipboard/${_auth.currentUser!.uid}')
          .remove();
          
      // No need to update local items as the database listener will handle it
    } catch (e) {
      _error = 'Failed to clear clipboard: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> copyToClipboard(String text) async {
    try {
      await FlutterClipboard.copy(text);
      // Prevent duplicate detection when we copy an item
      _lastClipboardText = text;
    } catch (e) {
      _error = 'Failed to copy to clipboard: ${e.toString()}';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _stopClipboardMonitoring();
    _stopListening();
    super.dispose();
  }
}