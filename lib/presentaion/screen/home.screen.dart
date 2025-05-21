import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/application/providers/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
    const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
    
}
class _HomeScreenState extends ConsumerState<HomeScreen> {
    @override
    void initState() {
        super.initState();
        // Load user info from secure storage when HomeScreen initializes
        Future.microtask(() {
        ref.read(userNotifierProvider.notifier).loadUserFromStorage();
        });
    }
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User ID: ${user.id}', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Role: ${user.role}', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('email: ${user.email}', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('email: ${user.profile.fullName}', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),

                  
                ],
              ),
            ),
    );
  }
}

    
