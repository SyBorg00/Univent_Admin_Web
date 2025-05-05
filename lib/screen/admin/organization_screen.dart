import 'package:agawin_unievent_app/bloc/main_bloc/crud_bloc.dart';
import 'package:agawin_unievent_app/cubit/project_cubit.dart';
import 'package:agawin_unievent_app/screen/admin/admin_dashboard.dart';
import 'package:agawin_unievent_app/screen/admin/organization_main_page.dart';
import 'package:agawin_unievent_app/screen/admin/organization_management.dart';
import 'package:agawin_unievent_app/widgets/organization_banner.dart';
import 'package:agawin_unievent_app/widgets/univent_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrganizationScreen extends StatelessWidget {
  const OrganizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SupabaseClient supabase = Supabase.instance.client;
    final size = MediaQuery.of(context).size;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) =>
                  ProjectBloc()
                    ..add(LoadProject(tableName: 'organizations', query: '*')),
        ),
        BlocProvider(create: (_) => NavigationCubit()),
      ],
      child: Scaffold(
        body: Row(
          children: [
            sidebar(context),
            Flexible(flex: 2, child: mainContentSide(size, context, supabase)),
          ],
        ),
      ),
    );
  }

  Column mainContentSide(
    Size size,
    BuildContext context,
    SupabaseClient supabase,
  ) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 700, height: size.height * .05, child: SearchBar()),
            IconButton(onPressed: () {}, icon: Icon(Icons.light_mode)),
            IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
            IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: CircleAvatar(),
            ),
          ],
        ),

        BlocBuilder<ProjectBloc, ProjectState>(
          builder: (context, state) {
            if (state is ProjectLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is ProjectLoaded) {
              return Stack(
                children: [
                  Container(
                    color: Colors.white,
                    width: size.width,
                    height: size.height * .9,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.data.length,
                      itemBuilder: (context, index) {
                        final org = state.data[index];

                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: orgBanner(context, org, supabase),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    right: 40,
                    bottom: 40,
                    child: FloatingActionButton.large(
                      elevation: 60,
                      tooltip: "Add A New Organization",
                      shape: CircleBorder(),
                      backgroundColor: Color.fromARGB(255, 4, 3, 84),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateOrganization(),
                          ),
                        );
                      },
                      child: Icon(Icons.add, color: Colors.white, size: 60),
                    ),
                  ),
                ],
              );
            } else if (state is ProjectError) {
              return Center(child: Text(state.message));
            }
            return SizedBox();
          },
        ),
      ],
    );
  }

  InkWell orgBanner(BuildContext context, org, SupabaseClient supabase) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => OrganizationMainPage(
                  orgUid: org['uid'],
                  orgEvents: org['events'],
                ),
          ),
        );
      },
      child: OrganizationBanner(
        name: org['name'],
        uid: org['uid'],
        email: org['email'],
        facebook: org['facebook'],
        banner: Image.network(
          fit: BoxFit.cover,
          supabase.storage.from('images').getPublicUrl(org['banner']),
        ),
        logo: CircleAvatar(
          radius: 150,
          backgroundImage: NetworkImage(
            supabase.storage.from('images').getPublicUrl(org['logo']),
          ),
        ),
      ),
    );
  }

  UniventSidebar sidebar(BuildContext context) {
    return UniventSidebar(
      items: [
        buttons(Icon(Icons.dashboard), "Dashboard"),
        buttons(Icon(Icons.group), "Organizations"),
        buttons(Icon(Icons.person), "Users"),
      ],
      onSelectedTab: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()),
            );
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrganizationScreen()),
            );
        }
      },
      logo: Column(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Image.asset('images/university_seal_white.png'),
          ),
          Text(
            "UniVents",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Row buttons(Icon icon, String title) {
    return Row(
      children: [
        icon,
        SizedBox(width: 10),
        Text(title, style: TextStyle(color: Colors.white)),
      ],
    );
  }
}
