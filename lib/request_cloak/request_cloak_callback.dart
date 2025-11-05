class RequestCloakCallback{
  final void Function() startRequestCloak;
  final void Function(bool isWhite) requestSuccess;

  const RequestCloakCallback({
    required this.startRequestCloak,
    required this.requestSuccess,
  });
}