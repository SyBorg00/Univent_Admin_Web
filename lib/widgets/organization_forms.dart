import 'package:agawin_unievent_app/bloc/main_bloc/crud_bloc.dart';
import 'package:agawin_unievent_app/cubit/image_picker_cubit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrganizationForms extends StatelessWidget {
  final String? uid;
  final String? name;
  final String? nickName;
  final String? category;
  final String? email;
  final String? facebook;
  final ImagePickerCubit bannerCubit;
  final ImagePickerCubit logoCubit;
  final bool? isUpdateData;

  const OrganizationForms({
    super.key,
    this.uid,
    this.name,
    this.nickName,
    this.category,
    this.email,
    this.facebook,
    required this.bannerCubit,
    required this.logoCubit,
    this.isUpdateData,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final nameController = TextEditingController(text: name);
    final nickNameController = TextEditingController(text: nickName);
    final categoryController = TextEditingController(text: category);
    final emailController = TextEditingController(text: email);
    final facebookController = TextEditingController(text: facebook);
    final SupabaseClient supabase = Supabase.instance.client;
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
            bannerPicker(size, bannerCubit),
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
                logoPicker(logoCubit),
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
                    supabase,
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

  BlocBuilder<ImagePickerCubit, PlatformFile?> logoPicker(
    ImagePickerCubit logoCubit,
  ) {
    return BlocBuilder<ImagePickerCubit, PlatformFile?>(
      bloc: logoCubit,
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
                  onTap: () => logoCubit.pickImage(),
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

  BlocBuilder<ImagePickerCubit, PlatformFile?> bannerPicker(
    Size size,
    ImagePickerCubit bannerCubit,
  ) {
    return BlocBuilder<ImagePickerCubit, PlatformFile?>(
      bloc: bannerCubit,
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
                  onTap: () => bannerCubit.pickImage(),
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
    SupabaseClient supabase,
  ) {
    return ElevatedButton(
      onPressed: () {
        final logoFile = logoCubit.state;
        final bannerFile = bannerCubit.state;
        final toggledMode = isUpdateData ?? false;

        if (toggledMode) {
          supabase.storage
              .from('images')
              .uploadBinary('logo/${logoFile?.name}', logoFile!.bytes!);
          supabase.storage
              .from('images')
              .uploadBinary('banner/${bannerFile?.name}', bannerFile!.bytes!);
          context.read<ProjectBloc>().add(
            UpdateData(
              tableName: 'organizations',
              primarykey: 'uid',
              uid: uid ?? "",
              updatedData: {
                "name": nameController.text,
                "banner": "banner/${bannerFile.name}",
                "logo": "logo/${logoFile.name}",
                "acronym": acronymController.text,
                "category": categoryController.text,
                "email": emailController.text,
                "facebook": facebookController.text,
                "status": "active",
              },
            ),
          );
        } else {
          supabase.storage
              .from('images')
              .uploadBinary('logo/${logoFile?.name}', logoFile!.bytes!);
          supabase.storage
              .from('images')
              .uploadBinary('banner/${bannerFile?.name}', bannerFile!.bytes!);

          context.read<ProjectBloc>().add(
            CreateData(
              tableName: 'organizations',
              data: {
                "name": nameController.text,
                "banner": "banner/${bannerFile.name}",
                "logo": "logo/${logoFile.name}",
                "acronym": acronymController.text,
                "category": categoryController.text,
                "email": emailController.text,
                "facebook": facebookController.text,
                "status": "active",
              },
            ),
          );
        }
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
