import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/profile_provider.dart';
import 'providers/chat_provider.dart';

final profileProvider = ChangeNotifierProvider<ProfileProvider>((ref) {
  return ProfileProvider();
});

final chatProvider = ChangeNotifierProvider<ChatProvider>((ref) {
  return ChatProvider();
});

/// Provider to control the main tab navigation
final tabControllerProvider = StateProvider<int>((ref) => 0);
