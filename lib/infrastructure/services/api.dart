import 'dart:io';

import 'package:cokut/common/exceptions.dart';
import 'package:cokut/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class Api {
  static String v1;
  static String utils;
  // static final String v1 = "http://cokut.herokuapp.com/api/v1";
  // static final String utils = "http://cokut.herokuapp.com/utils";

  Api({bool test}) {
    if (test ?? false) {
      v1 = "http://192.168.43.65:4000/api/v1";
      utils = "http://192.168.43.65:4000/utils";
    } else {
      v1 = "http://cokut.herokuapp.com/api/v1";
      utils = "http://cokut.herokuapp.com/utils";
    }
  }

// Main Dio
  Dio mainDio = Dio(
    BaseOptions(
      baseUrl: v1,
      headers: {"Content-Type": "application/json"},
    ),
  );

// Util Dio
  Dio utilDio() {
    return Dio(
      BaseOptions(
        baseUrl: utils,
        headers: {
          "Content-Type": "application/json",
        },
      ),
    );
  }

// Super Dio
  Dio superDio(String token) {
    return Dio(
      BaseOptions(
        baseUrl: v1,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer " + token,
        },
      ),
    );
  }

// Form data post wrapper
  Future<Response> postData(
    Map<String, dynamic> map,
    String endpoint, {
    bool util = false,
    String token = "",
  }) async {
    Dio dio = util ? await utilDio() : await superDio(token);
    try {
      Response response = await dio.post(
        endpoint,
        data: map,
      );
      return response;
    } on DioError catch (e) {
      if (e.error is SocketException) {
        throw SocketException("Please check your network connectivity");
      } else if (!e.response.data["success"]) {
        logger.e(e.response.data);
        throw CustomException(e.response.data["msg"]);
      }
      return e.response;
    }
  }

  // Form data post wrapper
  Future<Response> getData(Map<String, dynamic> map, String endpoint,
      {bool util = false, String token = "", String method = "GET"}) async {
    Response response;
    Dio dio = util ? await utilDio() : superDio(token);

    try {
      response = await dio.request(
        endpoint,
        queryParameters: map,
        options: Options(
          method: method,
          contentType: "application/json",
          responseType: ResponseType.json,
        ),
      );
    } on DioError catch (e) {
      logger.e(e.response);
      if (e.error is SocketException) {
        throw SocketException("Please check your network connectivity");
      } else if (!e.response.data["success"]) {
        var msg;
        if (e.response.data["code"] == 0)
          msg = "No records";
        else
          msg = "An error occured";
        throw CustomException(msg);
      }
    }
    return response;
  }

  // Register User
  Future<dynamic> registerUser({
    @required String token,
    @required String name,
    String email,
    String phone,
    String gid,
  }) async {
    Map<String, dynamic> map = {
      "name": name,
      "email": email,
      "phone": phone,
    };

    Response resp = await postData(map, "/user/register", token: token);

    if (resp.data["success"]) {
      return resp.data;
    } else if (resp.data["msg"].toString().trim() == "DETAILS_EXIST") {
      throw DetailsExistException();
    } else {
      logger.wtf("IVIDEYO?");
      throw CustomException(resp.data["msg"]);
    }
  }

  // Register User
  Future<dynamic> addAddress({
    @required String token,
    @required Map<String, dynamic> address,
  }) async {
    Response resp = await postData(address, "/user/address", token: token);
    return resp.data["user"];
  }

  // Register User
  Future<dynamic> removeAddress({
    @required String token,
    @required Map<String, dynamic> address,
  }) async {
    Response resp = await getData({"title": address["title"]}, "/user/address",
        method: "DELETE", token: token);
    return resp.data["user"];
  }

  // Get User
  Future<Map<String, dynamic>> getUser(String token, {int i = 0}) async {
    Map<String, dynamic> userData = {};
    var dio = superDio(token);
    try {
      Response resp = await dio.get('/user');
      logger.i(resp.data);
      if (resp.data["exist"] && resp.data["user"] != null) {
        userData = resp.data["user"];
        userData["registered"] = true;
      } else if (!resp.data["exist"]) {
        userData["registered"] = false;
      }
      return userData;
    } on DioError catch (e) {
      logger.e(e);
      print(e.response.data);
      if (e.error is SocketException) {
        throw SocketException("Connection Error");
      } else {
        throw CustomException(e.response.data["msg"]);
      }
    }
  }

  // Get Restaurant
  // Get User
  Future<List<Map<String, dynamic>>> getRestaurants(
    String token, {
    bool isHomeMade = false,
  }) async {
    Response resp;

    resp = await getData(
      null,
      isHomeMade ? '/restaurants/home' : '/restaurants/regular',
      token: token,
    );

    return List<Map<String, dynamic>>.from(resp.data);
  }

  // Get Restaurant
  // Get User
  Future<List<Map<String, dynamic>>> getOrders(String token) async {
    Response resp;

    resp = await getData(
      null,
      '/user/orders',
      token: token,
    );

    return List<Map<String, dynamic>>.from(resp.data);
  }

  // Get Restaurant
  // Get User
  Future<List<Map<String, dynamic>>> getAllRestaurants(String token) async {
    Response resp;

    resp = await getData(
      null,
      '/restaurants',
      token: token,
    );

    return List<Map<String, dynamic>>.from(resp.data);
  }

  // Get Meals
  Future<List<Map<String, dynamic>>> getMeals(String token,
      {String rid, String endpoint = "/meals"}) async {
    Response resp;
    Map<String, dynamic> map = {"rid": rid};

    resp = await getData(
      map,
      endpoint,
      token: token,
    );

    return List<Map<String, dynamic>>.from(resp.data);
  }

  Future<Map<String, dynamic>> order(
      Map<String, dynamic> orderData, String token) async {
    var resp = await postData(orderData, '/order', token: token);
    return Map<String, dynamic>.from(resp.data);
  }
}
