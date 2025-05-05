import 'package:agawin_unievent_app/bloc/main_bloc/crud_bloc.dart';
import 'package:agawin_unievent_app/cubit/project_cubit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrganizationForms extends StatelessWidget {
  final String? name;
  final String? nickName;
  final String? category;
  final String? email;
  final String? facebook;

  const OrganizationForms({
    super.key,
    this.name,
    this.nickName,
    this.category,
    this.email,
    this.facebook,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final nameController = TextEditingController();
    final nickNameController = TextEditingController();
    final categoryController = TextEditingController();
    final emailController = TextEditingController();
    final facebookController = TextEditingController();

    return Container(
      padding: EdgeInsets.only(left: 50, right: 50),
      width: size.width,
      height: size.height,
      child: SingleChildScrollView(
        //main column
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //banner
            BlocProvider(
              create: (_) => ImagePickerCubit(),
              child: bannerPicker(size),
            ),
            //names, nickname and category
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      inputField(
                        "Name of Organization Here...",
                        2,
                        Icon(Icons.title),
                        nameController,
                      ),
                      inputField(
                        "Organization Nickname...",
                        1,
                        Icon(Icons.subtitles),
                        nickNameController,
                      ),
                      inputField(
                        "Organization Category...",
                        1,
                        Icon(Icons.type_specimen),
                        categoryController,
                      ),
                    ],
                  ),
                ),
                //logo section
                BlocProvider(
                  create: (context) => ImagePickerCubit(),
                  child: logoPicker(),
                ),
              ],
            ),
            //email and facebook
            Row(
              children: [
                Flexible(
                  flex: 2,
                  child: inputField(
                    "Email Address",
                    1,
                    Icon(Icons.email),
                    emailController,
                  ),
                ),
                SizedBox(width: 30),
                Flexible(
                  flex: 3,
                  child: inputField(
                    "Facebook Link",
                    1,
                    Icon(Icons.book),
                    facebookController,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: submitButton(
                    context,
                    nameController,
                    nickNameController,
                    categoryController,
                    emailController,
                    facebookController,
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text("Cancel"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BlocBuilder<ImagePickerCubit, PlatformFile?> logoPicker() {
    return BlocBuilder<ImagePickerCubit, PlatformFile?>(
      builder: (context, file) {
        return Container(
          width: 500,
          height: 500,
          padding: EdgeInsets.only(left: 40),
          child: Stack(
            children: [
              SizedBox.expand(child: Card(color: Colors.white)),
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () => context.read<ImagePickerCubit>().pickImage(),
                  child:
                      file != null
                          ? Image.memory(file.bytes!, fit: BoxFit.cover)
                          : Icon(Icons.add_a_photo, size: 40),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  BlocBuilder<ImagePickerCubit, PlatformFile?> bannerPicker(Size size) {
    return BlocBuilder<ImagePickerCubit, PlatformFile?>(
      builder: (context, file) {
        return Container(
          width: size.width,
          height: 450,
          padding: EdgeInsets.only(left: 40),
          child: Stack(
            children: [
              SizedBox.expand(child: Card(color: Colors.white)),
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () => context.read<ImagePickerCubit>().pickImage(),
                  child:
                      file != null
                          ? Image.memory(file.bytes!, fit: BoxFit.cover)
                          : Icon(Icons.add_a_photo, size: 40),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ElevatedButton submitButton(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController acronymController,
    TextEditingController categoryController,
    TextEditingController emailController,
    TextEditingController facebookController,
  ) {
    return ElevatedButton(
      onPressed: () {
        final imageFileName = context.read<ImagePickerCubit>().state?.name;
        context.read<ProjectBloc>().add(
          CreateData(
            tableName: 'organizations',
            data: {
              "name": nameController.text,
              "banner": "event_images/$imageFileName",
              "logo": "",
              "acronynm": acronymController.text,
              "category": categoryController.text,
              "email": emailController.text,
              "facebook": facebookController.text,
              "status": "active",
            },
          ),
        );
      },
      child: Text("Submit"),
    );
  }

  TextField inputField(
    String label,
    int lineNum,
    Icon icon,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      maxLines: lineNum,
      decoration: InputDecoration(
        prefixIcon: icon,
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
