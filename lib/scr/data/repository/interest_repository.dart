// import 'package:flutter_application_1/scr/data/model/interest.dart';

// abstract class InterestRepository {
//   Future<List<Interest>> getInterests();
//   Future<void> saveSelectedInterests(List<Interest> interests);
// }

// class InterestRepositoryImpl implements InterestRepository {
//   @override
//   Future<List<Interest>> getInterests() async {
//     // Simulate API call or database fetch
//     await Future.delayed(const Duration(seconds: 1));

//     return [
//       Interest(id: '1', name: 'User Interface', isSelected: true),
//       Interest(id: '2', name: 'User Experience', isSelected: false),
//       Interest(id: '3', name: 'User Research', isSelected: true),
//       Interest(id: '4', name: 'UX Writing', isSelected: false),
//       Interest(id: '5', name: 'User Testing', isSelected: false),
//       Interest(id: '6', name: 'Service Design', isSelected: false),
//       Interest(id: '7', name: 'Strategy', isSelected: true),
//       Interest(id: '8', name: 'Design Systems', isSelected: true),
//     ];
//   }

//   @override
//   Future<void> saveSelectedInterests(List<Interest> interests) async {
//     // Simulate API call or database save
//     final selectedInterests = interests.where((i) => i.isSelected).toList();

//     await Future.delayed(const Duration(seconds: 2));

//     print('Saved interests: ${selectedInterests.map((i) => i.name).toList()}');
//   }
// }
