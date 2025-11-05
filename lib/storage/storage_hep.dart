import 'package:get_storage/get_storage.dart';

class AfStorageHep{
  static final AfStorageHep _instance = AfStorageHep();
  static AfStorageHep get instance => _instance;

  final GetStorage _getStorage=GetStorage();

  final String _afResultKey="check_adjust_result_key";
  final String _localCheckUserKey="local_check_user_key";
  final String _localReferrerUserKey="local_referrer_user_key";

  saveAfResult(String result){
    _getStorage.write(_afResultKey, result);
  }

  String getAfResult()=>_getStorage.read(_afResultKey)??"";

  bool getLocalIsB()=>_getStorage.read(_localCheckUserKey)??false;

  saveUser(bool result){
    _getStorage.write(_localCheckUserKey, result);
  }

  getLocalReferrerStr()=>_getStorage.read(_localReferrerUserKey)??"";

  saveLocalReferrerStr(String result){
    _getStorage.write(_localReferrerUserKey, result);
  }
}