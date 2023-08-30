import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/utils/image_picker.dart';
import '../../core/widgets/view_template.dart';
import '../../core/decorations/text_field_decoration.dart';
import '../../core/values/colors.dart';

import 'create_post_view_model.dart';
import 'widgets.dart';

class CreatePostView extends StatefulWidget {
  const CreatePostView({super.key});

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  late TextEditingController tecTags, tecCaption;

  @override
  void initState() {
    super.initState();

    tecTags = TextEditingController();
    tecCaption = TextEditingController();

    final viewModel = context.read<CreatePostViewModel>();
    viewModel.initPage();
  }

  @override
  void dispose() {
    super.dispose();

    tecTags.dispose();
    tecCaption.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreatePostViewModel>();

    return ViewTemplate(
      widget: Column(
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
                    ...viewModel.listImagePicked
                        .map(
                          (val) => Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              image: DecorationImage(
                                image: MemoryImage(
                                  val,
                                  scale: 1.0,
                                ),
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                onPressed: () =>
                                    viewModel.removeImagePicked(val),
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
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
            onSubmitted: (value) {},
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
                  children: viewModel.tags.map((val) {
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
                onPressed: () => viewModel.createPost(
                  caption: tecCaption.text.trim(),
                  callbackSuccess: () => context.go('/'),
                ),
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
              );
            },
          )
        ],
      ),
    );
  }
}
