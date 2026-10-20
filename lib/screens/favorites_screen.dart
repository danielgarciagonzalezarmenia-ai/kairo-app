import 'package:flutter/cupertino.dart';
import '../services/preferences_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _prefs = PreferencesService();
  List<String> _favoriteIds = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _prefs.init();
    if (mounted) setState(() => _favoriteIds = _prefs.favoriteIds);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Favoritos',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF Pro Display',
            )),
      ),
      child: _favoriteIds.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.star, size: 64, color: CupertinoColors.systemGrey),
                  SizedBox(height: 16),
                  Text('No hay favoritos aún',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 17,
                      )),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _favoriteIds.length,
              itemBuilder: (_, i) {
                return CupertinoListTile(
                  leading: const Icon(CupertinoIcons.star_fill,
                      color: Color(0xFFFF3B30)),
                  title: Text('Evento ${_favoriteIds[i]}'),
                  onTap: () {},
                );
              },
            ),
    );
  }
}

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Calendario',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF Pro Display',
            )),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.calendar, size: 64, color: CupertinoColors.systemGrey),
            SizedBox(height: 16),
            Text('Calendario de eventos',
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 17,
                )),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Ajustes',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF Pro Display',
            )),
      ),
      child: ListView(
        children: [
          const SizedBox(height: 20),
          _SectionTile(
            title: 'Acerca de Kairo',
            subtitle: 'Versión 1.0.0',
            onTap: () {},
          ),
          _SectionTile(
            title: 'Términos y condiciones',
            onTap: () {},
          ),
          _SectionTile(
            title: 'Política de privacidad',
            onTap: () {},
          ),
          _SectionTile(
            title: 'Notificaciones',
            subtitle: 'Recibe alertas de tus eventos favoritos',
            trailing: CupertinoSwitch(
              value: true,
              onChanged: (_) {},
            ),
            onTap: () {},
          ),
          _SectionTile(
            title: 'Modo oscuro',
            subtitle: 'Sigue el sistema',
            trailing: CupertinoSwitch(
              value: true,
              onChanged: (_) {},
            ),
            onTap: () {},
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SectionTile({
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: const TextStyle(
                  fontSize: 13, color: CupertinoColors.systemGrey))
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
