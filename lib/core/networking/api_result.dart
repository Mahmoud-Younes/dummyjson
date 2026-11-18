// The ONE result type every repository method returns.
//
// Instead of throwing errors around, we hand back an object that is
// either a success (with data) or a failure (with an ErrorModel).
// The UI checks which one it is:
//   if (result is ApiSuccess) { show data } else { show error }.
//
// "sealed" = the list of children is fixed and known to Dart,
// so the compiler can check our switch/if checks are complete.

import 'package:dummyjson/core/networking/api_error_model.dart';

sealed class ApiResult<T> {
  const ApiResult();
}

final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);

  final T data;
}

final class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.error);

  final ErrorModel error;
}
