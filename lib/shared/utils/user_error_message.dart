/// Maps thrown errors to copy suitable for end users.
String userFriendlyError(Object error) {
  final message = error.toString().toLowerCase();

  if (message.contains('network') ||
      message.contains('socket') ||
      message.contains('connection') ||
      message.contains('offline') ||
      message.contains('timed out') ||
      message.contains('timeout')) {
    return 'Check your internet connection and try again.';
  }
  if (message.contains('permission') || message.contains('denied')) {
    return 'You do not have permission to view this content.';
  }
  if (message.contains('not found') || message.contains('no document')) {
    return 'The requested content could not be found.';
  }
  if (message.contains('unavailable')) {
    return 'This service is temporarily unavailable. Please try again shortly.';
  }

  return 'Something went wrong. Please try again.';
}
