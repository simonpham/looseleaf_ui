/// Where a letter is filed.
enum InboxFolder {
  inbox('Inbox', 'inbox'),
  archive('Archive', 'archive'),
  trash('Trash', 'trash');

  const InboxFolder(this.label, this.icon);

  final String label;
  final String icon;
}

/// One letter in the post.
///
/// Mirrors `Mail` in upstream `src/blocks/inbox/components/inbox-data.ts`.
class InboxMail {
  const InboxMail({
    required this.id,
    required this.from,
    required this.address,
    required this.subject,
    required this.date,
    required this.body,
    this.unread = false,
    this.starred = false,
    this.folder = InboxFolder.inbox,
    this.attachments = const [],
    this.replies = const [],
  });

  final String id;
  final String from;
  final String address;
  final String subject;
  final String date;
  final List<String> body;
  final bool unread;
  final bool starred;
  final InboxFolder folder;
  final List<String> attachments;
  final List<String> replies;

  /// The first word of [from], to greet them by.
  String get firstName => from.split(' ').first;

  InboxMail copyWith({
    bool? unread,
    bool? starred,
    InboxFolder? folder,
    List<String>? replies,
  }) => InboxMail(
    id: id,
    from: from,
    address: address,
    subject: subject,
    date: date,
    body: body,
    unread: unread ?? this.unread,
    starred: starred ?? this.starred,
    folder: folder ?? this.folder,
    attachments: attachments,
    replies: replies ?? this.replies,
  );
}

/// What a folder says when nothing is in it.
({String pose, String title, String text}) inboxEmptyState(
  InboxFolder folder,
) => switch (folder) {
  InboxFolder.inbox => (
    pose: 'celebrate',
    title: 'Inbox zero',
    text: 'Every letter answered or filed. Put the kettle on.',
  ),
  InboxFolder.archive => (
    pose: 'sleep',
    title: 'Nothing filed away',
    text: 'Letters you archive wait here, out of the way.',
  ),
  InboxFolder.trash => (
    pose: 'shrug',
    title: 'The bin is empty',
    text: 'Nothing to throw away, for once.',
  ),
};

const inboxMails = <InboxMail>[
  InboxMail(
    id: 'm1',
    from: 'Ada Lovelace',
    address: 'ada@marigold.example',
    subject: 'The sticker sheet, finally',
    date: '9:12',
    body: [
      'Jo,',
      'I drew the snail. He is smug, which I think is right. Have a look before we send the sheet to print? I would like to keep the shell as it is.',
      'Ada',
    ],
    unread: true,
    attachments: ['snail-sticker.png'],
  ),
  InboxMail(
    id: 'm2',
    from: 'Post Office, rue Cler',
    address: 'noreply@laposte.example',
    subject: 'Your parcel is waiting for you',
    date: '8:03',
    body: [
      'A parcel addressed to Marigold Paper Co. is at the counter.',
      'Please bring a piece of identification. We are open until six, and until noon on Saturdays.',
    ],
    unread: true,
  ),
  InboxMail(
    id: 'm3',
    from: 'Mika Kobayashi',
    address: 'mika@marigold.example',
    subject: 'Photos of the field notebooks',
    date: 'Sep 24',
    body: [
      'Hello!',
      'The light was lovely at four, so I took the whole set again against the kraft paper. They are in the shared folder, the ones marked with a small star are my favorites.',
      'M.',
    ],
    starred: true,
    attachments: ['field-notebooks-contact-sheet.pdf'],
  ),
  InboxMail(
    id: 'm4',
    from: 'Sam Reyes',
    address: 'sam@marigold.example',
    subject: 'Postal code field is fixed',
    date: 'Sep 23',
    body: [
      'It was a stray space after the city name. Nothing more mysterious than that.',
      'It is live now; two customers who got stuck have been written to.',
    ],
  ),
  InboxMail(
    id: 'm5',
    from: 'Lyon Paper Fair',
    address: 'stands@lyonpapier.example',
    subject: 'Your stand is confirmed',
    date: 'Sep 22',
    body: [
      'We are delighted to confirm stand 14 (two meters by three) for the first and second of October.',
      'Set-up begins at 7:30 on the Thursday. There is a coffee cart by the main door, and it is very good.',
    ],
    starred: true,
    attachments: ['stand-plan.pdf', 'set-up-times.pdf'],
  ),
  InboxMail(
    id: 'm6',
    from: 'Ada Lovelace',
    address: 'ada@marigold.example',
    subject: 'Supper on Saturday?',
    date: 'Sep 21',
    body: [
      'Birthday supper at mine, half past seven. Nothing fancy, and please do not bring a present. Bring the good bread if you pass the bakery.',
    ],
  ),
  InboxMail(
    id: 'm7',
    from: 'Bank of the Left Bank',
    address: 'statements@bank.example',
    subject: 'Your statement is ready',
    date: 'Sep 20',
    body: [
      'Your September statement is ready to read. It is not very exciting, which is how we like it.',
    ],
  ),
  InboxMail(
    id: 'm8',
    from: 'Mum',
    address: 'mum@family.example',
    subject: 'Did you eat?',
    date: 'Sep 19',
    body: [
      'Just checking. Also the plum tree has gone mad, so there will be jam. Come and get some jam.',
      'x',
    ],
    starred: true,
  ),
  InboxMail(
    id: 'm9',
    from: 'Pemberton & Sons',
    address: 'accounts@pemberton.example',
    subject: 'Invoice 118, paid with thanks',
    date: 'Sep 18',
    body: [
      'Payment for invoice 118 has gone out today. A receipt is attached for your files.',
    ],
    folder: InboxFolder.archive,
    attachments: ['receipt-118.pdf'],
  ),
  InboxMail(
    id: 'm10',
    from: 'Stationery Weekly',
    address: 'editor@stationeryweekly.example',
    subject: 'Ten pens you will not need',
    date: 'Sep 12',
    body: ['A list of ten pens, all of which you will want anyway.'],
    folder: InboxFolder.trash,
  ),
];
