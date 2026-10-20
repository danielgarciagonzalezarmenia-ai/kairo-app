import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';
import '../services/preferences_service.dart';
import '../widgets/event_card.dart';
import '../widgets/live_tag.dart';
import '../widgets/sport_chip.dart';
import '../screens/player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _sports = [
    {'label': 'Fútbol', 'icon': CupertinoIcons.hand_raised_fill},
    {'label': 'Baloncesto', 'icon': CupertinoIcons.hand_raised_fill},
    {'label': 'Béisbol', 'icon': CupertinoIcons.hand_raised_fill},
    {'label': 'Tenis', 'icon': CupertinoIcons.hand_raised_fill},
    {'label': 'F1', 'icon': CupertinoIcons.car},
    {'label': 'Boxeo', 'icon': CupertinoIcons.hand_raised_fill},
    {'label': 'NFL', 'icon': CupertinoIcons.hand_raised_fill},
    {'label': 'MMA', 'icon': CupertinoIcons.hand_raised_fill},
  ];
  int _selectedSport = 0;
  final PageController _heroController = PageController();
  final _api = ApiService();
  final _token = TokenService();
  final _prefs = PreferencesService();
  List<Event> _liveEvents = [];
  List<Event> _upcomingEvents = [];
  List<Event> _featuredEvents = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _prefs.init();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _loading = true);
      final channels = await _api.getChannels();
      final schedule = await _api.getSchedule();
      _parseSchedule(schedule);
      for (final ch in channels) {
        final cid = ch['channel_id']?.toString() ?? '';
        if (cid.isNotEmpty) {
          _featuredEvents.add(Event(
            id: cid,
            title: ch['channel_name'] ?? 'Canal $cid',
            sport: '24/7',
            startTime: DateTime.now(),
            isLive: true,
            channelId: cid,
            channelName: ch['channel_name'] ?? 'Canal',
            logoUrl: ch['logo_url'],
          ));
        }
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _parseSchedule(Map<String, dynamic> schedule) {
    for (final dayKey in schedule.keys) {
      final day = schedule[dayKey];
      if (day == null || day is! Map) continue;
      for (final catKey in day.keys) {
        final cat = day[catKey];
        if (cat == null || cat is! List) continue;
        for (final item in cat) {
          if (item == null || item is! Map) continue;
          _upcomingEvents.add(Event.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    _liveEvents = _upcomingEvents.where((e) => e.isLive).toList();
  }

  Future<void> _playEvent(Event event) async {
    try {
      final tokenData = await _token.fetchToken(event.channelId);
      final m3u8Url = _token.buildM3u8Url(event.channelId, tokenData['token']);
      if (mounted) {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => PlayerScreen(
              event: event,
              m3u8Url: m3u8Url,
              token: tokenData['token'],
              ttl: tokenData['ttl'],
              onTokenRefresh: () async {
                final fresh = await _token.fetchToken(event.channelId);
                return _token.buildM3u8Url(event.channelId, fresh['token']);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('No se pudo cargar el stream: $e'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Aceptar'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _buildHero() {
    if (_featuredEvents.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          PageView.builder(
            controller: _heroController,
            itemCount: _featuredEvents.length,
            itemBuilder: (_, i) {
              final e = _featuredEvents[i];
              return _HeroCard(event: e, onTap: () => _playEvent(e));
            },
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _featuredEvents.length,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _heroController.hasClients &&
                            _heroController.page!.round() == i
                        ? const Color(0xFF0A84FF)
                        : const Color(0xFFFFFFFF).withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Event> events) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SF Pro Display',
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {},
                child: const Text(
                  'Ver todo',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: events.length,
            itemBuilder: (_, i) {
              final e = events[i];
              return Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: i == events.length - 1 ? 16 : 8,
                  bottom: 16,
                ),
                child: EventCard(
                  event: e,
                  onTap: () => _playEvent(e),
                  onFavoriteToggle: () => _prefs.toggleFavorite(e.id),
                  isFavorite: _prefs.isFavorite(e.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _heroController.dispose();
    _api.dispose();
    _token.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }
    if (_error != null) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Kairo'),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.exclamationmark_triangle,
                  size: 48, color: CupertinoColors.systemGrey),
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(color: CupertinoColors.systemGrey),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              CupertinoButton(
                color: const Color(0xFF0A84FF),
                onPressed: _loadData,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Kairo',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF Pro Display',
            )),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: const Icon(CupertinoIcons.search, size: 26),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: const Icon(CupertinoIcons.person_circle, size: 26),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 10),
            _buildHero(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Deportes',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 86,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _sports.length,
                itemBuilder: (_, i) {
                  final s = _sports[i];
                  return Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: i == _sports.length - 1 ? 16 : 8,
                    ),
                    child: SportChip(
                      label: s['label'] as String,
                      icon: s['icon'] as IconData,
                      selected: _selectedSport == i,
                      onTap: () => setState(() => _selectedSport = i),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            if (_liveEvents.isNotEmpty)
              _buildSection('En vivo ahora', _liveEvents),
            const SizedBox(height: 16),
            _buildSection('Próximos eventos',
                _upcomingEvents.take(10).toList()),
            const SizedBox(height: 16),
            _buildSection('Destacados',
                _featuredEvents.take(10).toList()),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  const _HeroCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF000000)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              event.thumbnailUrl != null
                  ? Image.network(
                      event.thumbnailUrl!,
                      height: 320,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 320,
                      color: isDark
                          ? const Color(0xFF1C1C1E)
                          : const Color(0xFFF2F2F7),
                    ),
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LiveTag(live: true),
                    const SizedBox(height: 12),
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro Display',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 44,
                      child: CupertinoButton.filled(
                        onPressed: onTap,
                        child: const Text('Ver ahora',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
