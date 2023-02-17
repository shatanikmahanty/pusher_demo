import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class ChannelBloc extends ChangeNotifier {
  List<Map<String, dynamic>> _allSpaces = [];

  List<Map<String, dynamic>> get allSpaces => _allSpaces;

  StreamSubscription? _allSpacesSub;

  StreamSubscription? get allSpacesSub => _allSpacesSub;

  final Map<String, int> _joinedChannelsMap = {};

  Map<String, int> get joinedChannelsMap => _joinedChannelsMap;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isSpaceCreationInProgress = false;

  bool get isSpaceCreationInProgress => _isSpaceCreationInProgress;

  late PusherChannelsFlutter pusher;

  ChannelBloc() {
    configurePusher();
    getAvailableChannels();
  }

  Future getAvailableChannels() async {
    Query<Map<String, dynamic>> reference =
        FirebaseFirestore.instance.collection("spaces");

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

  Future createSpace(String name, String description) async {
    _isSpaceCreationInProgress = true;
    notifyListeners();

    DocumentReference ref =
        FirebaseFirestore.instance.collection("spaces").doc();
    await ref.set({
      "name": name,
      "description": description,
      "id": ref.id,
    });

    _isSpaceCreationInProgress = false;
    notifyListeners();
  }

  Future joinChannel(String channelId) async {
    await pusher.subscribe(
      channelName: channelId,
      onEvent: (event) {
        if (event.eventName == "pusher_internal:subscription_count") {
          String channelName = event.channelName;

          _joinedChannelsMap[channelName] = int.parse(event.data
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

  Future configurePusher() async {
    pusher = PusherChannelsFlutter.getInstance();
    try {
      await pusher.init(
        apiKey: "YOUR_API_KEY", // TODO: replace with your api_key
        cluster: "YOUR_CLUSTER", // TODO: replace with your cluster
      );

      await pusher.connect();
    } catch (e) {
      debugPrint('$e');
    }
  }
}
