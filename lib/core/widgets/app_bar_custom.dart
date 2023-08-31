import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_media/auth_state.dart';
import 'package:social_media/core/values/colors.dart';

import '../decorations/text_field_decoration.dart';

class AppBarCustom extends StatelessWidget {
  final String? query;
  const AppBarCustom({this.query, super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController tecSearch = TextEditingController();
    final authState = context.watch<AuthState>();

    final sizeWidth = MediaQuery.of(context).size.width;

    tecSearch.text = query != null ? query! : '';

    if (authState.userData == null) {
      return Container();
    }

    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0.5,
      shadowColor: Colors.grey.shade500,
      flexibleSpace: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 32,
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      context.go('/');
                    },
                    child: Image.asset('assets/logo/logo-n.png'),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: sizeWidth > 720 ? 1 : 3,
              child: TextField(
                controller: tecSearch,
                onSubmitted: (value) {
                  if (tecSearch.text.isEmpty) return;
                  context.push(
                    '/search?query=${tecSearch.text.toLowerCase().trim()}',
                  );
                },
                style: const TextStyle(fontSize: 14),
                decoration: TextFieldDecoration.filled(
                  hint: 'Search Something',
                  suffix: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: primaryLightColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: InkWell(
                      onTap: () {
                        if (tecSearch.text.isEmpty) return;

                        context.push(
                          '/search?query=${tecSearch.text.toLowerCase().trim()}',
                        );
                      },
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      context.go('/profile/${authState.userData!.id}');
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(64),
                      child: Image.network(
                        authState.userData!.photoProfile,
                        fit: BoxFit.cover,
                        width: 40,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
