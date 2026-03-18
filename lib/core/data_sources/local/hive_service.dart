import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:inventory/core/models/user_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());

class HiveService {
  static const String _boxName = 'inventory_app';
  static const String _userKey = 'current_user';
  static const String _lastRoomIdKey = 'last_room_id';

  static bool _initialized = false;

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(_boxName);
    _initialized = true;
  }

  Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  Future<void> saveUser(UserModel user) async {
    await ensureInitialized();
    await _box.put(_userKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    await ensureInitialized();
    final raw = _box.get(_userKey);
    if (raw is! String || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    return UserModel.fromJson(decoded);
  }

  Future<void> clearUser() async {
    await ensureInitialized();
    await _box.delete(_userKey);
  }

  Future<void> saveLastRoomId(int roomId) async {
    await ensureInitialized();
    await _box.put(_lastRoomIdKey, roomId);
  }

  Future<int?> getLastRoomId() async {
    await ensureInitialized();
    final value = _box.get(_lastRoomIdKey);
    return value is int ? value : null;
  }

  Future<void> clearSessionCache() async {
    await ensureInitialized();
    await _box.delete(_userKey);
    await _box.delete(_lastRoomIdKey);
  }
}

Future<void> hiveInit() async {
  await Hive.initFlutter();
  await Hive.openBox<dynamic>('inventory_app');
}
