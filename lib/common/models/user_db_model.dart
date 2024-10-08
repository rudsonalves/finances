// Copyright (C) 2024 rudson
//
// This file is part of finances.
//
// finances is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// finances is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:convert';

import '../../locator.dart';
import '../../repositories/user/abstract_user_repository.dart';
import '../constants/app_constants.dart';
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
  StatisticMedium userBudgetRef;
  List<String> userCategoryList;
  int userMaxTransactions;
  List<int> userOfxStopCategories;

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
    this.userBudgetRef = StatisticMedium.mediumMonth,
    List<String>? userCategoryList,
    this.userMaxTransactions = 35,
    List<int>? userOfxStopCategories,
  })  : userCategoryList = userCategoryList ?? [],
        userOfxStopCategories = userOfxStopCategories ?? [1];

  final userRepository = locator<AbstractUserRepository>();

  void setFromUserModel(UserModel user) {
    userId = user.id;
    userName = user.name;
    userEmail = user.email;
    userLogged = false;
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
    userBudgetRef = StatisticMedium.values
        .where((item) => item.index == (userMap['userBudgetRef'] as int))
        .first;
    userCategoryList = List<String>.from(
      jsonDecode(
        userMap['userCategoryList'],
      ),
    );
    userMaxTransactions = userMap['userMaxTransactions'] != null
        ? userMap['userMaxTransactions'] as int
        : 35;
    userOfxStopCategories = List<int>.from(
      jsonDecode(
        userMap['userOfxStopCategories'] ?? "[1]",
      ),
    );
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
    userBudgetRef = user.userBudgetRef;
    userCategoryList = user.userCategoryList;
    userMaxTransactions = user.userMaxTransactions;
    userOfxStopCategories = user.userOfxStopCategories;
  }

  @override
  String toString() {
    return 'User(\n'
        'Id: $userId\n'
        ' Name: "$userName"\n'
        ' Email: $userEmail\n'
        ' Logged: $userLogged\n'
        ' MainAccountId: $userMainAccountId\n'
        ' Theme: $userTheme\n'
        ' Language: $userLanguage\n'
        ' GrpShowGrid: $userGrpShowGrid\n'
        ' GrpIsCurved: $userGrpIsCurved\n'
        ' GrpShowDots: $userGrpShowDots\n'
        ' GrpAreaChart: $userGrpAreaChart\n'
        ' BudgetRef: $userBudgetRef\n'
        ' CategoryList: $userCategoryList\n'
        ' MaxTransactions: $userMaxTransactions\n'
        ' OfxStopCategories: $userOfxStopCategories\n'
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
        'userGrpShowGrid': userGrpShowGrid ? 1 : 0,
        'userGrpIsCurved': userGrpIsCurved ? 1 : 0,
        'userGrpShowDots': userGrpShowDots ? 1 : 0,
        'userGrpAreaChart': userGrpAreaChart ? 1 : 0,
        'userBudgetRef': userBudgetRef.index,
        'userCategoryList': jsonEncode(userCategoryList),
        'userMaxTransactions': userMaxTransactions,
        'userOfxStopCategories': jsonEncode(userOfxStopCategories),
      };
    } else {
      return <String, dynamic>{
        'userName': userName,
        'userEmail': userEmail,
        'userLogged': userLogged ? 1 : 0,
        'userMainAccountId': userMainAccountId,
        'userTheme': userTheme,
        'userLanguage': userLanguage,
        'userGrpShowGrid': userGrpShowGrid ? 1 : 0,
        'userGrpIsCurved': userGrpIsCurved ? 1 : 0,
        'userGrpShowDots': userGrpShowDots ? 1 : 0,
        'userGrpAreaChart': userGrpAreaChart ? 1 : 0,
        'userBudgetRef': userBudgetRef.index,
        'userCategoryList': jsonEncode(userCategoryList),
        'userMaxTransactions': userMaxTransactions,
        'userOfxStopCategories': jsonEncode(userOfxStopCategories),
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
      userBudgetRef: StatisticMedium.values
          .where((item) => item.index == (map['userBudgetRef'] as int))
          .first,
      userCategoryList: List<String>.from(
        jsonDecode(
          map['userCategoryList'],
        ),
      ),
      userMaxTransactions: map['userMaxTransactions'] != null
          ? map['userMaxTransactions'] as int
          : 35,
      userOfxStopCategories: List<int>.from(
        jsonDecode(
          map['userOfxStopCategories'] ?? "[1]",
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserDbModel.fromJson(String source) =>
      UserDbModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Future<void> updateUser() async {
    await userRepository.updateUser(this);
  }

  Future<void> updateUserBudgetRef() async {
    await userRepository.updateUserBudgetRef(this);
  }

  Future<void> updateUserGrpShowGrid() async {
    await userRepository.updateUserGrpShowGrid(this);
  }

  Future<void> updateUserGrpIsCurved() async {
    await userRepository.updateUserGrpIsCurved(this);
  }

  Future<void> updateUserGrpShowDots() async {
    await userRepository.updateUserGrpShowDots(this);
  }

  Future<void> updateUserGrpAreaChart() async {
    await userRepository.updateUserGrpAreaChart(this);
  }

  Future<void> updateUserLanguage() async {
    await userRepository.updateUserLanguage(this);
  }

  Future<void> updateUserTheme() async {
    await userRepository.updateUserTheme(this);
  }

  Future<void> updateUserMaxTransactions() async {
    await userRepository.updateUserMaxTransactions(this);
  }
}
