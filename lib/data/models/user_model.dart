class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.isAnonymous = false,
  });

  final String id;
  final String email;
  final String? displayName;
  final bool isAnonymous;

  factory AppUser.anonymous(String id) {
    return AppUser(
      id: id,
      email: 'guest@cyphlab.app',
      displayName: 'Guest Explorer',
      isAnonymous: true,
    );
  }
}
