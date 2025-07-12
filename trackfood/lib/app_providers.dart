import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/profile_provider.dart';
import 'providers/chat_provider.dart';

class AppProviders extends StatelessWidget {
  final Widget child;
  const AppProviders({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (_) => ChatProvider(),
        ),
      ],
      child: child,
    );
  }
}
