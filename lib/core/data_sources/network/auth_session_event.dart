import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthSessionExpiredEventNotifier extends Notifier<int> {
	@override
	int build() => 0;

	void emit() {
		state++;
	}
}

final authSessionExpiredEventProvider =
		NotifierProvider<AuthSessionExpiredEventNotifier, int>(
			AuthSessionExpiredEventNotifier.new,
		);
