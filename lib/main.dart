import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/controllers/menubController.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final MenubController menuController = Get.put(MenubController());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Hello World"),
        ),
        body: Obx(() {
          switch (menuController.selectedIndex.value) {
            case 0:
              return Center(child: Text("Home"));
            case 1:
              return Center(child: Text("Profile"));
            default:
              return Container();
          }
        }),
        bottomNavigationBar: Obx(() {
          return BottomNavigationBar(
            currentIndex: menuController.selectedIndex.value,
            onTap: menuController.changeIndex,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          );
        }),
      ),
    );
  }
}
