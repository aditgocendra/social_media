import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/core/widgets/card_custom.dart';
import 'package:social_media/core/widgets/post.dart';
import '../../core/widgets/view_template.dart';
import '../../data/models/post_model.dart';
import '../../data/models/user_model.dart';
import 'search_view_model.dart';

class SearchView extends StatefulWidget {
  final String query;
  const SearchView({required this.query, super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);

    final viewModel = context.read<SearchViewModel>();
    viewModel.initView(widget.query);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SearchViewModel>();
    return ViewTemplate(
      querySearch: widget.query,
      widget: Column(
        children: [
          TabBar(
            controller: tabController,
            tabs: const [
              Icon(Icons.article_outlined),
              Icon(Icons.person_2_outlined),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                ListView(
                  shrinkWrap: true,
                  primary: false,
                  children: viewModel.resultPosts.map((val) {
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
                  }).toList(),
                ),
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: viewModel.users.length,
                  itemBuilder: (context, index) {
                    final user = viewModel.users[index];
                    return cardCustom(
                      content: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              user.photoProfile,
                              width: 64,
                              height: 64,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              user.username,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
