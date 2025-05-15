import 'package:agawin_unievent_app/bloc/main_bloc/crud_bloc.dart';
import 'package:agawin_unievent_app/cubit/event_datetimerange_cubit.dart';
import 'package:agawin_unievent_app/cubit/image_picker_cubit.dart';
import 'package:agawin_unievent_app/cubit/project_cubit.dart';
import 'package:agawin_unievent_app/widgets/event_datetime_picker.dart';
import 'package:agawin_unievent_app/widgets/tag_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventForms extends StatelessWidget {
  final List<dynamic> orgList;
  final String? uid;
  final String? title;
  final String? description;
  final String? bannerPath;
  final String? location;
  final String? type;
  final String? status;
  final bool isUpdateData;
  final DropDownCubit? dropDownCubit;
  final ImagePickerCubit? bannerCubit;
  final DateTimeRangeCubit? dateTimeRangeCubit;
  final ToggleButtonCubit toggleButton;

  const EventForms({
    super.key,
    required this.orgList,
    this.uid,
    this.title,
    this.description,
    this.bannerPath,
    this.location,
    this.type,
    this.status,
    required this.isUpdateData,
    required this.toggleButton,
    this.dropDownCubit,
    this.dateTimeRangeCubit,
    this.bannerCubit,
  });

  @override
  Widget build(BuildContext context) {
    final SupabaseClient supabase = Supabase.instance.client;
    final size = MediaQuery.of(context).size;
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: title);
    final locationController = TextEditingController(text: location);
    final typeController = TextEditingController(text: type);
    final descContoller = TextEditingController(text: description);
    //final statusController = TextEditingController(text: status);

    return Form(
      key: formKey,
      child: Container(
        padding: EdgeInsets.all(30),
        width: size.width,
        height: size.height,
        child: SingleChildScrollView(
          //***main body
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //*titles, visbility toggle, tags, organization and banner
              Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: upperField(titleController),
              ),
              //**Additional detail sections...
              Text(
                "Input the Details of the Event:",
                textAlign: TextAlign.left,
              ),
              //location and type field
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    Flexible(
                      flex: 3,
                      child: requiredField(
                        "Location",
                        1,
                        Icon(Icons.pin_drop),
                        locationController,
                      ),
                    ),
                    SizedBox(width: 30),
                    Flexible(
                      flex: 1,
                      child: requiredField(
                        "Type",
                        1,
                        Icon(Icons.book),
                        typeController,
                      ),
                    ),
                  ],
                ),
              ),
              //date start and date end picker
              Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: dateTimePicker(),
              ),

              //description field
              SizedBox(
                width: size.width,
                height: 300,
                child: optionalField(
                  "Description",
                  6,
                  Icon(Icons.edit),
                  descContoller,
                ),
              ),

              //submit and cancel buttons
              Row(
                children: [
                  Expanded(
                    child: submitButton(
                      supabase,
                      formKey,
                      context,
                      titleController,
                      locationController,
                      descContoller,
                      typeController,
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
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

  Row upperField(TextEditingController titleController) {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              //toggle button
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: toggleVisibilityButton(),
              ),
              //organization dropdownbutton
              Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: organizationSelection(),
              ),

              //title field
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: requiredField(
                  "Title of Event here",
                  3,
                  Icon(Icons.title),
                  titleController,
                ),
              ),
              //tags input field
              Padding(padding: EdgeInsets.only(bottom: 20), child: TagField()),
            ],
          ),
        ),
        //banner image picker
        Padding(padding: EdgeInsets.only(left: 30), child: bannerPicker()),
      ],
    );
  }

  BlocBuilder<DateTimeRangeCubit, EventDateTimeRange?> dateTimePicker() {
    return BlocBuilder<DateTimeRangeCubit, EventDateTimeRange?>(
      bloc: dateTimeRangeCubit,
      builder: (context, dateTimeRange) {
        return EventDateRangePicker(
          startDateController: TextEditingController(
            text:
                isUpdateData
                    ? DateFormat.yMMMd().add_jm().format(dateTimeRange!.end!)
                    : null,
          ),
          endDateController: TextEditingController(
            text:
                isUpdateData
                    ? DateFormat.yMMMd().add_jm().format(dateTimeRange!.start!)
                    : null,
          ),
          onStartChanged: (date) => dateTimeRangeCubit?.updateStart(date),
          onEndChanged: (date) => dateTimeRangeCubit?.updateEnd(date),
        );
      },
    );
  }

  BlocBuilder<ImagePickerCubit, PlatformFile?> bannerPicker() {
    return BlocBuilder<ImagePickerCubit, PlatformFile?>(
      bloc: bannerCubit,
      builder: (context, file) {
        return GestureDetector(
          onTap: () => bannerCubit?.pickImage(),
          child: Container(
            width: 300,
            height: 350,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            padding: EdgeInsets.only(left: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child:
                  file != null
                      ? Image.memory(file.bytes!, fit: BoxFit.cover)
                      : Icon(Icons.add_a_photo, size: 50),
            ),
          ),
        );
      },
    );
  }

  BlocBuilder<DropDownCubit, dynamic> organizationSelection() {
    return BlocBuilder<DropDownCubit, dynamic>(
      bloc: dropDownCubit,
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
          value: selectedItem,
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
              dropDownCubit?.selectItem(item);
            }
          },
          isExpanded: true,
        );
      },
    );
  }

  BlocBuilder<ToggleButtonCubit, bool> toggleVisibilityButton() {
    return BlocBuilder<ToggleButtonCubit, bool>(
      builder: (context, isVisible) {
        return Row(
          children: [
            Text("Set This Event as Visible: "),
            Switch(
              value: isVisible,
              onChanged: (_) => context.read<ToggleButtonCubit>().toggle(),
            ),
          ],
        );
      },
    );
  }

  TextFormField requiredField(
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

  TextField optionalField(
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

  ElevatedButton submitButton(
    SupabaseClient supabase,
    GlobalKey<FormState> formKey,
    BuildContext context,
    TextEditingController titleController,
    TextEditingController locationController,
    TextEditingController descController,
    TextEditingController typeController,
  ) {
    return ElevatedButton(
      onPressed: () async {
        final selectedOrganization = dropDownCubit?.state;
        final dateTimeRange = context.read<DateTimeRangeCubit>().state;
        final imageFile = bannerCubit?.state;
        final tags = context.read<TagInputCubit>().state;
        final toggledVisibility = toggleButton.state;

        //initial checking
        if (formKey.currentState!.validate() &&
            selectedOrganization != null &&
            dateTimeRange?.start != null &&
            dateTimeRange?.end != null &&
            imageFile != null &&
            (titleController.text.isNotEmpty ||
                titleController.text.trim().isNotEmpty) &&
            (locationController.text.isNotEmpty ||
                locationController.text.trim().isNotEmpty)) {
          //check if it is about updating the data or not
          if (isUpdateData) {
            //supabase.storage.from('images').remove([]);
            supabase.storage
                .from('images')
                .uploadBinary(
                  'event_images/${imageFile.name}',
                  imageFile.bytes!,
                );
            context.read<ProjectBloc>().add(
              UpdateData(
                tableName: "events",
                primarykey: "uid",
                uid: uid!,
                updatedData: {
                  "orguid": selectedOrganization['uid'],
                  "title": titleController.text,
                  "banner": "event_images/${imageFile.name}",
                  "tags": tags,
                  "type": typeController.text,
                  "location": locationController.text,
                  "description": descController.text,
                  "datetimestart": dateTimeRange?.start!.toIso8601String(),
                  "datetimeend": dateTimeRange?.end!.toIso8601String(),
                  "status": "pending",
                  "isVisible": toggledVisibility,
                },
              ),
            );
            //else will insert data to the database instead
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
                  "datetimestart": dateTimeRange?.start!.toIso8601String(),
                  "datetimeend": dateTimeRange?.end!.toIso8601String(),
                  "status": "pending",
                  "isVisible": toggledVisibility,
                },
              ),
            );
          }
          //specific handling for the banner selection
        } else if (imageFile == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Please select the Banner")));

          //specific handling for the organization selection
        } else if (selectedOrganization == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please select the organization")),
          );
          //general handling for all required fields
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
