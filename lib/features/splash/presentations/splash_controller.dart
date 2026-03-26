import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/core/config/endpoint.dart';
import 'package:inventory/core/data_sources/local/hive_service.dart';
import 'package:inventory/core/data_sources/local/secure_storage_service.dart';
import 'package:inventory/core/data_sources/network/dio_client.dart';
import 'package:inventory/features/login/application.dart';

final splashBootstrapProvider = FutureProvider<String>((ref) async {
	final token = await ref.read(secureStorageServiceProvider).getToken();
	final user = await ref.read(hiveServiceProvider).getUser();

	if (token == null || token.isEmpty || user == null) {
		await ref.read(secureStorageServiceProvider).clearToken();
		await ref.read(hiveServiceProvider).clearSessionCache();
		return '/login';
	}

	final role = (user.role ?? 'user').toLowerCase();
	final roleHome = role == 'aslab' ? '/aslab' : '/user';

	try {
		await ref.read(dioProvider).get<dynamic>(Endpoint.loans);
		ref.read(loginControllerProvider.notifier).setUser(user);
		return roleHome;
	} on DioException catch (error) {
		if (error.response?.statusCode == 401) {
			await ref.read(secureStorageServiceProvider).clearToken();
			await ref.read(hiveServiceProvider).clearSessionCache();
			return '/login';
		}

		ref.read(loginControllerProvider.notifier).setUser(user);
		return roleHome;
	}
});

