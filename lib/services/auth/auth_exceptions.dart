//login exception
class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

// registerview exception
class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

//generic Exception
class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
