import 'package:flutter/material.dart';

class IconPickerModal extends StatelessWidget {
  final List<String> usedIcons;
  final bool error;

  const IconPickerModal({
    super.key,
    required this.usedIcons,
    this.error = false,
  });

  static final Map<String, IconData> iconMap = {
    'snowshoeing': Icons.snowshoeing,
    'paragliding': Icons.paragliding,
    'snowboarding:': Icons.snowboarding,
    'thunderstorm': Icons.thunderstorm,
    'sports_football': Icons.sports_football,
    'sanitizer': Icons.sanitizer,
    'surfing': Icons.surfing,
    'sports_volleyball': Icons.sports_volleyball,
    'sports_motorsports': Icons.sports_motorsports,
    'cookie': Icons.cookie,
    'compost': Icons.compost,
    'workspace_premium': Icons.workspace_premium,
    'webhook': Icons.webhook,
    'api': Icons.api,
    'loyalty': Icons.loyalty,
    'catching_pokemon': Icons.catching_pokemon,
    'pest_control_rodent': Icons.pest_control_rodent,
    'hive': Icons.hive,
    'flutter_dash': Icons.flutter_dash,
    'egg': Icons.egg,
    'bug_report': Icons.bug_report,
    'cruelty_free': Icons.cruelty_free,
    'account_balance': Icons.account_balance,
    'anchor': Icons.anchor,
    'apartment': Icons.apartment,
    'attach_money': Icons.attach_money,
    'auto_awesome': Icons.auto_awesome,
    'beach_access': Icons.beach_access,
    'book': Icons.book,
    'brush': Icons.brush,
    'build': Icons.build,
    'business': Icons.business,
    'cake': Icons.cake,
    'camera_alt': Icons.camera_alt,
    'celebration': Icons.celebration,
    'check_circle': Icons.check_circle,
    'color_lens': Icons.color_lens,
    'commute': Icons.commute,
    'directions_bike': Icons.directions_bike,
    'directions_car': Icons.directions_car,
    'directions_run': Icons.directions_run,
    'directions_walk': Icons.directions_walk,
    'diversity_3': Icons.diversity_3,
    'domain': Icons.domain,
    'eco': Icons.eco,
    'emoji_emotions': Icons.emoji_emotions,
    'emoji_events': Icons.emoji_events,
    'emoji_flags': Icons.emoji_flags,
    'emoji_food_beverage': Icons.emoji_food_beverage,
    'emoji_nature': Icons.emoji_nature,
    'emoji_people': Icons.emoji_people,
    'emoji_transportation': Icons.emoji_transportation,
    'engineering': Icons.engineering,
    'event': Icons.event,
    'explore': Icons.explore,
    'face': Icons.face,
    'fastfood': Icons.fastfood,
    'favorite': Icons.favorite,
    'favorite_border': Icons.favorite_border,
    'fitness_center': Icons.fitness_center,
    'flare': Icons.flare,
    'flight': Icons.flight,
    'hiking': Icons.hiking,
    'home': Icons.home,
    'house': Icons.house,
    'icecream': Icons.icecream,
    'lightbulb': Icons.lightbulb,
    'local_airport': Icons.local_airport,
    'local_cafe': Icons.local_cafe,
    'local_dining': Icons.local_dining,
    'local_florist': Icons.local_florist,
    'local_pizza': Icons.local_pizza,
    'location_on': Icons.location_on,
    'map': Icons.map,
    'menu_book': Icons.menu_book,
    'music_note': Icons.music_note,
    'navigation': Icons.navigation,
    'nights_stay': Icons.nights_stay,
    'palette': Icons.palette,
    'person': Icons.person,
    'pets': Icons.pets,
    'psychology': Icons.psychology,
    'public': Icons.public,
    'recycling': Icons.recycling,
    'rocket': Icons.rocket,
    'sailing': Icons.sailing,
    'school': Icons.school,
    'science': Icons.science,
    'security': Icons.security,
    'self_improvement': Icons.self_improvement,
    'sentiment_dissatisfied': Icons.sentiment_dissatisfied,
    'sentiment_satisfied': Icons.sentiment_satisfied,
    'sentiment_very_dissatisfied': Icons.sentiment_very_dissatisfied,
    'sentiment_very_satisfied': Icons.sentiment_very_satisfied,
    'shopping_bag': Icons.shopping_bag,
    'spa': Icons.spa,
    'sports_basketball': Icons.sports_basketball,
    'sports_esports': Icons.sports_esports,
    'sports_soccer': Icons.sports_soccer,
    'sports_tennis': Icons.sports_tennis,
    'star': Icons.star,
    'star_border': Icons.star_border,
    'store': Icons.store,
    'style': Icons.style,
    'thumb_up': Icons.thumb_up,
    'train': Icons.train,
    'travel_explore': Icons.travel_explore,
    'wb_sunny': Icons.wb_sunny,
    'work': Icons.work,
  };

  @override
  Widget build(BuildContext context) {
    final iconNames = iconMap.keys.toList();

    return AlertDialog(
      title: const Text('アイコンを選択'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (error)
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                '※ 使用済みアイコンの取得に失敗しました',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          SizedBox(
            width: double.maxFinite,
            height: 400,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
              ),
              itemCount: iconNames.length,
              itemBuilder: (context, index) {
                final iconName = iconNames[index];
                final isUsed = usedIcons.contains(iconName);
                final iconData = iconMap[iconName]!;

                return GestureDetector(
                  onTap: isUsed
                      ? null
                      : () {
                          Navigator.of(context).pop(iconName);
                        },
                  child: Opacity(
                    opacity: isUsed ? 0.3 : 1.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(iconData, size: 30),
                        Text(
                          iconName,
                          style: const TextStyle(fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('キャンセル'),
        ),
      ],
    );
  }
}
