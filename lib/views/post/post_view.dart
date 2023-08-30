import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_media/auth_state.dart';

import '../../data/models/comment_model.dart';
import '../../data/models/user_model.dart';

import '../../core/decorations/text_field_decoration.dart';
import '../../core/values/colors.dart';
import '../../core/widgets/card_custom.dart';
import '../../core/widgets/post.dart';
import '../../core/widgets/view_template.dart';

import 'post_view_model.dart';

class PostView extends StatefulWidget {
  final String postId;
  const PostView({required this.postId, super.key});

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  final TextEditingController tecComment = TextEditingController();

  @override
  void initState() {
    super.initState();

    final viewModel = context.read<PostViewModel>();

    viewModel.initView(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PostViewModel>();
    final authState = context.read<AuthState>();

    if (viewModel.post == null && viewModel.userPost == null) {
      return Container();
    }

    return ViewTemplate(
      widget: ListView(
        children: [
          cardCustom(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Post(
                  post: viewModel.post!,
                  user: viewModel.userPost!,
                  isLike: viewModel.isUserLike,
                  isBookmark: viewModel.isUserBookmark,
                  updateCounterPost: (postId, field) =>
                      viewModel.updateCounterPost(
                    postId,
                    field,
                  ),
                  deletePost: (uid) {
                    if (uid != viewModel.post!.userId) {
                      viewModel.blockPost(uid: uid, postId: viewModel.post!.id);
                    } else {
                      viewModel.deletePost(viewModel.post!);
                    }

                    context.go('/');
                  },
                ),
                Divider(
                  height: 0.5,
                  color: Colors.grey.shade300,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        authState.userData!.photoProfile,
                        width: 40,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: TextField(
                          controller: tecComment,
                          minLines: 1,
                          maxLines: 5,
                          style: const TextStyle(fontSize: 14),
                          decoration: TextFieldDecoration.filled(
                            hint: 'Comments',
                            suffix: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryLightColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: InkWell(
                                onTap: () {
                                  if (tecComment.text.isEmpty) return;

                                  viewModel.createComment(
                                    comment: tecComment.text.trim(),
                                  );

                                  tecComment.clear();
                                },
                                child: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 0.5,
                  color: Colors.grey.shade300,
                ),
                SizedBox(
                  height: 300,
                  child: Builder(builder: (context) {
                    if (viewModel.comments.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'No Comments',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      child: Column(
                        children: viewModel.comments.map((val) {
                          final CommentModel comment = val['comment'];
                          final UserModel user = val['user'];

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.network(
                                  user.photoProfile,
                                  width: 40,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.username,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        comment.comment,
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }),
                ),
                Builder(
                  builder: (context) {
                    final int counterComment =
                        viewModel.post!.counter['comments'] as int;
                    final int commentLength = viewModel.comments.length;

                    if (counterComment - commentLength <= 0) {
                      return Container();
                    }

                    return InkWell(
                      onTap: () async {
                        final CommentModel lastPost =
                            viewModel.comments.last['comment'];

                        await viewModel.setComments(
                          postId: widget.postId,
                          startAfterId: lastPost.id,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Show the other ${counterComment - commentLength} comments',
                          style: const TextStyle(
                            fontSize: 12,
                            color: primaryLightColor,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
