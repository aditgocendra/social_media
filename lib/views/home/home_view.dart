import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/post.dart';
import '../../core/widgets/card_custom.dart';
import '../../core/widgets/view_template.dart';

import '../../data/models/post_model.dart';
import '../../data/models/user_model.dart';

import 'home_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();

    final viewModel = context.read<HomeViewModel>();
    viewModel.initView();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return ViewTemplate(
      widget: Builder(
        builder: (context) {
          if (viewModel.isLoading) {
            return const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.postUsers.isEmpty) return Container();

          return ListView(
            children: viewModel.postUsers.map(
              (val) {
                PostModel post = val['post'];
                UserModel user = val['user'];
                bool isLike = val['isLike'];
                bool isBookmark = val['isBookmark'];

                return cardCustom(
                  content: Post(
                    post: post,
                    user: user,
                    isLike: isLike,
                    isBookmark: isBookmark,
                    updateCounterPost: (postId, field) =>
                        viewModel.updateCounterPost(
                      postId,
                      field,
                    ),
                    deletePost: (uid) {
                      if (uid != post.userId) {
                        viewModel.blockPost(uid: uid, postId: post.id);
                      } else {
                        viewModel.deletePost(post);
                      }
                    },
                  ),
                );
              },
            ).toList(),
          );
        },
      ),
    );
  }
}
