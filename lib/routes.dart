import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_media/views/create_post/create_post_view.dart';
import 'package:social_media/views/edit_post/edit_post_view.dart';
import 'package:social_media/views/post/post_view.dart';
import 'package:social_media/views/search/search_view.dart';
import 'package:social_media/views/setting/setting_view.dart';

import 'views/profile/profile_view.dart';
import 'views/edit_profile/edit_profile_view.dart';
import 'views/home/home_view.dart';
import 'views/sign_in/sign_in_view.dart';
import 'views/sign_up/sign_up_view.dart';

import 'auth_state.dart';

CustomTransitionPage buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

GoRouter setRouter(BuildContext context) {
  final authState = context.watch<AuthState>();

  return GoRouter(
    redirect: (_, state) {
      if (!authState.isSignedIn && state.uri.toString() != '/sign_up') {
        return '/sign_in';
      }

      // if (authState.isLoading) {
      //   return null;
      // }

      if (authState.userData == null && state.uri.toString() != '/sign_up') {
        return '/edit_profile';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeView(),
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const HomeView(),
        ),
      ),
      GoRoute(
        path: '/sign_in',
        builder: (context, state) => SignInView(),
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: SignInView(),
        ),
      ),
      GoRoute(
        path: '/sign_up',
        builder: (context, state) => SignUpView(),
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: SignUpView(),
        ),
      ),
      GoRoute(
        path: '/profile/:id',
        builder: (context, state) => ProfileView(
          id: state.pathParameters['id']!,
        ),
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: ProfileView(id: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/setting',
        builder: (context, state) => const SettingView(),
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const SettingView(),
        ),
      ),
      GoRoute(
        path: '/edit_profile',
        builder: (context, state) => const EditProfileView(),
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const EditProfileView(),
        ),
      ),
      GoRoute(
        path: '/create_post',
        builder: (context, state) => const CreatePostView(),
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const CreatePostView(),
        ),
      ),
      GoRoute(
        path: '/post/:id',
        builder: (context, state) => PostView(
          postId: state.pathParameters['id']!,
        ),
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: PostView(postId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => SearchView(
          query: state.uri.queryParameters['query']!,
        ),
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: SearchView(query: state.uri.queryParameters['query']!),
        ),
      ),
      GoRoute(
        path: '/edit_post/:id',
        builder: (context, state) => EditPostView(
          postId: state.pathParameters['id']!,
        ),
        pageBuilder: (context, state) => buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: EditPostView(postId: state.pathParameters['id']!),
        ),
      )
    ],
  );
}
