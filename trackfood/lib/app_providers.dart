import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackfood/providers/chat_provider.dart';

// This file is for simple, app-wide providers.
// More complex providers like Profile, Diary, etc., should live in their own files.

// REMOVED: Old profileProvider definition. It now lives in providers/profile_provider.dart

// The chatProvider should also be a StateNotifierProvider if it manages complex state.
// For now, assuming it's a simple notifier. If it causes issues, it will need a similar refactor.
final chatProvider = ChangeNotifierProvider<ChatProvider>((ref) {
  return ChatProvider();
});

/// Provider to control the main tab navigation
final tabControllerProvider = StateProvider<int>((ref) => 0);
