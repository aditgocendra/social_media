import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_media/views/edit_post/edit_post_view_model.dart';
import 'package:social_media/views/search/search_view_model.dart';

import 'core/values/colors.dart';

import 'data/service/user_service.dart';
import 'data/service/post_service.dart';
import 'data/service/tag_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'views/edit_profile/edit_profile_view_model.dart';
import 'views/sign_up/sign_up_view_model.dart';
import 'views/sign_in/sign_in_view_model.dart';
import 'views/create_post/create_post_view_model.dart';
import 'views/home/home_view_model.dart';
import 'views/profile/profile_view_model.dart';
import 'views/post/post_view_model.dart';

import 'auth_state.dart';
import 'routes.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting();

  GoRouter.optionURLReflectsImperativeAPIs = true;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final UserService userService = UserServiceImpl();
    final PostService postService = PostServiceImpl();
    final TagService tagService = TagServiceImpl();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthState(userService: userService),
        ),
        ChangeNotifierProvider(
          create: (context) => SignInViewModel(userService: userService),
        ),
        ChangeNotifierProvider(
          create: (context) => SignUpViewModel(userService: userService),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeViewModel(
            userService: userService,
            postService: postService,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileViewModel(
            userService: userService,
            postService: postService,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => EditProfileViewModel(
            userService: userService,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CreatePostViewModel(
            userService: userService,
            postService: postService,
            tagService: tagService,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => PostViewModel(
            postService: postService,
            userService: userService,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => SearchViewModel(
            postService: postService,
            userService: userService,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => EditPostViewModel(
            postService: postService,
          ),
        )
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'Social Media',
            debugShowCheckedModeBanner: false,
            scrollBehavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: primaryLightColor),
              useMaterial3: true,
            ),
            routerConfig: setRouter(context),
          );
        },
      ),
    );
  }
}

class NoThumbScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
      };
}
