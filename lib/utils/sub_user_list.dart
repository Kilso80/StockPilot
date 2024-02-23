import 'package:flutter/material.dart';
import 'package:stockpilot/data/login_system.dart';

class SubUsersList extends StatefulWidget {
  const SubUsersList({super.key});

  @override
  State<SubUsersList> createState() => _SubUsersListState();
}

class _SubUsersListState extends State<SubUsersList> {
  Widget buildWithData(BuildContext context, AsyncSnapshot<List> snapshot) {
    return ListView.builder(
      itemCount: snapshot.data!.length,
      itemBuilder: (context, index) => index == snapshot.data!.length
          ? IconButton(onPressed: () {/* TODO */}, icon: const Icon(Icons.add))
          : const ListTile(
              title: Row(
              children: [],
            )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: LoginSystem().getSubUsers(),
      builder: buildWithData,
      initialData: const [],
    );
  }
}
