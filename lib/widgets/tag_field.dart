import 'package:agawin_unievent_app/cubit/project_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TagField extends StatelessWidget {
  final String hintText;
  const TagField({super.key, this.hintText = "Add a Tag..."});

  void _onSubmitted(BuildContext context, String val) {
    context.read<TagInputCubit>().addTag(val);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TagInputCubit, List<dynamic>>(
      builder: (context, tags) {
        return Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: [
            ...tags.map(
              (tag) => Chip(
                label: Text(tag),
                deleteIcon: Icon(Icons.close, size: 20),
                onDeleted: () => context.read<TagInputCubit>().removeTag(tag),
              ),
            ),
            TextField(
              onSubmitted: (val) => _onSubmitted(context, val),
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );
      },
    );
  }
}
