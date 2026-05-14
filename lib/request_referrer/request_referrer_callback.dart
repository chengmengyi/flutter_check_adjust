class RequestReferrerCallback{
  final void Function() startRequestReferrer;
  final void Function(String referrer) requestSuccess;

  const RequestReferrerCallback({
    required this.startRequestReferrer,
    required this.requestSuccess,
  });
}