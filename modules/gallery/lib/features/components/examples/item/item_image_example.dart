import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ItemImageExample extends StatelessWidget {
  const ItemImageExample({super.key});

  static const _maxWidth = Spacing.d448;
  static const _music = [
    (
      title: 'Midnight City Lights',
      artist: 'Neon Dreams',
      album: 'Electric Nights',
      duration: '3:45',
      doodle: 'moon',
    ),
    (
      title: 'Coffee Shop Conversations',
      artist: 'The Morning Brew',
      album: 'Urban Stories',
      duration: '4:05',
      doodle: 'cup',
    ),
    (
      title: 'Digital Rain',
      artist: 'Cyber Symphony',
      album: 'Binary Beats',
      duration: '3:30',
      doodle: 'rain-cloud',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final muted = LooseleafTheme.of(context).colors.inkMuted;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d16,
        children: [
          for (final song in _music)
            InkItem(
              variant: ItemVariant.outline,
              onPressed: () {},
              children: [
                ItemMedia(
                  variant: ItemMediaVariant.image,
                  child: Padding(
                    padding: const EdgeInsets.only(top: Spacing.d2),
                    child: Doodle(song.doodle, size: Spacing.d36),
                  ),
                ),
                ItemContent(
                  children: [
                    ItemTitle(
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: '${song.title} - '),
                            TextSpan(
                              text: song.album,
                              style: TextStyle(color: muted),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ItemDescription(Text(song.artist)),
                  ],
                ),
                ItemDescription(Text(song.duration)),
              ],
            ),
        ],
      ),
    );
  }
}
