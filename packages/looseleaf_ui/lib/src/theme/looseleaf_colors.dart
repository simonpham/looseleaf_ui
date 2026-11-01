import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Looseleaf's paint tokens, the `--ll-*` colors of `src/styles/looseleaf.css`.
///
/// Ink markup names them as `var(--ll-<name>)`; [token] resolves those names,
/// including the derived tokens the stylesheet mixes from the base ones.
class LooseleafColors {
  /// Creates a palette. Every token defaults to Looseleaf's light theme.
  const LooseleafColors({
    this.desk = const Color(0xFFA8C8BB),
    this.deskDeep = const Color(0xFF93B4A7),
    this.paper = const Color(0xFFF8F5EE),
    this.paperShade = const Color(0xFFECE6DA),
    this.slip = const Color(0xFFFBF8F1),
    this.card = const Color(0xFFFBF6E9),
    this.graph = const Color(0xFFF4F7EF),
    this.kraft = const Color(0xFFDCC8A3),
    this.check = const Color(0xFFDFE9D8),
    this.pad = const Color(0xFFF8F2DE),
    this.photo = const Color(0xFFFFFDF6),
    this.ruleBlue = const Color(0xFF8FB0D4),
    this.ruleRed = const Color(0xFFD9776A),
    this.padRule = const Color(0xFFB2C3DC),
    this.checkRule = const Color(0xFF7FA37C),
    this.stickyYellow = const Color(0xFFF7E38A),
    this.stickyGreen = const Color(0xFFCFE6A8),
    this.stickyOrange = const Color(0xFFF7C08E),
    this.stickyPink = const Color(0xFFF6B8B0),
    this.stickyBlue = const Color(0xFFBCD8F0),
    this.ink = const Color(0xFF2A2420),
    this.inkSoft = const Color(0xFF4A423B),
    this.inkMuted = const Color(0xFF4A433C),
    this.inkYou = const Color(0xFF2C4F9E),
    this.pencil = const Color(0xFF6B6660),
    this.pencilText = const Color(0xFF5A554E),
    this.pencilMark = const Color(0xFF8E887F),
    this.red = const Color(0xFFC2412D),
    this.green = const Color(0xFF3B7A4B),
    this.marker = const Color(0xFFDF6B3C),
    this.orangeText = const Color(0xFFA4502A),
    this.hi = const Color(0xFFF8DC4C),
    this.hiDeep = const Color(0xFFA87F0C),
    this.focus = const Color(0xFF2C4F9E),
    this.linkHover = const Color(0xFF1F3B7A),
    this.checkInk = const Color(0xFF2F6B45),
    this.checkNo = const Color(0xFFB23A28),
    this.tomato = const Color(0xFFE8483A),
    this.tangerine = const Color(0xFFF59A2F),
    this.lemon = const Color(0xFFFBD63A),
    this.grass = const Color(0xFF5DB85C),
    this.teal = const Color(0xFF2FB1A3),
    this.sky = const Color(0xFF4AA8E8),
    this.grape = const Color(0xFF8F6FD6),
    this.bubblegum = const Color(0xFFF38BB8),
    this.tape = const Color(0x80F6F4EC),
    this.tapeEdge = const Color(0x598C8778),
    this.wetInkFrom = const Color(0xFF15110E),
    this.shade = const Color(0xFF3A2C1E),
  });

  final Color desk;
  final Color deskDeep;
  final Color paper;
  final Color paperShade;
  final Color slip;
  final Color card;
  final Color graph;
  final Color kraft;
  final Color check;
  final Color pad;
  final Color photo;
  final Color ruleBlue;
  final Color ruleRed;
  final Color padRule;
  final Color checkRule;
  final Color stickyYellow;
  final Color stickyGreen;
  final Color stickyOrange;
  final Color stickyPink;
  final Color stickyBlue;
  final Color ink;
  final Color inkSoft;
  final Color inkMuted;
  final Color inkYou;
  final Color pencil;
  final Color pencilText;
  final Color pencilMark;
  final Color red;
  final Color green;
  final Color marker;
  final Color orangeText;
  final Color hi;
  final Color hiDeep;
  final Color focus;
  final Color linkHover;
  final Color checkInk;
  final Color checkNo;
  final Color tomato;
  final Color tangerine;
  final Color lemon;
  final Color grass;
  final Color teal;
  final Color sky;
  final Color grape;
  final Color bubblegum;
  final Color tape;
  final Color tapeEdge;
  final Color wetInkFrom;

  /// The warm shadow tint, `--ll-shade` (`--ll-umber` is this color, opaque).
  final Color shade;

  Color get umber => shade;
  Color get line => pencilMark;
  Color get lineSoft => _fade(pencilMark, 0.55);
  Color get link => inkYou;
  Color get inputInk => inkYou;
  Color get caret => inkYou;
  Color get placeholder => pencilText;
  Color get hiSelect => _fade(hi, 0.62);
  Color get selectionText => ink;
  Color get riso => marker;
  Color get stampFill => _fade(marker, 0.5);
  Color get stampFillRed => _fade(red, 0.28);
  Color get stampFillGreen => _fade(green, 0.24);
  Color get diffAdd => _fade(green, 0.16);
  Color get diffDel => _fade(red, 0.14);

