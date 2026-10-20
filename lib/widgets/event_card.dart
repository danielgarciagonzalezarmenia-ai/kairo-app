import 'package:flutter/cupertino.dart';
import '../models/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool isFavorite;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? const Color(0xFF2C2C2E)
                : const Color(0xFFE5E5EA),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: event.thumbnailUrl != null
                      ? Image.network(
                          event.thumbnailUrl!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            height: 150,
                            color: isDark
                                ? const Color(0xFF2C2C2E)
                                : const Color(0xFFF2F2F7),
                            child: Icon(
                              CupertinoIcons.hand_raised_fill,
                              size: 40,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        )
                      : Container(
                          height: 150,
                          color: isDark
                              ? const Color(0xFF2C2C2E)
                              : const Color(0xFFF2F2F7),
                            child: Icon(
                              CupertinoIcons.hand_raised_fill,
                              size: 40,
                              color: CupertinoColors.systemGrey,
                            ),
                        ),
                ),
                if (event.isLive)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF3B30).withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: Offset.zero,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'EN VIVO',
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: onFavoriteToggle,
                    child: Icon(
                      isFavorite
                          ? CupertinoIcons.star_fill
                          : CupertinoIcons.star,
                      color: isFavorite
                          ? const Color(0xFFFF3B30)
                          : CupertinoColors.systemGrey,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        event.sport,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.systemGrey,
                          letterSpacing: 0.4,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2C2C2E)
                            : const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                        child: Text(
                          event.displayTime,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: event.isLive
                                ? const Color(0xFFFF3B30)
                                : CupertinoColors.systemGrey,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (event.hasScore) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.scoreDisplay,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SF Pro Rounded',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
