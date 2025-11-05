import 'package:dio/dio.dart';
import 'package:flutter_check_adjust/dio/dio_result.dart';

class DioHep{
  static final DioHep _baseDio=DioHep();
  static DioHep get instance=>_baseDio;

  Dio? _dio;
  DioHep(){
    _dio??=Dio(BaseOptions(
      responseType: ResponseType.json,
      receiveDataWhenStatusError: false,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  Future<DioResult> requestPost({
    required String path,
    required dynamic data,
    Map<String,dynamic>? header,
    String? contentType,
  })async{
    if(null!=header){
      _dio?.options.headers=header;
    }
    if(null!=contentType){
      _dio?.options.contentType=contentType;
    }
    try{
      var response = await _dio?.request<String>(
          path,
          data: data,
          options: Options(method: "post")
      );
      return DioResult(success: response?.statusCode==200, msg: response?.data??"");
    }catch(e){
      return DioResult(success: false, msg: "");
    }
  }
}