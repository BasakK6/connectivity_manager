import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:connectivity_manager/connectivity_change/network_change_notifier.dart';

import 'package:connectivity_manager/connectivity_change/network_result.dart';

import '../../project/constants.dart';
import 'components/colored_message_box.dart';

class HomeView extends ConsumerWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(ref),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: const Text(Constants.homeViewTitle),
    );
  }

  Center buildBody(WidgetRef ref) {
    return Center(
      child: ref.watch(networkChangeNotifierProvider) == NetworkResult.on
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
