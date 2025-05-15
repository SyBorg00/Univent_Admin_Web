import 'package:agawin_unievent_app/bloc/main_bloc/crud_bloc.dart';
import 'package:agawin_unievent_app/cubit/event_datetimerange_cubit.dart';
import 'package:agawin_unievent_app/cubit/image_download_cubit.dart';
import 'package:agawin_unievent_app/cubit/image_picker_cubit.dart';
import 'package:agawin_unievent_app/cubit/project_cubit.dart';
import 'package:agawin_unievent_app/screen/admin/admin_dashboard.dart';
import 'package:agawin_unievent_app/widgets/event_forms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventManagement extends StatelessWidget {
  final bool isUpdateData;
  final Map<String, dynamic>? currentEvent;
  const EventManagement({
    super.key,
    required this.isUpdateData,
    this.currentEvent,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) =>
                  ProjectBloc()..add(
                    LoadProject(tableName: 'organizations', query: 'name, uid'),
                  ),
        ),
        BlocProvider(create: (_) => TagInputCubit()),
        BlocProvider(create: (_) => ToggleButtonCubit(true)),
        if (isUpdateData)
          BlocProvider(
            create:
                (_) =>
                    ImageDownloadCubit()
                      ..downloadImage(currentEvent?['banner']),
          ),
      ],
      //bloclistener to handle states upon form submission
      child: BlocListener<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Process Is Successful!")));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()),
            );
          } else if (state is ProjectError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        //main body
        child: Scaffold(
          drawer: Drawer(),
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 22, 17, 177),
            title: Text("Event Manager", style: TextStyle(color: Colors.white)),
          ),
          body: BlocBuilder<ProjectBloc, ProjectState>(
            builder: (context, state) {
              if (state is ProjectLoading) {
                return Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      Text("Loading Forms... Please Wait"),
                    ],
                  ),
                );
              } else if (state is ProjectLoaded) {
                final orgList = state.data;
                if (isUpdateData) {
                  DateTime? start = DateTime.parse(
                    currentEvent?['datetimestart'],
                  );
                  DateTime? end = DateTime.parse(currentEvent?['datetimeend']);
                  final organization = orgList.firstWhere(
                    (org) => org['uid'] == currentEvent?['orguid'],
                  );
                  //if the admin wants to update events, EventForms w/ paramaters will be called
                  return BlocBuilder<ImageDownloadCubit, PlatformFile?>(
                    builder: (context, file) {
                      return EventForms(
                        orgList: state.data,
                        uid: currentEvent?['uid'],
                        title: currentEvent?['title'],
                        bannerPath: currentEvent?['banner'],
                        location: currentEvent?['location'],
                        status: currentEvent?['status'],
                        type: currentEvent?['type'],
                        description: currentEvent?['description'],
                        isUpdateData: isUpdateData,
                        dateTimeRangeCubit: DateTimeRangeCubit(
                          initDateTime: EventDateTimeRange(
                            start: start,
                            end: end,
                          ),
                        ),
                        bannerCubit: ImagePickerCubit(initImage: file),
                        toggleButton: ToggleButtonCubit(
                          currentEvent?['isVisible'],
                        ),
                        dropDownCubit: DropDownCubit(organization),
                      );
                    },
                  );
                } else {
                  //else, will instead create a new event
                  return EventForms(
                    toggleButton: ToggleButtonCubit(true),
                    bannerCubit: ImagePickerCubit(),
                    dateTimeRangeCubit: DateTimeRangeCubit(),
                    dropDownCubit: DropDownCubit(orgList.first),
                    orgList: orgList,
                    isUpdateData: false,
                  );
                }
              } else if (state is ProjectError) {
                return Center(child: Text(state.message));
              }
              return SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
