import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_media/auth_state.dart';
import '../../core/widgets/view_template.dart';

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthState>();

    return ViewTemplate(
      widget: Column(
        children: [
          ListTile(
            onTap: () {
              context.go('/edit_profile');
            },
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.edit_sharp),
          ),
          const SizedBox(
            height: 8,
          ),
          ListTile(
            onTap: () {
              authState.onSignedOut();
              context.go('/sign_in');
            },
            title: const Text('Sign Out'),
            trailing: const Icon(Icons.logout),
          )
        ],
      ),
    );
  }
}
