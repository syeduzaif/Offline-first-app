import 'package:stacked/stacked.dart';

class AppViewModel extends BaseViewModel {
  bool get isLoading => isBusy;
  String? get errorMessage => modelError?.toString();
  bool get hasErrorMessage => modelError != null;

  void setLoading(bool value) => setBusy(value);

  void setErrorMessage(String? message) {
    if (message == null || message.isEmpty) {
      clearErrors();
      return;
    }
    setError(message);
  }

  void clearErrorMessage() => clearErrors();
}
