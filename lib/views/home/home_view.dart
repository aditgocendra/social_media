import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:social_media/core/values/colors.dart';

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
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final viewModel = context.read<HomeViewModel>();
    viewModel.initView();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        final PostModel post = viewModel.postUsers.last['post'];
        viewModel.setPost(post.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return ViewTemplate(
      widget: Builder(
        builder: (context) {
          return ListView(
            controller: scrollController,
            children: [
              ...viewModel.postUsers.map(
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
              if (viewModel.isLoading)
                LoadingAnimationWidget.threeArchedCircle(
                  color: primaryLightColor,
                  size: 40,
                )
            ],
          );
        },
      ),
    );
  }
}
