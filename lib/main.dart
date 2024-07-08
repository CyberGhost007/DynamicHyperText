import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'dynamic_hyper_text.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DynamicHyperText Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonSelectionArea(
      customMenuItems: [
        CustomMenuOption(
          label: 'Share',
          onPressed: () {
            print('Sharing...');
            // Implement share functionality here
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sharing content...')),
            );
          },
          imagePath: 'assets/love.png',
        ),
        CustomMenuOption(
          label: 'Translate',
          onPressed: () {
            print('Translating...');
            // Implement translate functionality here
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Translating content...')),
            );
          },
          imagePath: 'assets/translate_icon.png',
        ),
        CustomMenuOption(
          label: 'Define',
          onPressed: () {
            print('Defining...');
            // Implement define functionality here
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Looking up definition...')),
            );
          },
          imagePath: 'assets/love.png',
        ),
        CustomMenuOption(
          label: 'Define',
          onPressed: () {
            print('Defining...');
            // Implement define functionality here
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Looking up definition...')),
            );
          },
          imagePath: 'assets/love.png',
        ),
        CustomMenuOption(
          label: 'Define',
          onPressed: () {
            print('Defining...');
            // Implement define functionality here
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Looking up definition...')),
            );
          },
          imagePath: 'assets/love.png',
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('DynamicHyperText Demo'),
        ),
        body: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: DynamicHyperText(
                text:
                    'Hello @user! Check out https://example.com and join \$FlutterCandies\$ [love] {bg:FFE0B2:This text has a background}',
                style: TextStyle(fontSize: 16),
                overflow: TextOverflow.visible,
                maxLines: 4,
                overflowWidget: TextOverflowWidget(
                  position: TextOverflowPosition.end,
                  child: Text('... Read More'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
