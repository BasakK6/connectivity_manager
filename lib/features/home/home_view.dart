import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:connectivity_manager/connectivity_change/network_change_manager.dart';

import 'package:connectivity_manager/connectivity_change/network_result.dart';

import '../../project/constants.dart';
import 'components/colored_message_box.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeView> createState() => _NetworkChangeViewState();
}

class _NetworkChangeViewState extends ConsumerState<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: const Text(Constants.homeViewTitle),
    );
  }

  Center buildBody() {
    return Center(
      child: ref.watch(networkChangeManagerProvider).networkResult ==
              NetworkResult.on
          ? const ColoredMessageBox(
              color: Colors.green,
              message: Constants.homeViewPositiveMessage,
            )
          : const ColoredMessageBox(
              color: Colors.red,
              message: Constants.homeViewNegativeMessage,
            ),
    );
  }
}
