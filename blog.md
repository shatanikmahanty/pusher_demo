Flutter: Realtime Participants Counter
======================================

Overview
========

This tutorial will guide you toward creating an app that can track real-time participant counts using Pusher Channels. We will be relying on pusher events for the counters and Firebase Firestore for data storage.

For the sake of simplicity, we will use a very minimalistic UI.

**What is Pusher?**
===================

Pusher is a platform that helps create powerful real-time experiences for mobile and web. It can be used to create and maintain complex messaging infrastructure so you can build and scale the real-time features your users need.

**Use Cases:**

*   Realtime Charts
*   Notifications
*   Location Tracking
*   In-app chat
*   Live counters (Our end goal😎)

To get started we will need to set up a few dependencies:

``` yaml
pusher_channels_flutter: ^2.0.2  #For interacting with pusher  
provider: ^6.0.4   #For using provide architecture  
firebase_core: ^2.0.0   #For initializing firebase in flutter app  
cloud_firestore: ^4.0.1 #For accessing Cloud Firestore
```

Add the above dependencies to your pubspec.yaml file. (You can use the given version or the latest one from [pub.dev](https://pub.dev/)).

**The Implementation…**
=======================

Setting up the app
------------------

Create a new Flutter Project, `pusher_demo`

Remove the code for the counter app until you only remain with a Scaffold with a home (We will be creating this later in this tutorial).

``` dart
import 'package:flutter/material.dart';  
import 'package:pusher_demo/screens/home.dart';  
  
void main() {  
  runApp(const MyApp());  
}  
  
class MyApp extends StatelessWidget {  
  const MyApp({super.key});  
  
  @override  
  Widget build(BuildContext context) {  
    return const MaterialApp(  
        title: 'Spaces',  
        home: HomePage(),  
        debugShowCheckedModeBanner: false,  
      );  
  }  
}
```

**Linking with Firebase**

For this step follow the official firebase guide on how to set up firebase for flutter projects and add the required files like `google_services.json`. More details can be found [here](https://firebase.google.com/docs/flutter/setup).

Initialize the firebase app in the `main()`function.

``` dart
void main() async {  
  WidgetsFlutterBinding._ensureInitialized_();  
  
  await configureApp();  
  
  runApp(const MyApp());  
}  
  
Future configureApp() async {  
  ///Initialising firebase app  
  ///so that all firebase services can be used
  if (Firebase.apps.isEmpty) await Firebase.initializeApp();  
}
```

**Linking with pusher**
-----------------------

Now we need an API key and a cluster name that lets our app connect to Pusher. Let’s set up Pusher before integrating with Flutter.

Go to [https://dashboard.pusher.com/](https://dashboard.pusher.com/) and create an account if you don’t have one.

Create an app from [https://dashboard.pusher.com/apps](https://dashboard.pusher.com/apps). You will be presented with an interface similar to this. Give your app a name and select a cluster.

![Pusher app creation dialog](https://user-images.githubusercontent.com/67138059/218485164-ab0510c8-e96d-474b-9bcb-28ef88ec0535.png)

Click Create app.

You will see your app listed. Click on it to view details. You will be presented with an overview of your app. Click on the App Keys option. Generate a new key in case you don’t have one.

![Demo pusher app dashboard](https://user-images.githubusercontent.com/67138059/218485236-1f66de0a-b2a1-4f83-b76d-6752ed8638c0.png)

Go to App settings and enable the below-mentioned options.

![Enable required options](https://user-images.githubusercontent.com/67138059/218485314-7025b957-b207-41dd-a2f3-821244a2c250.png)

Once you have the key, you are ready to integrate Pusher with Flutter.

Some key terms that will be used concerning pusher:

**Channel**: Pusher Channels provide real-time communication between servers, apps, and devices. Channels are used for real-time charts, real-time user lists, real-time maps, multiplayer gaming, and many other kinds of UI updates.

**Events**: Events are triggers fired with regard to channels that notify clients about data packets that are transmitted from a server.

**Creating the channel logic in Flutter**

We will be creating a class ChannelBloc that extends ChangeNotifier so that we can use it as a provider.

Let’s create a method to configure Pusher.

We will be creating a PusherChannelsFlutter object. replace `YOUR_API_KEY` and `CLUSTER` with the values obtained in the previous step.

``` dart
import 'dart:async';  
import 'package:cloud_firestore/cloud_firestore.dart';  
import 'package:flutter/cupertino.dart';  
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';  
  
class ChannelBloc extends ChangeNotifier { 
late PusherChannelsFlutter pusher; 
ChannelBloc() {  
    configurePusher();  
  }  
  
  Future configurePusher() async {  
    pusher = PusherChannelsFlutter._getInstance_();  
    try {  
      await pusher.init(  
        apiKey: "YOUR_API_KEY",  
        cluster: "CLUSTER",  
      );  
  
      await pusher.connect();  
    } catch (e) {  
      print(e);  
    }  
  }
}
```

Next, we will need a way to store details about created channels. This is where Firebase Firestore comes into play. We will add a new method in our ChannelBloc called getAvailableChannels().

We are calling the channels spaces in this tutorial to better align with our end goal. We will create a stream subscription that notifies us as soon as a new channel is created. The stream gives us all the documents of the collection including the newly created one. We store that in a list`_allSpaces` and create a getter for accessing from UI.

We also create a loading indicator variable `_isLoading` so that we can notify users in case the documents are being fetched

> Note: In a real-world scenario this is not ideal, as fetching all available docs at once can be costly. But, for the sake of the simplicity of this tutorial, we will not optimize it.
> 
> Tip for optimization: You can create a logic that fetches only popular spaces and let the rest of the channels be accessible using a code.

``` dart
class ChannelBloc extends ChangeNotifier {  
  List<Map<String, dynamic>> _allSpaces = [];  
  
  List<Map<String, dynamic>> get allSpaces => _allSpaces;  
  
  StreamSubscription? _allSpacesSub;  
  
  StreamSubscription? get allSpacesSub => _allSpacesSub;  
  
  bool _isLoading = false;  
  
  bool get isLoading => _isLoading;  
  
  late PusherChannelsFlutter pusher;  
  
  ChannelBloc() {  
    configurePusher();  
    getAvailableChannels();  
  }  
  
  Future getAvailableChannels() async {  
    Query<Map<String, dynamic>> reference =  
        FirebaseFirestore._instance_.collection("spaces");  
  
    Stream<QuerySnapshot<Map<String, dynamic>>> stream = reference.snapshots();  
  
    _allSpacesSub = stream.listen((querySnapshot) {  
      _isLoading = true;  
      notifyListeners();  
      _allSpaces = [];  
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc  
          in querySnapshot.docs) {  
        _allSpaces.add(doc.data());  
      }  
      _isLoading = false;  
      notifyListeners();  
    });  
  }  
}
```

We move on to joining and disconnecting from the channel.

We pass channelId to the joinChannel method. To join a channel is as simple as calling pusher.subscribe() and passing the channelName.

We will be using `onEvent` callback to get notified of events. For this tutorial, we will be using the event `pusher_internal:subscription_count`. This event fires whenever a new user subscribes to the event and provides us with an event object.

Now we need an architecture to store count of the no of subscribers for each channel. For this, we will use `Map<String, int>`. The Channel name will be used as a key and the number of subscribers will be the value.

Using `event.data` provides us with the data given by the event. In this case, the subscription counter. The data is a string of the form {“subscription\_count”:1}. But this data needs to be cleaned to get the count. Thus we use replace() and split() operations on the string.

For disconnecting, we just need to call unsubscribe and remove the channel from \_joinedChannelsMap.

``` dart
final Map<String, int> _joinedChannelsMap = {};  
  
Map<String, int> get joinedChannelsMap => _joinedChannelsMap;Future joinChannel(String channelId) async {  
  await pusher.subscribe(  
    channelName: channelId,  
    onEvent: (event) {  
      if (event.eventName == "pusher_internal:subscription_count") {  
        String channelName = event.channelName;  
  
        _joinedChannelsMap[channelName] = int._parse_(event.data  
            .replaceAll("\"", "")  
            .replaceAll("{", "")  
            .replaceAll("}", "")  
            .split(":")[1]);  
  
        notifyListeners();  
      }  
    },  
  );  
}  
  
Future disconnectFromChannel(String channelId) async {  
  await pusher.unsubscribe(  
    channelName: channelId,  
  );  
  
  _joinedChannelsMap.removeWhere((channelName, count) {  
    if (channelName == channelId) {  
      return true;  
    } else {  
      return false;  
    }  
  });  
  notifyListeners();  
}
```

Next, we write the logic for creating a channel. Pusher channels don’t need to be created explicitly. They are created at the time the first user subscribes. What we will create is the logic for storing the space details in Firebase so that they can be joined later as a pusher channel.

We use _isSpaceCreationInProgress to update the UI while calling this function from UI.

``` dart
bool _isSpaceCreationInProgress = false;  
  
bool get isSpaceCreationInProgress => _isSpaceCreationInProgress;Future createSpace(String name,String description) async {  
  _isSpaceCreationInProgress = true;  
  notifyListeners();  
  
  DocumentReference ref = FirebaseFirestore._instance_.collection("spaces").doc();  
  await ref.set({  
    "name": name,  
    "description": description,  
    "id" : ref.id,  
  });  
  
  _isSpaceCreationInProgress = false;  
  notifyListeners();  
}
```

> That completes the business logic. To make it usable we need to register it in `main.dart`.

``` dart
import 'package:flutter/material.dart';  
import 'package:provider/provider.dart';  
import 'package:firebase_core/firebase_core.dart';  
import 'package:pusher_demo/blocs/channel_bloc.dart';  
import 'package:pusher_demo/screens/home.dart';  
  
void main() async {  
  WidgetsFlutterBinding._ensureInitialized_();  
  
  await configureApp();  
  
  runApp(const MyApp());  
}  
  
Future configureApp() async {  
  ///Initialising firebase app  
  ///so that all firebase services can be used 
  if (Firebase._apps_.isEmpty) await Firebase.initializeApp();  
}  
  
class MyApp extends StatelessWidget {  
  const MyApp({super.key});  
  
  @override  
  Widget build(BuildContext context) {  
    return MultiProvider(  
      providers: [  
        ChangeNotifierProvider<ChannelBloc>(  
          create: (context) => ChannelBloc(),  
        ),  
      ],  
      child: const MaterialApp(  
        title: 'Spaces',  
        home: HomePage(),  
        debugShowCheckedModeBanner: false,  
      ),  
    );  
  }  
}
```

Now that we have dealt with the business logic we needed, let’s get to coding the UI. Since this project focuses only on the subscription counter we won’t be creating the logic for sending messages in the spaces.

![Spaces page UI](https://user-images.githubusercontent.com/67138059/218485602-7c390c65-8352-4b00-bcda-81d29ef6c22b.png)

For the home page, we will create a list view that shows the currently available rooms and a floating action button that shows a space creation dialog. If the spaces are loading we show CircularProgressIndicator, otherwise, we show the listview.

Individual elements of the list view allow the user to join using the join button. On joining we update the UI to disconnect the button and show the online count.

We also declare two TextEditingController for the dialog that we pass to the dialog class.

``` dart
import 'package:flutter/material.dart';  
import 'package:provider/provider.dart';  
import 'package:pusher_demo/blocs/channel_bloc.dart';  
import 'package:pusher_demo/utils/new_space_dialog.dart';
class HomePage extends StatefulWidget {  
  const HomePage({Key? key}) : super(key: key);  
  
  @override  
  State<HomePage> createState() => _HomePageState();  
}  
  
class _HomePageState extends State<HomePage> {  
  final TextEditingController _nameCtrl = TextEditingController();  
  final TextEditingController _descriptionCtrl = TextEditingController();  
  
  @override  
  Widget build(BuildContext context) {  
    ChannelBloc cb = Provider.of<ChannelBloc>(context);  
    Size size = MediaQuery.of(context).size;  
  
    return Scaffold(  
      backgroundColor: const Color(0xff0c1015),  
      floatingActionButton: FloatingActionButton(  
        backgroundColor: const Color(0xff3b3b3b),  
        shape: const RoundedRectangleBorder(  
           borderRadius: BorderRadius.all(Radius.circular(15.0)),  
        ),  
      body: cb.isLoading  
        ? const Center(  
            child: CircularProgressIndicator(),  
          )  
      : Column(  
          crossAxisAlignment: CrossAxisAlignment.start,  
          children: [  
            Container(  
              width: size.width,  
              decoration: const BoxDecoration(  
                borderRadius: BorderRadius.only(  
                  bottomRight: Radius.circular(30),  
                  bottomLeft: Radius.circular(30),  
                ),  
                image: DecorationImage(  
                  image: AssetImage(  
                    "assets/images/background.jpg",  
                  ),  
                  fit: BoxFit.cover,  
                ),  
              ),  
              child: Padding(  
                padding: const EdgeInsets.fromLTRB(20, 140, 20, 30),  
                child: Column(  
                  crossAxisAlignment: CrossAxisAlignment.start,  
                  children: const [  
                    Text(  
                      "Explore \nall spaces",  
                      style: TextStyle(  
                        fontWeight: FontWeight.bold,  
                        fontSize: 30,  
                        color: Colors.white,  
                        fontFamily: "PublicSans",  
                      ),  
                    ),  
                    SizedBox(  
                      height: 20,  
                    ),  
                    Text(  
                      "Find your favourite space",  
                      style: TextStyle(  
                        fontSize: 15,  
                        color: Colors.white38,  
                        fontFamily: "PublicSans",  
                      ),  
                    ),  
                  ],  
                ),  
              ),  
            ),  
            Padding(  
              padding: const EdgeInsets.symmetric(  
                horizontal: 20.0,  
                vertical: 10,  
              ),  
              child: Row(  
                children: [  
                  const Text(  
                    "Available Spaces",  
                    style: TextStyle(  
                      fontSize: 20,  
                      color: Colors.white,  
                      fontWeight: FontWeight.bold,  
                      fontFamily: "PublicSans",  
                    ),  
                  ),  
                  const Spacer(),  
                  CircleAvatar(  
                    radius: 20,  
                    child: Text(  
                      cb.allSpaces.length.toString(),  
                      style: const TextStyle(  
                        fontSize: 20,  
                        color: Colors.white,  
                        fontFamily: "PublicSans",  
                      ),  
                    ),  
                  ),  
                ],  
              ),  
            ),  
            Flexible(  
              child: ListView.builder(  
                shrinkWrap: true,  
                physics: const BouncingScrollPhysics(),  
                itemCount: cb.allSpaces.length,  
                padding: EdgeInsets.zero,  
                itemBuilder: (BuildContext context, int index) {  
                  String channelId = cb.allSpaces[index]["id"];  
                  Map<String, dynamic> space = cb.allSpaces[index];  
                  bool isJoinedSpace =  
                      cb.joinedChannelsMap.containsKey(channelId);  
                  return Card(  
                    shape: RoundedRectangleBorder(  
                      borderRadius: BorderRadius.circular(20),  
                    ),  
                    elevation: 10,  
                    margin: const EdgeInsets.symmetric(  
                      horizontal: 20,  
                      vertical: 10,  
                    ),  
                    color: const Color(0xff191c26),  
                    child: Padding(  
                      padding: const EdgeInsets.all(25.0),  
                      child: Column(  
                        crossAxisAlignment: CrossAxisAlignment.start,  
                        children: [  
                          Text(  
                            space["name"],  
                            style: const TextStyle(  
                              fontWeight: FontWeight.bold,  
                              color: Colors.white,  
                              fontFamily: "PublicSans",  
                              fontSize: 25,  
                            ),  
                          ),  
                          const SizedBox(  
                            height: 20,  
                          ),  
                          Text(  
                            space["description"],  
                            style: const TextStyle(  
                              fontFamily: "PublicSans",  
                              color: Colors.white,  
                              fontSize: 20,  
                            ),  
                          ),  
                          if (isJoinedSpace) ...[  
                            const SizedBox(  
                              height: 20,  
                            ),  
                            Row(  
                              children: [  
                                const Icon(  
                                  Icons.fiber_manual_record,  
                                  color: Colors.cyanAccent,  
                                ),  
                                const SizedBox(  
                                  width: 10,  
                                ),  
                                Text(  
                                  "Online: ${cb.joinedChannelsMap[channelId]}",  
                                  style: const TextStyle(  
                                    fontFamily: "PublicSans",  
                                    color: Colors.white,  
                                    fontSize: 20,  
                                  ),  
                                ),  
                              ],  
                            ),  
                          ],  
                          const SizedBox(  
                            height: 30,  
                          ),  
                          SizedBox(  
                            height: 60,  
                            width: size.width,  
                            child: ElevatedButton(  
                              style: ElevatedButton.styleFrom(  
                                backgroundColor: const Color(0xff3b3b3b),  
                                shape: RoundedRectangleBorder(  
                                  borderRadius: BorderRadius.circular(20),  
                                ),  
                              ),  
                              onPressed: () {  
                                if (isJoinedSpace) {  
                                  cb.disconnectFromChannel(channelId);  
                                } else {  
                                  cb.joinChannel(channelId);  
                                }  
                              },  
                              child: Text(  
                                isJoinedSpace ? "Disconnect" : "Join",  
                                style: const TextStyle(  
                                  fontFamily: "PublicSans",  
                                  color: Colors.white,  
                                  fontWeight: FontWeight.bold,  
                                  fontSize: 18,  
                                ),  
                              ),  
                            ),  
                          )  
                        \],  
                      ),  
                    ),  
                  );  
                },  
              ),  
            ),  
          ],  
        ),  
        onPressed: () {  
          showDialog(  
            context: context,  
            builder: (context) {  
              return NewSpaceDialog(  
                size: size,  
                nameCtrl: _nameCtrl,  
                descriptionCtrl: _descriptionCtrl,  
                cb: cb,  
              );  
            }  
          );  
        },  
       child: const Icon(  
         Icons.add,  
       ),  
     ),     
  );
```

All we are left with now is the dialog for the creation of spaces. We will create a new stateless widget for this to keep the code clean.

``` dart
import 'package:flutter/material.dart';  
import 'package:pusher_demo/blocs/channel_bloc.dart';  
  
class NewSpaceDialog extends StatelessWidget {  
  final Size size;  
  
  final TextEditingController nameCtrl;  
  final TextEditingController descriptionCtrl;  
  final ChannelBloc cb;  
  
  const NewSpaceDialog(  
      {Key? key,  
      required this.size,  
      required this.nameCtrl,  
      required this.descriptionCtrl,  
      required this.cb})  
      : super(key: key);  
  
  @override  
  Widget build(BuildContext context) {  
    return Dialog(  
      shape: RoundedRectangleBorder(  
        borderRadius: BorderRadius.circular(20),  
      ),  
      backgroundColor: const Color(0xff191c26),  
      child: Container(  
        height: 400,  
        width: size.width * 0.8,  
        padding: const EdgeInsets.all(30),  
        child: Column(  
          children: [  
            const Text(  
              "Create Space",  
              style: TextStyle(  
                fontSize: 20,  
                color: Colors.white,  
                fontFamily: "PublicSans",  
                fontWeight: FontWeight.bold,  
              ),  
            ),  
            const SizedBox(  
              height: 40,  
            ),  
            TextFormField(  
              controller: nameCtrl,  
              decoration: InputDecoration(  
                labelText: "Name",  
                hintText: "Enter Name",  
                hintStyle: const TextStyle(  
                  fontFamily: "GoogleSans",  
                ),  
                filled: true,  
                fillColor: Colors._white_,  
                enabledBorder: OutlineInputBorder(  
                  borderRadius: BorderRadius.circular(12),  
                  borderSide: const BorderSide(  
                    width: 0.2,  
                    color: Colors.black,  
                    style: BorderStyle.solid,  
                  ),  
                ),  
                focusedBorder: OutlineInputBorder(  
                  borderRadius: BorderRadius.circular(12),  
                  borderSide: const BorderSide(  
                    width: 2,  
                    color: Colors.blueGrey,  
                    style: BorderStyle.solid,  
                  ),  
                ),  
              ),  
            ),  
            const SizedBox(  
              height: 30,  
            ),  
            TextFormField(  
              controller: descriptionCtrl,  
              decoration: InputDecoration(  
                labelText: "Description",  
                hintText: "Enter Description",  
                hintStyle: const TextStyle(  
                  fontFamily: "GoogleSans",  
                ),  
                filled: true,  
                fillColor: Colors.white,  
                enabledBorder: OutlineInputBorder(  
                  borderRadius: BorderRadius.circular(12),  
                  borderSide: const BorderSide(  
                    width: 0.2,  
                    color: Colors.black,  
                    style: BorderStyle.solid,  
                  ),  
                ),  
                focusedBorder: OutlineInputBorder(  
                  borderRadius: BorderRadius.circular(12),  
                  borderSide: const BorderSide(  
                    width: 2,  
                    color: Colors.blueGrey,  
                    style: BorderStyle.solid,  
                  ),  
                ),  
              ),  
            ),  
            const Spacer(),  
            SizedBox(  
              height: 60,  
              width: size.width,  
              child: ElevatedButton(  
                style: ElevatedButton.styleFrom(  
                  backgroundColor: const Color(0xff3b3b3b),  
                  shape: RoundedRectangleBorder(  
                    borderRadius: BorderRadius.circular(20),  
                  ),  
                ),  
                onPressed: () {  
                  if (nameCtrl.text.isNotEmpty &&  
                      descriptionCtrl.text.isNotEmpty) {  
                    cb.createSpace(  
                      nameCtrl.text,  
                      descriptionCtrl.text,  
                    );  
                    nameCtrl.clear();  
                    descriptionCtrl.clear();  
                    Navigator.pop(context);  
                  } else {  
                    ScaffoldMessenger._of_(context).showSnackBar(  
                      const SnackBar(  
                        content: Text(  
                          "Please enter the details",  
                          style: TextStyle(  
                            fontFamily: "PublicSans",  
                            color: Colors.white,  
                            fontSize: 18,  
                          ),  
                        ),  
                      ),  
                    );  
                  }  
                },  
                child: cb.isSpaceCreationInProgress  
                    ? const Center(  
                        child: CircularProgressIndicator(),  
                      )  
                    : const Text(  
                        "Create",  
                        style: TextStyle(  
                          fontFamily: "PublicSans",  
                          color: Colors.white,  
                          fontWeight: FontWeight.bold,  
                          fontSize: 18,  
                        ),  
                      ),  
              ),  
            ),  
          \],  
        ),  
      ),  
    );  
  }  
}
```

With that, you are ready to fully use Pusher subscription counters in your app. I can’t wait to witness what you all will build with it 🤩

The source code for this project is hosted at this GitHub repo: [https://github.com/shatanikmahanty/pusher\_demo/](https://github.com/shatanikmahanty/pusher_demo/)

You can reach out to me through LinkedIn: [https://www.linkedin.com/in/shatanikmahanty/](https://www.linkedin.com/in/shatanikmahanty/)

Find more about pusher at [https://pusher.com/](https://pusher.com/)

Find more about firebase at [https://firebase.google.com/](https://firebase.google.com/)

> Thank you for taking the time to read this ❤️
