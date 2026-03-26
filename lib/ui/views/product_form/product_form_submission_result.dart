class ProductFormSubmissionResult {
  const ProductFormSubmissionResult._({
    required this.message,
    required this.didSucceed,
  });

  const ProductFormSubmissionResult.success(String message)
      : this._(message: message, didSucceed: true);

  const ProductFormSubmissionResult.failure(String message)
      : this._(message: message, didSucceed: false);

  final String message;
  final bool didSucceed;
}
