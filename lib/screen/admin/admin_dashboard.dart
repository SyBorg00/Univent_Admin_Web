import 'package:agawin_unievent_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:agawin_unievent_app/bloc/main_bloc/crud_bloc.dart';
import 'package:agawin_unievent_app/cubit/project_cubit.dart';
import 'package:agawin_unievent_app/screen/admin/event_management.dart';
import 'package:agawin_unievent_app/screen/admin/event_screen.dart';
import 'package:agawin_unievent_app/screen/admin/organization_screen.dart';
import 'package:agawin_unievent_app/widgets/univent_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agawin_unievent_app/widgets/event_card.dart';

class AdminDashboard extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final SupabaseClient supabase = Supabase.instance.client;
    final size = MediaQuery.of(context).size;

    return MultiBlocProvider(
      providers: [
        //load data from the supabase
        BlocProvider(
          create:
              (_) =>
                  ProjectBloc()..add(
                    LoadProject(
                      tableName: 'events',
                      query: '*, organizations (*)',
                    ),
                  ),
        ),
        //handling the navigation siderail
        BlocProvider(create: (_) => NavigationCubit()),
      ],
      child: Scaffold(
        key: scaffoldKey,
        endDrawer: profileDrawer(),
        body: Row(
          children: [
            sidebar(context),
            Flexible(flex: 2, child: mainContentSide(size, supabase, context)),
          ],
        ),
      ),
    );
  }

  ConstrainedBox profileDrawer() {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 300, maxWidth: 200),

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [ListTile(title: Text("Log Out"))],
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

  Column mainContentSide(
    Size size,
    SupabaseClient supabase,
    BuildContext context,
  ) {
    return Column(
      children: [
        Flexible(
          child: Row(
            children: [
              SizedBox(
                width: 700,
                height: size.height * .05,
                child: SearchBar(),
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.light_mode)),
              IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
              IconButton(
                onPressed: () {
                  scaffoldKey.currentState?.openEndDrawer();
                },
                icon: CircleAvatar(),
              ),
            ],
          ),
        ),
        BlocBuilder<ProjectBloc, ProjectState>(
          builder: (context, state) {
            if (state is ProjectLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProjectLoaded) {
              if (state.data.isEmpty) {
                return const Center(child: Text("No events can be found"));
              }
              return Stack(
                children: [
                  Container(
                    color: Colors.white,
                    width: size.width,
                    height: size.height * .9,
                    child: GridView.builder(
                      padding: EdgeInsets.all(20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 56,
                            mainAxisSpacing: 36,
                            childAspectRatio: 4 / 3,
                          ),
                      itemCount: state.data.length,
                      itemBuilder: (context, index) {
                        final event = state.data[index];

                        final logo = event['organizations']['logo'];
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
                      tooltip: "Add A New Event",
                      shape: CircleBorder(),
                      backgroundColor: Color.fromARGB(255, 4, 3, 84),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateEvent(),
                          ),
                        );
                      },
                      child: Icon(Icons.add, color: Colors.white, size: 60),
                    ),
                  ),
                ],
              );
            } else if (state is ProjectError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              return Center(child: Text(state.message));
            }
            return SizedBox();
          },
        ),
      ],
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

  InkWell eventCards(
    BuildContext context,
    Map<String, dynamic> event,
    SupabaseClient supabase,
    logo,
    DateTime eventDate,
  ) {
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
        tags: "WIP", //event['tags'],
      ),
    );
  }
}
