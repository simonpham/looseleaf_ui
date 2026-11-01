import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../support/fixture_frames.dart';
import '../support/fixture_source.dart';

void main() {
  final frame = FixtureFrame.named('button-outline');

  test('bucketBox rounds to the 4×2 grid like upstream', () {
    expect(InkFrameRequest.bucketBox(const Size(121, 39)), const Size(120, 40));
    expect(InkFrameRequest.bucketBox(const Size(122, 41)), const Size(124, 42));
    expect(InkFrameRequest.bucketBox(const Size(1, 0.4)), const Size(4, 2));
  });

  test('keys frames like upstream frameKey', () {
    final source = FixtureSource(frame);
    final key = InkFrameCache.keyOf(
      source,
      const InkFrameRequest(
        box: Size(121, 40),
        seed: 's1',
        density: LooseleafDensity.calm,
        tier: LooseleafTier.hi,
      ),
    );
    expect(key, 'fixture-button-outline@1|120x40|s1|lo|calm|ltr||{}|1,1,1,1');
  });

  test('draws once per key and parses eagerly', () {
    final cache = InkFrameCache();
    final source = FixtureSource(frame, lazyLayers: {'focus', 'pressed'});
    const request = InkFrameRequest(box: Size(120, 40), seed: 'a');
    final first = cache.frame(source, request);
    final second = cache.frame(source, request);
    expect(identical(first, second), isTrue);
    expect(source.requests, hasLength(1));
    expect(cache.hits, 1);
    expect(cache.misses, 1);
    expect(first.has('focus'), isFalse);
    expect(first.layers.first, 'rest');
  });

  test('draws lazy layers on demand and keeps them', () {
    final cache = InkFrameCache();
    final source = FixtureSource(frame, lazyLayers: {'focus', 'pressed'});
    const request = InkFrameRequest(box: Size(120, 40), seed: 'a');
    cache.frame(source, request);
    final focused = cache.frame(
      source,
      request.withLazy({'focus'}, lazyOnly: false),
    );
    expect(focused.has('focus'), isTrue);
    expect(source.requests.last.lazyOnly, isTrue);
    expect(source.requests.last.lazy, {'focus'});
    cache.frame(source, request.withLazy({'focus'}, lazyOnly: false));
    expect(source.requests, hasLength(2));
    expect(focused.layers.last, 'focus');
  });

  test('evicts the least recently used frames past its budget', () {
    final cache = InkFrameCache(maxEntries: 2);
    final source = FixtureSource(frame);
    for (final seed in ['a', 'b', 'c']) {
      cache.frame(
        source,
        InkFrameRequest(box: const Size(120, 40), seed: seed),
      );
    }
    expect(cache.length, 2);
    cache.frame(source, const InkFrameRequest(box: Size(120, 40), seed: 'a'));
    expect(cache.misses, 4);
  });
}
