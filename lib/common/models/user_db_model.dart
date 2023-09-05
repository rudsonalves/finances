import 'dart:convert';

import '../../locator.dart';
import '../../repositories/user/user_repository.dart';
import './user_model.dart';

/*
Model for app current user
*/
class UserDbModel {
  String? userId;
  String? userName;
  String? userEmail;
  bool userLogged;
  int? userMainAccountId;
  String userTheme;
  String userLanguage;
  bool userGrpShowGrid;
  bool userGrpIsCurved;
  bool userGrpShowDots;
  bool userGrpAreaChart;

  UserDbModel({
    this.userId,
    this.userName,
    this.userEmail,
    this.userLogged = false,
    this.userMainAccountId,
    this.userTheme = 'system',
    this.userLanguage = 'en_US',
    this.userGrpShowGrid = true,
    this.userGrpIsCurved = false,
    this.userGrpShowDots = false,
    this.userGrpAreaChart = false,
  });

  void setFromUserModel(UserModel user) {
    userId = user.id;
    userName = user.name;
    userEmail = user.email;
    userLogged = false;
    // userMainAccountId;
    userTheme = 'system';
    userLanguage = 'en_US';
  }

  void setFromUserMap(Map<String, dynamic> userMap) {
    userId = userMap['userId'] as String;
    userName = userMap['userName'] as String;
    userEmail = userMap['userEmail'] as String;
    userLogged = userMap['userLogged'] as int == 0 ? false : true;
    userMainAccountId = userMap['userMainAccountId'] as int;
    userTheme = userMap['userTheme'] as String;
    userLanguage = userMap['userLanguage'] as String;
    userGrpShowGrid = userMap['userGrpShowGrid'] as int == 0 ? false : true;
    userGrpIsCurved = userMap['userGrpIsCurved'] as int == 0 ? false : true;
    userGrpShowDots = userMap['userGrpShowDots'] as int == 0 ? false : true;
    userGrpAreaChart = userMap['userGrpAreaChart'] as int == 0 ? false : true;
  }

  void copyFromUser(UserDbModel user) {
    userId = user.userId;
    userName = user.userName;
    userEmail = user.userEmail;
    userLogged = user.userLogged;
    userMainAccountId = user.userMainAccountId;
    userTheme = user.userTheme;
    userLanguage = user.userLanguage;
    userGrpShowGrid = user.userGrpShowGrid;
    userGrpIsCurved = user.userGrpIsCurved;
    userGrpShowDots = user.userGrpShowDots;
    userGrpAreaChart = user.userGrpAreaChart;
  }

  @override
  String toString() {
    return 'User('
        'Id: $userId;'
        ' Name: "$userName";'
        ' Email: $userEmail;'
        ' Logged: $userLogged;'
        ' MainAccountId: $userMainAccountId;'
        ' Theme: $userTheme;'
        ' Language: $userLanguage;'
        ' GrpShowGrid: $userGrpShowGrid;'
        ' GrpIsCurved: $userGrpIsCurved;'
        ' GrpShowDots: $userGrpShowDots;'
        ' GrpAreaChart: $userGrpAreaChart'
        ')';
  }

  Map<String, dynamic> toMap() {
    if (userId != null) {
      return <String, dynamic>{
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'userLogged': userLogged ? 1 : 0,
        'userMainAccountId': userMainAccountId,
        'userTheme': userTheme,
        'userLanguage': userLanguage,
        'userGrpShowGrid': userGrpShowGrid,
        'userGrpIsCurved': userGrpIsCurved,
        'userGrpShowDots': userGrpShowDots,
        'userGrpAreaChart': userGrpAreaChart,
      };
    } else {
      return <String, dynamic>{
        'userName': userName,
        'userEmail': userEmail,
        'userLogged': userLogged ? 1 : 0,
        'userMainAccountId': userMainAccountId,
        'userTheme': userTheme,
        'userLanguage': userLanguage,
        'userGrpShowGrid': userGrpShowGrid,
        'userGrpIsCurved': userGrpIsCurved,
        'userGrpShowDots': userGrpShowDots,
        'userGrpAreaChart': userGrpAreaChart,
      };
    }
  }

  factory UserDbModel.fromMap(Map<String, dynamic> map) {
    return UserDbModel(
      userId: map['userId'] != null ? map['userId'] as String : null,
      userName: map['userName'] != null ? map['userName'] as String : null,
      userEmail: map['userEmail'] != null ? map['userEmail'] as String : null,
      userLogged: map['userLogged'] as int == 0 ? false : true,
      userMainAccountId: map['userMainAccountId'] != null
          ? map['userMainAccountId'] as int
          : null,
      userTheme: map['userTheme'] as String,
      userLanguage: map['userLanguage'] as String,
      userGrpShowGrid: map['userGrpShowGrid'] as int == 0 ? false : true,
      userGrpIsCurved: map['userGrpIsCurved'] as int == 0 ? false : true,
      userGrpShowDots: map['userGrpShowDots'] as int == 0 ? false : true,
      userGrpAreaChart: map['userGrpAreaChart'] as int == 0 ? false : true,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserDbModel.fromJson(String source) =>
      UserDbModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Future<void> updateUser() async {
    await locator.get<UserRepository>().updateUser(this);
  }
}
