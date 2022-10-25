import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pusher_demo/blocs/channel_bloc.dart';

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
                                cb.allSpaces[index]["name"],
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
                                cb.allSpaces[index]["description"],
                                style: const TextStyle(
                                  fontFamily: "PublicSans",
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              if (cb.joinedChannelsMap
                                  .containsKey(channelId)) ...[
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
                                    if (cb.joinedChannelsMap
                                        .containsKey(channelId)) {
                                      cb.disconnectFromChannel(channelId);
                                    } else {
                                      cb.joinChannel(channelId);
                                    }
                                  },
                                  child: Text(
                                    cb.joinedChannelsMap.containsKey(channelId)
                                        ? "Disconnect"
                                        : "Join",
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
                          controller: _nameCtrl,
                          decoration: InputDecoration(
                            labelText: "Name",
                            hintText: "Enter Name",
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
                        const SizedBox(
                          height: 30,
                        ),
                        TextFormField(
                          controller: _descriptionCtrl,
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
                              if (_nameCtrl.text.isNotEmpty &&
                                  _descriptionCtrl.text.isNotEmpty) {
                                cb.createSpace(
                                  _nameCtrl.text,
                                  _descriptionCtrl.text,
                                );
                                _nameCtrl.clear();
                                _descriptionCtrl.clear();
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
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
                      ],
                    ),
                  ),
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
