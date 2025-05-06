import 'package:agawin_unievent_app/bloc/main_bloc/crud_bloc.dart';
import 'package:agawin_unievent_app/cubit/project_cubit.dart';
import 'package:agawin_unievent_app/widgets/event_datetime_picker.dart';
import 'package:agawin_unievent_app/widgets/tag_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventForms extends StatelessWidget {
  final List<dynamic> orgList;
  final String? title;
  final String? description;
  final String? location;
  final String? type;
  final String? status;
  final bool? isUpdateData;

  const EventForms({
    super.key,
    required this.orgList,
    this.title,
    this.description,
    this.location,
    this.type,
    this.status,
    this.isUpdateData,
  });

  @override
  Widget build(BuildContext context) {
    final SupabaseClient supabase = Supabase.instance.client;
    final size = MediaQuery.of(context).size;
    final titleController = TextEditingController(text: title);
    final locationController = TextEditingController(text: location);
    final typeController = TextEditingController(text: type);
    final descContoller = TextEditingController(text: description);
    //final statusController = TextEditingController(text: status);
    final formKey = GlobalKey<FormState>();

    return Form(
      key: formKey,
      child: Container(
        padding: EdgeInsets.only(left: 50, right: 50),
        width: size.width,
        height: size.height,
        child: SingleChildScrollView(
          //***main column
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //*titles and such
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        //toggle button
                        toggleVisibilityButton(),
                        //organization dropdownbutton
                        dropDownSelection(),
                        //title field
                        inputField(
                          "Title of Event here",
                          2,
                          Icon(Icons.title),
                          titleController,
                        ),
                        //tags input field
                        TagField(),
                      ],
                    ),
                  ),
                  //image picker widget
                  imagePicker(),
                ],
              ),
              //the rest
              Text(
                "Input the Details of the Event:",
                textAlign: TextAlign.left,
              ),
              Row(
                children: [
                  Flexible(
                    flex: 3,
                    child: inputField(
                      "Location",
                      1,
                      Icon(Icons.pin_drop),
                      locationController,
                    ),
                  ),
                  SizedBox(width: 30),
                  Flexible(
                    flex: 1,
                    child: inputField(
                      "Type",
                      1,
                      Icon(Icons.book),
                      typeController,
                    ),
                  ),
                ],
              ),
              //date start and date end picker
              dateTimePicker(context),
              SizedBox(
                width: size.width,
                height: 300,
                child: inputField(
                  "Description",
                  6,
                  Icon(Icons.edit),
                  descContoller,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: submitButton(
                      formKey,
                      supabase,
                      context,
                      titleController,
                      locationController,
                      descContoller,
                      typeController,
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
      ),
    );
  }

  EventDateRangePicker dateTimePicker(BuildContext context) {
    return EventDateRangePicker(
      startDateController: TextEditingController(),
      endDateController: TextEditingController(),
      onStartChanged:
          (date) => context.read<DateTimeRangeCubit>().setStartDate(date),
      onEndChanged:
          (date) => context.read<DateTimeRangeCubit>().setEndDate(date),
    );
  }

  BlocBuilder<ImagePickerCubit, PlatformFile?> imagePicker() {
    return BlocBuilder<ImagePickerCubit, PlatformFile?>(
      builder: (context, file) {
        return Container(
          width: 500,
          height: 550,
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

  BlocBuilder<DropDownCubit, dynamic> dropDownSelection() {
    return BlocBuilder<DropDownCubit, dynamic>(
      builder: (context, selectedItem) {
        return DropdownButtonFormField<dynamic>(
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          value:
              (selectedItem != null && orgList.contains(selectedItem))
                  ? selectedItem
                  : null,
          iconSize: 40,
          items:
              orgList.map((item) {
                return DropdownMenuItem<dynamic>(
                  value: item,
                  child: Text(item['name']),
                );
              }).toList(),
          onChanged: (item) {
            if (item != null) {
              context.read<DropDownCubit>().selectItem(item);
            }
          },
          isExpanded: true,
        );
      },
    );
  }

  BlocBuilder<ToggleVisibilityCubit, bool> toggleVisibilityButton() {
    return BlocBuilder<ToggleVisibilityCubit, bool>(
      builder: (context, isVisible) {
        return Row(
          children: [
            Text("Toggle Visibility of the Event: "),
            IconButton(
              onPressed: context.read<ToggleVisibilityCubit>().toggle,
              icon: Row(
                children: [
                  Icon(isVisible ? Icons.visibility : Icons.visibility_off),
                  SizedBox(width: 10),
                  Text(isVisible ? "Visible" : "Hidden"),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  TextFormField inputField(
    String label,
    int lineNum,
    Icon icon,
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      maxLines: lineNum,
      decoration: InputDecoration(
        prefixIcon: icon,
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "$label is required";
        }
        return null;
      },
    );
  }

  ElevatedButton submitButton(
    GlobalKey<FormState> formKey,
    SupabaseClient supabase,
    BuildContext context,
    TextEditingController titleController,
    TextEditingController locationController,
    TextEditingController descController,
    TextEditingController typeController,
  ) {
    return ElevatedButton(
      onPressed: () async {
        final selectedOrganization = context.read<DropDownCubit>().state;
        final dateTimeRange = context.read<DateTimeRangeCubit>().state;
        final imageFile = context.read<ImagePickerCubit>().state;
        final tags = context.read<TagInputCubit>().state;
        final toggleVisibility = context.read<ToggleVisibilityCubit>().state;
        final updateToggle =
            isUpdateData ??
            false; //check toggle if the user will either create or update data

        if (formKey.currentState!.validate() &&
            selectedOrganization != null &&
            dateTimeRange.start != null &&
            dateTimeRange.end != null &&
            imageFile != null &&
            (titleController.text.isNotEmpty ||
                titleController.text.trim().isNotEmpty) &&
            (locationController.text.isNotEmpty ||
                locationController.text.trim().isNotEmpty)) {
          if (updateToggle) {
            supabase.storage.from('images').remove(['']);
            context.read<ProjectBloc>().add(
              UpdateData(
                tableName: "events",
                primarykey: 'need to put it first here',
                uid: 'uid',
                updatedData: {},
              ),
            );
          } else {
            supabase.storage
                .from('images')
                .uploadBinary(
                  'event_images/${imageFile.name}',
                  imageFile.bytes!,
                );

            context.read<ProjectBloc>().add(
              CreateData(
                tableName: 'events',
                data: {
                  "orguid": selectedOrganization['uid'],
                  "title": titleController.text,
                  "banner": "event_images/${imageFile.name}",
                  "tags": tags,
                  "type": typeController.text,
                  "location": locationController.text,
                  "description": descController.text,
                  "datetimestart": dateTimeRange.start!.toIso8601String(),
                  "datetimeend": dateTimeRange.end!.toIso8601String(),
                  "status": "pending",
                  "isVisible": toggleVisibility,
                },
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Complete all required fields")),
          );
        }
      },
      child: Text("Submit"),
    );
  }
}
