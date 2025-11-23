// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'reminder_model.dart';

class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final int typeId = 2;

  @override
  Reminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reminder(
      id: fields[0] as String,
      title: fields[1] as String,
      notes: fields[2] as String?,
      dueDate: fields[3] as DateTime?,
      type: fields[6] as ReminderType,
      location: fields[7] as String?,
      category: fields[8] as ReminderCategory,
      isCompleted: fields[9] as bool,
      isFavorite: fields[10] as bool,
    )
      ..dueHour = fields[4] as int?
      ..dueMinute = fields[5] as int?;
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj.dueHour)
      ..writeByte(5)
      ..write(obj.dueMinute)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.location)
      ..writeByte(8)
      ..write(obj.category)
      ..writeByte(9)
      ..write(obj.isCompleted)
      ..writeByte(10)
      ..write(obj.isFavorite);
  }
}

class ReminderTypeAdapter extends TypeAdapter<ReminderType> {
  @override
  final int typeId = 0;

  @override
  ReminderType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReminderType.time;
      case 1:
        return ReminderType.location;
      default:
        return ReminderType.time;
    }
  }

  @override
  void write(BinaryWriter writer, ReminderType obj) {
    switch (obj) {
      case ReminderType.time:
        writer.writeByte(0);
        break;
      case ReminderType.location:
        writer.writeByte(1);
        break;
    }
  }
}

class ReminderCategoryAdapter extends TypeAdapter<ReminderCategory> {
  @override
  final int typeId = 1;

  @override
  ReminderCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReminderCategory.work;
      case 1:
        return ReminderCategory.personal;
      case 2:
        return ReminderCategory.shopping;
      case 3:
        return ReminderCategory.health;
      default:
        return ReminderCategory.work;
    }
  }

  @override
  void write(BinaryWriter writer, ReminderCategory obj) {
    switch (obj) {
      case ReminderCategory.work:
        writer.writeByte(0);
        break;
      case ReminderCategory.personal:
        writer.writeByte(1);
        break;
      case ReminderCategory.shopping:
        writer.writeByte(2);
        break;
      case ReminderCategory.health:
        writer.writeByte(3);
        break;
    }
  }
}
