import 'package:agawin_unievent_app/cubit/project_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UniventSidebar extends StatelessWidget {
  final List<Widget> items;
  final double? width;
  final Widget? logo;
  final Color? backgroundColor;
  final Color? listColor;
  final void Function(int index) onSelectedTab;

  const UniventSidebar({
    super.key,
    this.logo,
    this.width,
    this.backgroundColor,
    this.listColor,
    required this.onSelectedTab,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (_) => NavigationCubit(),
      child: BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, state) {
          final isOpen = state.isOpen;
          return Container(
            width: isOpen ? 250 : 50,
            height: size.height,
            color: listColor ?? Colors.blueAccent,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => context.read<NavigationCubit>().toggle(),
                    icon: Icon(Icons.menu),
                  ),
                ),
                if (isOpen)
                  for (int i = 0; i < items.length; i++)
                    _buildList(
                      context,
                      i,
                      context.watch<NavigationCubit>().state.index,
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, int index, int selectedIndx) {
    final isSelected = index == selectedIndx;
    return ListTile(
      tileColor: isSelected ? Colors.white : Color.fromARGB(255, 22, 17, 177),
      title: items[index],
      onTap: () {
        context.read<NavigationCubit>().select(index);
        onSelectedTab(index);
      },
    );
  }
}
