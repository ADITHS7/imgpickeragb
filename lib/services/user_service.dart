// services/user_service.dart
import 'package:imgpickapp/model/user_model.dart';

class UserService {
  List<User> _users = [
    User(id: 1, name: "John Doe"),
    User(id: 2, name: "Jane Smith"),
    User(id: 3, name: "Mike Johnson"),
    User(id: 4, name: "Sarah Wilson"),
    User(id: 5, name: "David Brown"),
    User(id: 6, name: "Emily Davis"),
    User(id: 7, name: "Chris Miller"),
    User(id: 8, name: "Lisa Anderson"),
  ];

  List<User> getAllUsers() {
    return List.from(_users);
  }

  User? getUserById(int id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  List<User> searchUsers(String query) {
    if (query.isEmpty) return getAllUsers();

    return _users
        .where((user) => user.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  bool updateUser(User updatedUser) {
    final index = _users.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      return true;
    }
    return false;
  }

  bool deleteUser(int userId) {
    final index = _users.indexWhere((user) => user.id == userId);
    if (index != -1) {
      _users.removeAt(index);
      return true;
    }
    return false;
  }

  User? addUser(User newUser) {
    final maxId =
        _users.isEmpty
            ? 0
            : _users.map((u) => u.id).reduce((a, b) => a > b ? a : b);
    final userWithId = User(
      id: maxId + 1,
      name: newUser.name,
      imagePath: newUser.imagePath,
    );
    _users.add(userWithId);
    return userWithId;
  }

  int get userCount => _users.length;
}
