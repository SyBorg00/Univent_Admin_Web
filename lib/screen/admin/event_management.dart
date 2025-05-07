import 'package:agawin_unievent_app/bloc/main_bloc/crud_bloc.dart';
import 'package:agawin_unievent_app/cubit/image_picker.dart';
import 'package:agawin_unievent_app/cubit/project_cubit.dart';
import 'package:agawin_unievent_app/screen/admin/admin_dashboard.dart';
import 'package:agawin_unievent_app/widgets/event_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//inserting new events
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
        BlocProvider(
          create: (_) => DropDownCubit("Please select an organization first"),
        ),
        BlocProvider(create: (_) => TagInputCubit()),
        BlocProvider(create: (_) => DateTimeRangeCubit()),
        BlocProvider(create: (_) => ImagePickerCubit()),
        BlocProvider(create: (_) => ToggleVisibilityCubit(true)),
      ],
      //bloclistener to handle state of form submission
      child: BlocListener<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Your Process Is Successful!")),
            );
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
        child: Scaffold(
          drawer: Drawer(),
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 22, 17, 177),
            title: Text("Event Manager"),
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
                return EventForms(
                  orgList: state.data,
                  uid: currentEvent?['uid'],
                  title: currentEvent?['title'],
                  location: currentEvent?['location'],
                  status: currentEvent?['status'],
                  type: currentEvent?['type'],
                  description: currentEvent?['description'],
                  isUpdateData: isUpdateData,
                );
              } else if (state is ProjectError) {
                return Center();
              }
              return SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
