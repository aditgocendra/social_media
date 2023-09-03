import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media/auth_state.dart';
import '../extension/datetime_extension.dart';
import '../../data/models/post_model.dart';
import '../../data/models/user_model.dart';

import '../values/colors.dart';

class Post extends StatelessWidget {
  final PostModel post;
  final UserModel user;
  final bool isLike;
  final bool isBookmark;
  final Function(
    String postId,
    String field,
  ) updateCounterPost;
  final Function(
    String uid,
  ) deletePost;

  const Post({
    super.key,
    required this.post,
    required this.user,
    required this.isLike,
    required this.isBookmark,
    required this.deletePost,
    required this.updateCounterPost,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          leading: InkWell(
            onTap: () {
              context.go('/profile/${user.id}');
            },
            child: Image.network(
              user.photoProfile,
              width: 40,
            ),
          ),
          title: Text(
            user.username,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          subtitle: Text(
            post.createdAt.dMMMyFormat(),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade400,
            ),
          ),
          trailing: Wrap(
            children: [
              if (authState.userData!.id == post.userId)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: InkWell(
                    onTap: () {
                      context.go('/edit_post/${post.id}');
                    },
                    child: const Icon(
                      Icons.edit,
                      size: 19,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  onTap: () {
                    deletePost(authState.userData!.id);
                  },
                  child: const Icon(
                    Icons.close,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ReadMoreText(
            post.caption,
            trimLines: 4,
            preDataTextStyle: const TextStyle(fontWeight: FontWeight.w500),
            style: const TextStyle(color: Colors.black),
            colorClickableText: primaryLightColor,
            trimMode: TrimMode.Line,
            trimCollapsedText: 'Show more',
            trimExpandedText: ' show less',
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            return InkWell(
              hoverColor: Colors.transparent,
              onTap: () {
                context.go('/post/${post.id}');
              },
              child: CarouselSlider(
                items: post.content
                    .map(
                      (val) => SizedBox(
                        width: width,
                        height: width,
                        child: Image.network(
                          val,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    )
                    .toList(),
                options: CarouselOptions(
                  height: width,
                  viewportFraction: 1.0,
                  initialPage: 0,
                  reverse: false,
                  autoPlay: true,
                  enableInfiniteScroll: false,
                  autoPlayInterval: const Duration(seconds: 12),
                  autoPlayAnimationDuration: const Duration(milliseconds: 600),
                  autoPlayCurve: Curves.fastOutSlowIn,
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  updateCounterPost(post.id, 'likes');
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.volunteer_activism_rounded,
                      size: 20,
                      color: isLike ? primaryLightColor : Colors.grey.shade700,
                    ),
                    Text(
                      post.counter['likes'] == 0
                          ? ''
                          : ' (${post.counter['likes']})',
                      style: TextStyle(
                        color:
                            isLike ? primaryLightColor : Colors.grey.shade700,
                      ),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  context.go('/post/${post.id}');
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.wysiwyg,
                      size: 20,
                      color: Colors.grey.shade700,
                    ),
                    Text(
                      post.counter['comments'] == 0
                          ? ''
                          : ' (${post.counter['comments']})',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  updateCounterPost(post.id, 'bookmarks');
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.bookmarks,
                      size: 20,
                      color:
                          isBookmark ? primaryLightColor : Colors.grey.shade700,
                    ),
                    Text(
                      post.counter['bookmarks'] == 0
                          ? ''
                          : ' (${post.counter['bookmarks']})',
                      style: TextStyle(
                        color: isBookmark ? primaryColor : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget deleteAction(BuildContext context, delete) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        width: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Delete Post',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const Text('Are you sure delete this post ?'),
            const SizedBox(
              height: 24,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    delete();
                  },
                  child: const Text('Yes'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