  /// The token named `--ll-<name>`, or null when Looseleaf has no such color.
  Color? token(String name) => switch (name) {
    'desk' => desk,
    'desk-deep' => deskDeep,
    'paper' => paper,
    'paper-shade' => paperShade,
    'slip' => slip,
    'card' => card,
    'graph' => graph,
    'kraft' => kraft,
    'check' => check,
    'pad' => pad,
    'photo' => photo,
    'rule-blue' => ruleBlue,
    'rule-red' => ruleRed,
    'pad-rule' => padRule,
    'check-rule' => checkRule,
    'sticky-yellow' => stickyYellow,
    'sticky-green' => stickyGreen,
    'sticky-orange' => stickyOrange,
    'sticky-pink' => stickyPink,
    'sticky-blue' => stickyBlue,
    'ink' => ink,
    'ink-soft' => inkSoft,
    'ink-muted' => inkMuted,
    'ink-you' => inkYou,
    'pencil' => pencil,
    'pencil-text' => pencilText,
    'pencil-mark' => pencilMark,
    'red' => red,
    'green' => green,
    'marker' => marker,
    'orange-text' => orangeText,
    'hi' => hi,
    'hi-deep' => hiDeep,
    'focus' => focus,
    'link-hover' => linkHover,
    'check-ink' => checkInk,
    'check-no' => checkNo,
    'tomato' => tomato,
    'tangerine' => tangerine,
    'lemon' => lemon,
    'grass' => grass,
    'teal' => teal,
    'sky' => sky,
    'grape' => grape,
    'bubblegum' => bubblegum,
    'tape' => tape,
    'tape-edge' => tapeEdge,
    'wet-ink-from' => wetInkFrom,
    'umber' => umber,
    'line' => line,
    'line-soft' => lineSoft,
    'link' => link,
    'input-ink' => inputInk,
    'caret' => caret,
    'placeholder' => placeholder,
    'hi-select' => hiSelect,
    'selection-text' => selectionText,
    'riso' => riso,
    'stamp-fill' => stampFill,
    'stamp-fill-red' => stampFillRed,
    'stamp-fill-green' => stampFillGreen,
    'diff-add' => diffAdd,
    'diff-del' => diffDel,
    _ => null,
  };

  static Color _fade(Color color, double amount) =>
      color.withValues(alpha: color.a * amount);

  /// A copy with the given tokens replaced.
  LooseleafColors copyWith({
    Color? paper,
    Color? ink,
    Color? inkSoft,
    Color? inkMuted,
    Color? pencilText,
    Color? marker,
    Color? hi,
    Color? focus,
    Color? photo,
    Color? pencil,
    Color? pencilMark,
    Color? inkYou,
    Color? red,
    Color? green,
    Color? orangeText,
    Color? hiDeep,
    Color? grape,
  }) => LooseleafColors(
    desk: desk,
    deskDeep: deskDeep,
    paper: paper ?? this.paper,
    paperShade: paperShade,
    slip: slip,
    card: card,
    graph: graph,
    kraft: kraft,
    check: check,
    pad: pad,
    photo: photo ?? this.photo,
    ruleBlue: ruleBlue,
    ruleRed: ruleRed,
    padRule: padRule,
    checkRule: checkRule,
    stickyYellow: stickyYellow,
    stickyGreen: stickyGreen,
    stickyOrange: stickyOrange,
    stickyPink: stickyPink,
    stickyBlue: stickyBlue,
    ink: ink ?? this.ink,
    inkSoft: inkSoft ?? this.inkSoft,
    inkMuted: inkMuted ?? this.inkMuted,
    inkYou: inkYou ?? this.inkYou,
    pencil: pencil ?? this.pencil,
    pencilText: pencilText ?? this.pencilText,
    pencilMark: pencilMark ?? this.pencilMark,
    red: red ?? this.red,
    green: green ?? this.green,
    marker: marker ?? this.marker,
    orangeText: orangeText ?? this.orangeText,
    hi: hi ?? this.hi,
    hiDeep: hiDeep ?? this.hiDeep,
    focus: focus ?? this.focus,
    linkHover: linkHover,
    checkInk: checkInk,
    checkNo: checkNo,
    tomato: tomato,
    tangerine: tangerine,
    lemon: lemon,
    grass: grass,
    teal: teal,
    sky: sky,
    grape: grape ?? this.grape,
    bubblegum: bubblegum,
    tape: tape,
    tapeEdge: tapeEdge,
    wetInkFrom: wetInkFrom,
    shade: shade,
  );

  @override
  bool operator ==(Object other) =>
      other is LooseleafColors && listEquals(_all, other._all);

  @override
  int get hashCode => Object.hashAll(_all);

  List<Color> get _all => [
    desk,
    deskDeep,
    paper,
    paperShade,
    slip,
    card,
    graph,
    kraft,
    check,
    pad,
    photo,
    ruleBlue,
    ruleRed,
    padRule,
    checkRule,
    stickyYellow,
    stickyGreen,
    stickyOrange,
    stickyPink,
    stickyBlue,
    ink,
    inkSoft,
    inkMuted,
    inkYou,
    pencil,
    pencilText,
    pencilMark,
    red,
    green,
    marker,
    orangeText,
    hi,
    hiDeep,
    focus,
    linkHover,
    checkInk,
    checkNo,
    tomato,
    tangerine,
    lemon,
    grass,
    teal,
    sky,
    grape,
    bubblegum,
    tape,
    tapeEdge,
    wetInkFrom,
    shade,
  ];
}
