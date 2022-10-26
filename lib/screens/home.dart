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
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff3b3b3b),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
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
              });
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
