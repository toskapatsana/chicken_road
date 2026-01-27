/// Presentation Layer - User Data Provider
/// 
/// Manages user-specific recipe data (ratings, notes, cooking history).

import 'package:flutter/foundation.dart';
import '../../domain/entities/user_recipe_data.dart';
import '../../data/datasources/user_data_datasource.dart';

class UserDataProvider extends ChangeNotifier {
  final UserDataDataSource _dataSource;
  
  Map<String, UserRecipeData> _userData = {};
  Map<String, UserRecipeData> get userData => _userData;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  UserDataProvider({UserDataDataSource? dataSource})
      : _dataSource = dataSource ?? UserDataDataSource();
  
  Future<void> loadAllUserData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _userData = await _dataSource.getAllUserData();
    } catch (_) {
      _userData = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  UserRecipeData? getUserDataForRecipe(String recipeId) {
    return _userData[recipeId];
  }
  
  Future<UserRecipeData> _getOrCreateUserData(String recipeId) async {
    if (_userData.containsKey(recipeId)) {
      return _userData[recipeId]!;
    }
    
    final existingData = await _dataSource.getUserData(recipeId);
    if (existingData != null) {
      _userData[recipeId] = existingData;
      return existingData;
    }
    
    return UserRecipeData(recipeId: recipeId);
  }
  
  Future<void> setRating(String recipeId, int rating) async {
    final data = await _getOrCreateUserData(recipeId);
    final updatedData = data.copyWith(rating: rating);
    
    _userData[recipeId] = updatedData;
    notifyListeners();
    
    await _dataSource.saveUserData(updatedData);
  }
  
  Future<void> setNotes(String recipeId, String notes) async {
    final data = await _getOrCreateUserData(recipeId);
    final updatedData = data.copyWith(notes: notes.isEmpty ? null : notes);
    
    _userData[recipeId] = updatedData;
    notifyListeners();
    
    await _dataSource.saveUserData(updatedData);
  }
  
  Future<void> setSelectedServings(String recipeId, int servings) async {
    final data = await _getOrCreateUserData(recipeId);
    final updatedData = data.copyWith(selectedServings: servings);
    
    _userData[recipeId] = updatedData;
    notifyListeners();
    
    await _dataSource.saveUserData(updatedData);
  }
  
  Future<void> markAsCooked(String recipeId) async {
    final data = await _getOrCreateUserData(recipeId);
    final updatedData = data.addCookingEntry();
    
    _userData[recipeId] = updatedData;
    notifyListeners();
    
    await _dataSource.saveUserData(updatedData);
  }
  
  Future<void> clearAllUserData() async {
    await _dataSource.clearAllUserData();
    _userData = {};
    notifyListeners();
  }
}
