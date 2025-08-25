import 'package:flutter/material.dart';
import 'translation_single_screen.dart';
import 'document_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation App'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Single Translation'),
            Tab(text: 'Document Translation'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TranslationScreen(),
          DocumentScreen(),
        ],
      ),
    );
  }
}