import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/view_template.dart';
import '../../core/decorations/text_field_decoration.dart';
import '../../core/values/colors.dart';

import 'edit_profile_view_model.dart';

enum Gender { male, female }

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final TextEditingController tecUsername = TextEditingController();
  final TextEditingController tecStatus = TextEditingController();

  @override
  void initState() {
    super.initState();

    final viewModel = context.read<EditProfileViewModel>();

    viewModel.initView();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditProfileViewModel>();

    if (viewModel.user != null) {
      tecUsername.text = viewModel.user!.username;
      tecStatus.text = viewModel.user!.status;
    }

    return ViewTemplate(
      widget: Builder(
        builder: (context) {
          if (viewModel.avatars.isEmpty) {
            return LoadingAnimationWidget.threeArchedCircle(
              color: primaryLightColor,
              size: 40,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(64),
                child: Image.network(
                  viewModel.genderSelect == Gender.male
                      ? viewModel.avatars[1]
                      : viewModel.avatars[0],
                  fit: BoxFit.cover,
                  width: 100,
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              TextFormField(
                controller: tecUsername,
                maxLength: 16,
                decoration: TextFieldDecoration.filled(hint: 'Username'),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: tecStatus,
                maxLines: 2,
                maxLength: 128,
                decoration: TextFieldDecoration.filled(hint: 'Status'),
              ),
              const SizedBox(
                height: 16,
              ),
              Wrap(
                children: [
                  const Text('Gender : '),
                  ListTile(
                    title: const Text('Male'),
                    leading: Radio<Gender>(
                      value: Gender.male,
                      groupValue: viewModel.genderSelect,
                      onChanged: (value) {
                        viewModel.setGenderSelect(value!);
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Female'),
                    leading: Radio<Gender>(
                      value: Gender.female,
                      groupValue: viewModel.genderSelect,
                      onChanged: (value) {
                        viewModel.setGenderSelect(value!);
                      },
                    ),
                  )
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  viewModel.saveUser(
                    username: tecUsername.text.trim(),
                    status: tecStatus.text.trim(),
                    callbackSuccess: () => context.go('/'),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryLightColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
