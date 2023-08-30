import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/card_custom.dart';
import '../../core/widgets/post.dart';
import '../../data/models/post_model.dart';
import '../../data/models/user_model.dart';
import '../../core/values/colors.dart';
import '../../core/widgets/view_template.dart';

import 'profile_view_model.dart';

class ProfileView extends StatefulWidget {
  final String id;
  const ProfileView({required this.id, super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);

    final viewModel = context.read<ProfileViewModel>();

    viewModel.initView(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    return ViewTemplate(
      widget: Builder(builder: (context) {
        if (viewModel.user == null) {
          return Container();
        }

        return Column(
          children: [
            Image.network(
              viewModel.user!.photoProfile,
              width: 100,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              viewModel.user!.username,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              viewModel.user!.status,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Follower ${viewModel.follow.$1}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Follow ${viewModel.follow.$2}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryLightColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Builder(
                    builder: (context) {
                      if (viewModel.isUserProfile == null) {
                        return Container();
                      }

                      return InkWell(
                        onTap: () {
                          if (viewModel.isUserProfile!) {
                            context.go('/setting');
                          } else {
                            if (!viewModel.isUserFollow) {
                              viewModel.folowUser();
                            } else {
                              viewModel.unfollowUser();
                            }
                          }
                        },
                        child: Builder(
                          builder: (context) {
                            IconData icon;

                            if (viewModel.isUserProfile!) {
                              icon = Icons.settings;
                            } else {
                              if (viewModel.isUserFollow) {
                                icon = Icons.exposure_minus_1;
                              } else {
                                icon = Icons.plus_one;
                              }
                            }
                            return Icon(
                              icon,
                              color: Colors.white,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            if (viewModel.isUserProfile!)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: ElevatedButton(
                  onPressed: () => context.go('/create_post'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryLightColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    'Create Post',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            const SizedBox(
              height: 32,
            ),
            TabBar(
              controller: tabController,
              tabs: const [
                Icon(Icons.article_outlined),
                Icon(Icons.bookmark),
                Icon(Icons.photo_library_outlined),
              ],
            ),
            Expanded(
              child: SizedBox(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    // Post
                    ListView(
                      shrinkWrap: true,
                      primary: false,
                      children: viewModel.posts.map((val) {
                        final PostModel post = val['post'];
                        final UserModel user = val['user'];
                        final bool isLike = val['isLike'];
                        final bool isBookmark = val['isBookmark'];

                        return cardCustom(
                          content: Post(
                            post: post,
                            user: user,
                            isLike: isLike,
                            isBookmark: isBookmark,
                            updateCounterPost: (postId, field) {
                              viewModel.updateCounterPost(postId, field);
                            },
                            deletePost: (uid) {
                              if (uid != post.userId) {
                                viewModel.blockPost(uid: uid, postId: post.id);
                              } else {
                                viewModel.deletePost(post);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    // Bookmark Post
                    Container(),

                    // Gallery
                    GridView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: viewModel.userImages.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          viewModel.userImages[index],
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  ],
                ),
              ),
            )
          ],
        );
      }),
    );
  }
}
