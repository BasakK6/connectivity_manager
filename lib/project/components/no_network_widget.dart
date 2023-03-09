import 'package:connectivity_manager/connectivity_change/network_result.dart';
import 'package:connectivity_manager/core/context_extensions.dart';
import 'package:connectivity_manager/project/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:connectivity_manager/connectivity_change/network_change_notifier.dart';
import 'package:connectivity_manager/core/duration_items.dart';

class NoNetworkWidget extends ConsumerWidget {
  const NoNetworkWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedCrossFade(
      firstChild: Material(
        child: buildErrorMessageContainer(context),
      ),
      secondChild: buildEmptySizedBox(context),
      crossFadeState: ref.watch(networkChangeNotifierProvider) ==
              NetworkResult.off
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: const DurationItems.durationLow(),
    );
  }

  Container buildErrorMessageContainer(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.center,
      width: context.width,
      height: context.dynamicHeight(0.05),
      color: context.colorScheme.primary,
      child: const Text(Constants.noNetworkMessage),
    );
  }

  SizedBox buildEmptySizedBox(BuildContext context) {
    return SizedBox(
      width: context.width,
      height: 0,
    );
  }
}
