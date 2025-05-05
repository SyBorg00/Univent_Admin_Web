import 'package:agawin_unievent_app/bloc/main_bloc/crud_bloc.dart';
import 'package:agawin_unievent_app/cubit/project_cubit.dart';
import 'package:agawin_unievent_app/widgets/event_datetime_picker.dart';
import 'package:agawin_unievent_app/widgets/tag_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventForms extends StatelessWidget {
  final List<dynamic> orgList;
  final String? title;
  final String? description;
  final String? location;
  final String? type;
  final String? status;
  final List<String>? tags;

  const EventForms({
    super.key,
    required this.orgList,
    this.title,
    this.description,
    this.location,
    this.type,
    this.status,
    this.tags,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final titleController = TextEditingController(text: title);
    final locationController = TextEditingController(text: location);
    final typeController = TextEditingController(text: type);
    final descContoller = TextEditingController(text: description);
    final statusController = TextEditingController(text: status);

    return Container(
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
                      //visibility toggle button

                      //organization dropdownbutton
                      BlocBuilder<DropDownCubit, dynamic>(
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
                                (selectedItem != null &&
                                        orgList.contains(selectedItem))
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
                      ),
                      //title field
                      inputField(
                        "Title of Event here",
                        2,
                        Icon(Icons.title),
                        titleController,
                      ),
                      //tags field
                      TagField(),
                    ],
                  ),
                ),
                //image picker widget
                BlocBuilder<ImagePickerCubit, PlatformFile?>(
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
                              onTap:
                                  () =>
                                      context
                                          .read<ImagePickerCubit>()
                                          .pickImage(),
                              child:
                                  file != null
                                      ? Image.memory(
                                        file.bytes!,
                                        fit: BoxFit.cover,
                                      )
                                      : Icon(Icons.add_a_photo, size: 40),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            //the rest
            Text("Input the Details of the Event:", textAlign: TextAlign.left),
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
            EventDateRangePicker(
              startDateController: TextEditingController(),
              endDateController: TextEditingController(),
              onStartChanged:
                  (date) =>
                      context.read<DateTimeRangeCubit>().setStartDate(date),
              onEndChanged:
                  (date) => context.read<DateTimeRangeCubit>().setEndDate(date),
            ),
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
    );
  }

  ElevatedButton submitButton(
    BuildContext context,
    TextEditingController titleController,
    TextEditingController locationController,
    TextEditingController descController,
    TextEditingController typeController,
  ) {
    return ElevatedButton(
      onPressed: () {
        final imageFileName = context.read<ImagePickerCubit>().state?.name;
        context.read<ProjectBloc>().add(
          CreateData(
            tableName: 'events',
            data: {
              "orguid": context.read<DropDownCubit>().state['orguid'],
              "title": titleController.text,
              "banner": "event_images/$imageFileName",
              "tags": context.read<TagInputCubit>().state,
              "location": locationController.text,
              "description": descController.text,
              "type": typeController.text,
              "datetimestart":
                  context
                      .read<DateTimeRangeCubit>()
                      .state
                      .start!
                      .toIso8601String(),
              "datetimeend":
                  context
                      .read<DateTimeRangeCubit>()
                      .state
                      .end!
                      .toIso8601String(),
              "status": "pending",
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
