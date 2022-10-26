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
  }
}
