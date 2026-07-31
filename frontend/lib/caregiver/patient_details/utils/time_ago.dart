String formatTimeAgo(DateTime? dateTime) {
  if (dateTime == null) return 'Not checked yet';

  final difference = DateTime.now().difference(dateTime);

  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
  }
  if (difference.inHours < 24) {
    final hours = difference.inHours;
    return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
  }
  final days = difference.inDays;
  return '$days ${days == 1 ? 'day' : 'days'} ago';
}