/// One question on the FAQ sheet and its answer.
typedef Faq01Question = ({String id, String question, String answer});

/// The questions we get every week.
///
/// Mirrors `QUESTIONS` in upstream
/// `src/blocks/faq-01/components/faq-01-sheet.tsx`.
const List<Faq01Question> faq01Questions = [
  (
    id: 'free',
    question: 'Is there a free plan?',
    answer:
        'Yes. Teams of up to five can use everything, free, for as long as they like. Past five it is \$6 a person a month. No card to start.',
  ),
  (
    id: 'import',
    question: 'Can I bring my notes from other apps?',
    answer:
        'Drag in a folder of Markdown, or a Notion or Evernote export, and your pages and links come across, pictures too. A hundred pages takes about a minute.',
  ),
  (
    id: 'offline',
    question: 'Does it work offline?',
    answer:
        'It does. Keep writing on the train and everything syncs when you are back. If two people changed the same line, you get both versions side by side.',
  ),
  (
    id: 'privacy',
    question: 'Who can see my notebooks?',
    answer:
        'Only the people you invite. A page is private until you share it, and a shared link can be switched off whenever you like.',
  ),
  (
    id: 'backups',
    question: 'How are my pages backed up?',
    answer:
        'Every change is saved and every version is kept for a year. We also take nightly backups in two places, and you can download everything as plain files.',
  ),
  (
    id: 'cancel',
    question: 'Can I cancel any time?',
    answer:
        'In two clicks. Your notebooks stay readable and downloadable afterwards.',
  ),
];
