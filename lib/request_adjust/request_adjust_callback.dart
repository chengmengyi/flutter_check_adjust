class RequestAdjustCallback{
  final void Function() startRequestAdjust;
  final void Function(bool isB) requestSuccess;
  final void Function() firstRequestAdjustB;

  const RequestAdjustCallback({
    required this.startRequestAdjust,
    required this.requestSuccess,
    required this.firstRequestAdjustB,
  });
}