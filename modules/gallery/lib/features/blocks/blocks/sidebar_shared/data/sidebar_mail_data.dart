/// A mailbox folder.
enum MailFolder {
  inbox('Inbox', 'inbox'),
  drafts('Drafts', 'file'),
  sent('Sent', 'send'),
  junk('Junk', 'archive'),
  trash('Trash', 'trash');

  const MailFolder(this.title, this.icon);

  final String title;
  final String icon;
}

/// A letter in the mailbox.
class Mail {
  const Mail({
    required this.id,
    required this.name,
    required this.email,
    required this.subject,
    required this.date,
    required this.teaser,
    required this.folder,
    this.unread = false,
  });

  final String id;
  final String name;
  final String email;
  final String subject;
  final String date;

  /// The first lines, one per line break.
  final String teaser;
  final MailFolder folder;
  final bool unread;
}

/// Mirrors `mails` in upstream `src/blocks/sidebar-shared/sidebar-data.ts`.
const mails = [
  Mail(
    id: 'm1',
    name: 'Ada Lovelace',
    email: 'ada@looseleaf.example',
    subject: 'Meeting tomorrow',
    date: '09:34',
    teaser:
        'Hi team, a reminder about tomorrow at ten.\nPlease bring your sketchbooks and one good pen.',
    folder: MailFolder.inbox,
    unread: true,
  ),
  Mail(
    id: 'm2',
    name: 'Mika Kobayashi',
    email: 'mika@looseleaf.example',
    subject: 'Re: Postcard proofs',
    date: 'Yesterday',
    teaser:
        'The proofs look lovely. The blue is a touch loud on kraft.\nCan we try the graphite version too?',
    folder: MailFolder.inbox,
    unread: true,
  ),
  Mail(
    id: 'm3',
    name: 'Sam Reyes',
    email: 'sam@looseleaf.example',
    subject: 'Weekend plans',
    date: '2 days ago',
    teaser:
        'Thinking of a sketch walk on Saturday.\nHills or harbour, you choose. Bring a flask.',
    folder: MailFolder.inbox,
  ),
  Mail(
    id: 'm4',
    name: 'Emily Davis',
    email: 'emily@looseleaf.example',
    subject: 'Re: Question about the budget',
    date: '2 days ago',
    teaser:
        'I went through the numbers you sent.\nCould we have a quick call about the paper costs?',
    folder: MailFolder.inbox,
  ),
  Mail(
    id: 'm5',
    name: 'Michael Wilson',
    email: 'michael@looseleaf.example',
    subject: 'Big announcement',
    date: '1 week ago',
    teaser:
        'All hands on Friday at three.\nThere is news about the new studio, and there will be cake.',
    folder: MailFolder.inbox,
    unread: true,
  ),
  Mail(
    id: 'm6',
    name: 'Sarah Brown',
    email: 'sarah@looseleaf.example',
    subject: 'Feedback on the proposal',
    date: '1 week ago',
    teaser:
        'Thank you for the proposal. I have a few thoughts.\nCould we meet so I can walk you through them?',
    folder: MailFolder.inbox,
  ),
  Mail(
    id: 'm7',
    name: 'You',
    email: 'jo@looseleaf.example',
    subject: 'Draft: Spring catalog intro',
    date: 'Tuesday',
    teaser:
        'Every spring the studio opens its windows, and the pens come out of their tins.\nThis year we made something a bit different.',
    folder: MailFolder.drafts,
  ),
  Mail(
    id: 'm8',
    name: 'You',
    email: 'jo@looseleaf.example',
    subject: 'Draft: Thank-you notes',
    date: 'Last week',
    teaser:
        'Dear all, thank you for a wonderful season.\nA list of what we learned is enclosed.',
    folder: MailFolder.drafts,
  ),
  Mail(
    id: 'm9',
    name: 'To: Ada Lovelace',
    email: 'ada@looseleaf.example',
    subject: 'Re: Meeting tomorrow',
    date: '09:41',
    teaser: 'Ten is perfect. I will bring the kraft pad and the good pen.',
    folder: MailFolder.sent,
  ),
  Mail(
    id: 'm10',
    name: 'To: Mika Kobayashi',
    email: 'mika@looseleaf.example',
    subject: 'Postcard proofs',
    date: 'Monday',
    teaser:
        'Attached are the proofs for the spring run.\nTell me what you think of the wobble on the border.',
    folder: MailFolder.sent,
  ),
  Mail(
    id: 'm11',
    name: 'Stationery Deals',
    email: 'deals@example.com',
    subject: 'You have won a lifetime of ink',
    date: '3 days ago',
    teaser:
        'Click here to claim your free lifetime supply of ink.\nOffer ends tonight.',
    folder: MailFolder.junk,
  ),
  Mail(
    id: 'm12',
    name: 'Old Newsletter',
    email: 'news@example.com',
    subject: 'Last month at the paper mill',
    date: '2 weeks ago',
    teaser:
        'A roundup of what happened at the mill.\nYou are receiving this because you signed up in 2019.',
    folder: MailFolder.trash,
  ),
];
