# connectivity_manager

Today, mobile applications work by communicating with various services over the Internet.  For this reason, having an active Internet connection is one of the vital points of a mobile application/web development.  
In this project, we will examine how we can effectively control the Internet connection and update the user interface in Flutter.

In order to obtain this, we can use 2 packages on [pub.dev](https://pub.dev). 
You can find the packages that are used in this project below:

1) [connectivity_plus](https://pub.dev/packages/connectivity_plus)
2) [riverpod](https://pub.dev/packages/flutter_riverpod)

The connectivity_plus package was used to make the Internet connection control and the riverpod package was used for state management.

## 1) Packages Import

First things first, let's import these packages

```yaml
dependencies:
  # state management
  flutter_riverpod: ^2.2.0
  # network connectivity
  connectivity_plus: ^3.0.3
```

## 2) Network Status

We can then create an enum to denote the Network status. We can name this enum NetworkResult: 

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkResult{
  on,
  off;

  static NetworkResult checkConnectivity(ConnectivityResult result){
    switch(result){
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
      case ConnectivityResult.mobile:
        return NetworkResult.on;
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.none:
      default:
        return NetworkResult.off;
    }
  }
}
```

We have 2 states when it comes to network connection. It is either ON or  OFF (connected or not). Therefore, let's write these in the NetworkResult.

In addition, let's create a static method that returns either ON or OFF after checking the connection status. 
In this method we take a parameter of type ConnectivityResult and check its value with a switch/case. 
If there is a connection (wifi/ethernet/mobile) we return ON, else we return OFF.


## 3) Connectivity Change Subscription

Then, let's create a class that subscribes to the connection change events and notifies us about the future changes.

We can name this class class NetworkChangeNotifier. 
In order to get notified of the change and update the UI, let's extend this class from StateNotifier.

```dart
import 'dart:async';

import 'package:connectivity_manager/connectivity_change/network_result.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NetworkChangeNotifier extends StateNotifier<NetworkResult> {
  NetworkChangeNotifier(NetworkResult state) : super(state) {
    init();
  }

  Future<void> init() async {
    final Connectivity connectivity = Connectivity();
    await checkInitialConnection(connectivity);
    subscribeToTheConnectionChange(connectivity);
  }

  Future<void> checkInitialConnection(
      Connectivity connectivity) async {
    var connectivityResult = await connectivity.checkConnectivity();
    state = NetworkResult.checkConnectivity(connectivityResult);
  }

  void subscribeToTheConnectionChange(Connectivity connectivity) {
    connectivity.onConnectivityChanged.listen((event) {
      state = NetworkResult.checkConnectivity(event);
    });
  }
}
```
- Since we're going to control the NetworkResult change (ON or OFF) let's use the StateNotifier\<NetworkResult> generic type.
- Then, we create the constructor, receive the initial state value with a constructor parameter and transfer this value to the ancestor by using super.
- Inside the constructor we can call a method that checks the Internet connection for the first time and subscribes to the changes after the first control. We can name this method init()
- Let's divide these 2 jobs into their seperate methods. We first use checkInitialConnection() method and then subscribeToTheConnectionChange() method.
- In these 2 methods, we use the checkConnectivity static method that we wrote earlier and update the state.

## 4) StateNotifierProvider

After completing the StateNotifier class, we can create a global provider object:

```dart
final networkChangeNotifierProvider =
    StateNotifierProvider<NetworkChangeNotifier, NetworkResult>((ref) {
        return NetworkChangeNotifier(NetworkResult.off);
});
```

## 5) Consume the state in the specific widgets (pages)

Let's say we have a widget that is used as a route. When consuming providers we have 3 options.
1) If we have a StatelessWidget we can extend from ComsumerWidget and override its build method that has a WidgetRef parameter.
2) If we have a StatefulWidget we can extend from ComsumerStatefulWidget and ConsumerState and directly use the "ref" inside of our state class
3) Alternatively regardless of we have a Stateless or Statefull widget, we wrap our widget with Consumer widget and use its builder method

In this project the first option was given as an example:

```dart
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
        message: "There is an Internet Connection",
      )
          : const ColoredMessageBox(
        color: Colors.red,
        message: "No Internet Connection",
      ),
    );
  }
}
```


We can use ref.watch(networkChangeNotifierProvider) to get notified inside the build method.
- In this example, different ColoredMessageBox was shown depending on the NetworkResult state.
- ColoredMessageBox is just a Container that holds a Text widget inside it. You can check its code [here](https://github.com/BasakK6/connectivity_manager/blob/master/lib/features/home/components/colored_message_box.dart).

We could also use ref.listen() to show an AlertDialog or a SnackBar that is specific to the route.  
However we can have this feature with a different approach. Plus, fortunately, with this "different" approach, we don't have to use ref.listen() in our every route.

## 6) Consume the NetworkResult status in the whole app

We can design our custom widget to show connection state changes throughout the whole app. 
We can insert this widget on top of every route. For this, we can use the **"builder"** property of the **MaterialApp**.

>Builder property is used for inserting widgets above the Navigator or - when the WidgetsApp.router constructor is used - above the Router but below the other widgets created by the WidgetsApp widget, or for replacing the Navigator/Router entirely.

Let's create an animation widget that shows the Internet connection loss. 
By using this example widget, we can have a widget that looks like SnackBar and notifies the user no matter which route they're in our app. This way we don't have to write route/page specific controls. 
The builder property will insert our widget on top of every page.

```dart
import 'features/home/home_view.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeView(),
      builder: MainBuilder.build, //Use it here
    );
  }
}
```

The builder expects a type of  <ins>Widget Function(BuildContext, Widget?)? builder</ins>.
In order not to have a boilerplate code let's write a class that is responsible of providing this function. 
Let's name it MainBuilder and have it provide a static method of the same type.
We can then use it inside the MaterialApp as above.

```dart
import 'package:flutter/material.dart';
import 'components/no_network_widget.dart';

class MainBuilder {
  MainBuilder._privateConstructor();

  static Widget build(BuildContext context, Widget? child) {
    return Column(
      children: [
        Expanded(
          child: child!,
        ),
        const NoNetworkWidget(),
      ],
    );
  }
}
```

- Let's also restrict the object creation from this class by writing a private constructor.
- Inside the build method, we have a Column widget that has 2 children.
- The first child is the actual route (In this case HomeView because we assigned HomeView() to the home property of the MaterialApp). The child parameter of the build method changes  with the route.
- The second child is our custom widget that will be displayed only when there is no Internet connection.

## 7) NoNetworkWidget

You can choose any design/layout or animation you like. However in this project an Implicit Animation was used as an example.

```dart
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
```

We can have an AnimatedCrossFade that switches between "Error Message Container" and an "Empty SizedBox" depending on the NetworkResult state.
Here, in order to consume the state, a ConsumerWidget was used as well.