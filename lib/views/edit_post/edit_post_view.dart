import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/decorations/text_field_decoration.dart';
import '../../core/utils/image_picker.dart';
import '../../core/values/colors.dart';
import '../../core/widgets/view_template.dart';

import '../create_post/widgets.dart';
import 'edit_post_view_model.dart';

class EditPostView extends StatefulWidget {
  final String postId;
  const EditPostView({required this.postId, super.key});

  @override
  State<EditPostView> createState() => _EditPostViewState();
}

class _EditPostViewState extends State<EditPostView> {
  late TextEditingController tecTags, tecCaption;

  @override
  void initState() {
    super.initState();

    tecTags = TextEditingController();
    tecCaption = TextEditingController();

    final viewModel = context.read<EditPostViewModel>();
    viewModel.initView(widget.postId);
  }

  @override
  void dispose() {
    super.dispose();

    tecTags.dispose();
    tecCaption.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditPostViewModel>();

    return ViewTemplate(
      widget: Builder(builder: (context) {
        if (viewModel.post == null) {
          return Container();
        }

        tecCaption.text = viewModel.post!.caption;

        return Column(
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...viewModel.imageContent.map(
                        (val) {
                          return Container(
                            margin: const EdgeInsets.all(4),
                            width: 100,
                            height: 100,
                            child: Stack(
                              children: [
                                Align(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Builder(
                                      builder: (context) {
                                        if (val.runtimeType == String) {
                                          return Image.network(
                                            val,
                                            fit: BoxFit.cover,
                                          );
                                        }
                                        return Image.memory(val);
                                      },
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    onPressed: () {
                                      viewModel.removeImagePicked(val);
                                    },
                                    icon: Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                      Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: InkWell(
                          onTap: () async {
                            final r = await pickerImageWeb();

                            viewModel.addImagePicked(r!);
                          },
                          child: Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 40,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            TextField(
              controller: tecCaption,
              maxLines: 5,
              style: const TextStyle(fontSize: 14),
              decoration: TextFieldDecoration.filled(
                hint: 'Caption',
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    children: viewModel.post!.tags.map((val) {
                      return tagWidget(
                        val,
                        () => viewModel.removeTag(val),
                      );
                    }).toList(),
                  ),
                  TextField(
                    controller: tecTags,
                    decoration: const InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: 'Tags (Optional)',
                    ),
                    style: const TextStyle(fontSize: 14),
                    onSubmitted: (value) {
                      if (value.isEmpty) return;

                      viewModel.addTag(value);
                      tecTags.clear();
                    },
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Builder(
              builder: (context) {
                if (viewModel.isLoading) {
                  return const CircularProgressIndicator();
                }

                return ElevatedButton(
                  onPressed: () => {
                    viewModel.updatePost(
                      caption: tecCaption.text.trim(),
                      callbackSuccess: () => context.go('/'),
                    )
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryLightColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    'Edit Post',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            )
          ],
        );
      }),
    );
  }
}
