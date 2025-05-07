import 'package:agawin_unievent_app/bloc/main_bloc/crud_bloc.dart';
import 'package:agawin_unievent_app/cubit/project_cubit.dart';
import 'package:agawin_unievent_app/screen/admin/admin_dashboard.dart';
import 'package:agawin_unievent_app/screen/admin/event_management.dart';
import 'package:agawin_unievent_app/screen/admin/event_screen.dart';
import 'package:agawin_unievent_app/screen/admin/organization_management.dart';
import 'package:agawin_unievent_app/screen/admin/organization_screen.dart';
import 'package:agawin_unievent_app/widgets/event_card.dart';
import 'package:agawin_unievent_app/widgets/univent_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrganizationMainPage extends StatelessWidget {
  final String? orgUid;
  final List<dynamic>? orgEvents;
  const OrganizationMainPage({super.key, this.orgEvents, this.orgUid});

  @override
  Widget build(BuildContext context) {
    final SupabaseClient supabase = Supabase.instance.client;
    final size = MediaQuery.of(context).size;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (_) =>
                  ProjectBloc()..add(
                    LoadProject(
                      tableName: 'organizations',
                      query: "*,events(*)",
                      foreignKeyColumn: "uid",
                      foreignKeyValue: orgUid,
                    ),
                  ),
        ),
        BlocProvider(create: (_) => NavigationCubit()),
      ],
      child: Scaffold(
        body: Row(
          children: [
            sidebar(context),
            Flexible(child: mainContentSide(size, context, supabase)),
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
              if (state.data.isEmpty) {
                return const Center(
                  child: Text("No events can be found in this organization"),
                );
              }
              final eventList =
                  (state.data['events'] as List)
                      .map((e) => e as Map<String, dynamic>)
                      .toList();
              final logo = state.data['logo'];
              //final banner = state.data['banner'];

              return Stack(
                children: [
                  Container(
                    color: Colors.white,
                    width: size.width,
                    height: size.height * .9,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 56,
                            mainAxisSpacing: 36,
                            childAspectRatio: 4 / 3,
                          ),
                      itemCount: eventList.length,
                      itemBuilder: (context, index) {
                        final event = eventList[index];
                        final DateTime eventDate = DateTime.parse(
                          event['datetimestart'],
                        );

                        return eventCards(
                          context,
                          event,
                          supabase,
                          logo,
                          eventDate,
                        );
                      },
                    ),
                  ),
                  Positioned(
                    right: 40,
                    bottom: 40,
                    child: FloatingActionButton.large(
                      elevation: 60,
                      tooltip: "Add A New Event to this Organization",
                      shape: CircleBorder(),
                      backgroundColor: Color.fromARGB(255, 4, 3, 84),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    EventManagement(isUpdateData: false),
                          ),
                        );
                      },
                      child: Icon(Icons.add, color: Colors.white, size: 60),
                    ),
                  ),
                  Positioned(
                    right: 160,
                    bottom: 40,
                    child: FloatingActionButton.large(
                      elevation: 60,
                      tooltip: "Edit this Organization",
                      shape: CircleBorder(),
                      backgroundColor: Color.fromARGB(255, 4, 3, 84),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    UpdateOrganization(orgInfo: state.data),
                          ),
                        );
                      },
                      child: Icon(Icons.edit, color: Colors.white, size: 60),
                    ),
                  ),
                ],
              );
            } else if (state is ProjectError) {}
            return SizedBox();
          },
        ),
      ],
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

  InkWell eventCards(
    BuildContext context,
    event,
    SupabaseClient supabase,
    logo,
    DateTime eventDate,
  ) {
    final tags = event['tags'] as List<dynamic>;
    return InkWell(
      onTap: () {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: "Dismiss",
          pageBuilder:
              (context, animation, secondAnim) => EventScreen(events: event),
          transitionBuilder: (context, animation, secondAnim, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            );

            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-0.3, 0.0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
      },
      child: EventCard(
        avatar: CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(
            supabase.storage.from('images').getPublicUrl(logo),
          ),
        ),
        banner: Image.network(
          width: double.maxFinite,
          fit: BoxFit.cover,
          supabase.storage.from('images').getPublicUrl(event['banner']),
        ),
        eventDate: eventDate,
        title: event['title'],
        tags: tags, //event['tags'],
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
