import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/firebase/device_repository.dart';
import '../../../shared/providers/auth_state_provider.dart';
import '../domain/device_models.dart';

part 'device_list_provider.g.dart';

final _repo = DeviceRepository();

@riverpod
Stream<List<FirestoreDevice>> deviceList(Ref ref) {
  final session = ref.watch(authStateProvider);
  if (session == null) return const Stream.empty();
  return _repo.watchDevices(session.companyId);
}
