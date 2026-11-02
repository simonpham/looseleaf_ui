/// Where the newsletter sign-up is: waiting, turned away, sending, failed
/// or done.
///
/// Mirrors `Newsletter01Status` in upstream
/// `src/blocks/newsletter-01/components/newsletter-01-form.tsx`.
enum Newsletter01Status {
  idle,
  invalid,
  sending,
  failed,
  done;

  /// Whether the address field shows an error.
  bool get bad => this == invalid || this == failed;
}
