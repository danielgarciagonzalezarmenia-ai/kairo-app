import 'package:flutter/cupertino.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house),
            activeIcon: Icon(CupertinoIcons.house_fill),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.tv),
            activeIcon: Icon(CupertinoIcons.tv_fill),
            label: 'En vivo',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar),
            activeIcon: Icon(CupertinoIcons.calendar),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.star),
            activeIcon: Icon(CupertinoIcons.star_fill),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            activeIcon: Icon(CupertinoIcons.person_fill),
            label: 'Perfil',
          ),
        ],
      ),
      tabBuilder: (context, i) {
        switch (i) {
          case 0:
            return const HomeScreen();
          case 1:
            return const HomeScreen();
          case 2:
            return const SchedulePlaceholder();
          case 3:
            return const FavoritesScreen();
          default:
            return const SettingsPlaceholder();
        }
      },
    );
  }
}

class SchedulePlaceholder extends StatelessWidget {
  const SchedulePlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Calendario'),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.calendar, size: 64, color: CupertinoColors.systemGrey),
            SizedBox(height: 16),
            Text('Calendario de eventos',
                style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 17)),
          ],
        ),
      ),
    );
  }
}

class SettingsPlaceholder extends StatelessWidget {
  const SettingsPlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Perfil'),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.person, size: 64, color: CupertinoColors.systemGrey),
            SizedBox(height: 16),
            Text('Tu perfil',
                style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 17)),
          ],
        ),
      ),
    );
  }
}
