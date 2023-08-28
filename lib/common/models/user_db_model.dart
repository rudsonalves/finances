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

  UserDbModel({
    this.userId,
    this.userName,
    this.userEmail,
    this.userLogged = false,
    this.userMainAccountId,
    this.userTheme = 'system',
    this.userLanguage = 'en_US',
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
  }

  void copyFromUser(UserDbModel user) {
    userId = user.userId;
    userName = user.userName;
    userEmail = user.userEmail;
    userLogged = user.userLogged;
    userMainAccountId = user.userMainAccountId;
    userTheme = user.userTheme;
    userLanguage = user.userLanguage;
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
        ' Language: $userLanguage'
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
      };
    } else {
      return <String, dynamic>{
        'userName': userName,
        'userEmail': userEmail,
        'userLogged': userLogged ? 1 : 0,
        'userMainAccountId': userMainAccountId,
        'userTheme': userTheme,
        'userLanguage': userLanguage,
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
    );
  }

  String toJson() => json.encode(toMap());

  factory UserDbModel.fromJson(String source) =>
      UserDbModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Future<void> updateUser() async {
    await locator.get<UserRepository>().updateUser(this);
  }
}
