import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple provider tracking the active bottom-nav tab index.
final mainTabProvider = StateProvider<int>((ref) => 0);
