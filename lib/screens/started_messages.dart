import 'dart:convert';

import 'package:penai/models/custom_button.dart';
import 'package:penai/services/lan_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartedMessages extends StatefulWidget {
  const StartedMessages({super.key});

  @override
  State<StartedMessages> createState() => _StartedMessagesState();
}

class _StartedMessagesState extends State<StartedMessages> {
  ScrollController scrollController = ScrollController();
  List startedMessages = [];
  bool empty = true;
  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadStartedMessages();
  }

  Future<void> saveStartedMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedMessages =
        startedMessages.map((started) => jsonEncode(started)).toList();
    await prefs.setStringList('startedMessages', encodedMessages);
  }

  Future<void> loadStartedMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMessages = prefs.getStringList('startedMessages') ?? [];

    setState(() {
      if (savedMessages.isEmpty) {
        empty = true;
      } else {
        empty = false;
        startedMessages = savedMessages
            .map((started) => jsonDecode(started))
            .cast<String>() // Ensure this is dynamic
            .toList();
      }
    });
  }

  scrollMethod() {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // appBar: AppBar(
      //   title: const Text('Text Recognition'),
      // ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: IntrinsicHeight(
                child: Stack(
                  children: [
                    Align(
                      child: Text(
                        'PEN AI',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      child: CustomIconButton(
                        height: 35,
                        width: 35,
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            empty
                ? Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star_half_sharp,
                          size: 50,
                          color: Color.fromARGB(255, 6, 85, 141),
                        ),
                        Text(
                          texts['no_messages'] ?? '',
                          style: const TextStyle(
                            fontSize: 28.0,
                            color: Color.fromARGB(255, 6, 85, 141),
                          ),
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        controller: scrollController,
                        reverse: true,
                        itemCount: startedMessages.length,
                        itemBuilder: (context, index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 3),
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 6, 85, 141),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: SelectableText(
                                              startedMessages[index] ?? '',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                              textDirection: startedMessages[
                                                              index] !=
                                                          null &&
                                                      RegExp(r'[^\x00-\x7F]')
                                                          .hasMatch(
                                                              startedMessages[
                                                                  index])
                                                  ? TextDirection.rtl
                                                  : TextDirection.ltr,
                                            ),
                                          ),
                                          const SizedBox(width: 18.0),
                                          GestureDetector(
                                            onTap: () {
                                              startedMessages.removeAt(index);
                                              saveStartedMessages();
                                              setState(() {});
                                              showSnackbar(
                                                  'Deleted from started messages');
                                            },
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.transparent,
                                              ),
                                              child: const Icon(
                                                size: 15,
                                                Icons.delete_outline,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                            ],
                          );
                        }),
                  ),
          ],
        ),
      ),
    );
  }
}
