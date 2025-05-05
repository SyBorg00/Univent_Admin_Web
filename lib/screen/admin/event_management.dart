import 'package:agawin_unievent_app/bloc/main_bloc/crud_bloc.dart';
import 'package:agawin_unievent_app/cubit/project_cubit.dart';
import 'package:agawin_unievent_app/screen/admin/admin_dashboard.dart';
import 'package:agawin_unievent_app/widgets/event_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//creating events
class CreateEvent extends StatelessWidget {
  const CreateEvent({super.key});

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
        BlocProvider(create: (_) => DropDownCubit()),
        BlocProvider(create: (_) => TagInputCubit()),
        BlocProvider(create: (_) => DateTimeRangeCubit()),
        BlocProvider(create: (_) => ImagePickerCubit()),
      ],
      child: BlocListener<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectSuccess) {
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
            title: Text("Event Management"),
          ),
          body: BlocBuilder<ProjectBloc, ProjectState>(
            builder: (context, state) {
              if (state is ProjectLoading) {
                return Center();
              } else if (state is ProjectLoaded) {
                return EventForms(orgList: state.data);
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

//Upadating the events
class UpdateEvent extends StatelessWidget {
  const UpdateEvent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
