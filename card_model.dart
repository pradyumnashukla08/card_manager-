import 'package:hive/hive.dart';

part 'card_model.g.dart';

@HiveType(typeId: 0)
class CardModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String type;

  @HiveField(2)
  String number;

  @HiveField(3)
  String dueDate;

  @HiveField(4)
  String expiryDate;

  @HiveField(5)
  String limit;

  CardModel({
    required this.name,
    required this.type,
    required this.number,
    required this.dueDate,
    required this.expiryDate,
    required this.limit,
  });
}
