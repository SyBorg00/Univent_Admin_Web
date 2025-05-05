import 'package:agawin_unievent_app/bloc/main_bloc/crud_bloc.dart';
import 'package:agawin_unievent_app/screen/admin/organization_screen.dart';
import 'package:agawin_unievent_app/widgets/organization_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateOrganization extends StatelessWidget {
  const CreateOrganization({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProjectBloc(),
      child: BlocListener<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OrganizationScreen()),
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
            title: Text("Organization Management"),
          ),
          body: OrganizationForms(),
        ),
      ),
    );
  }
}
