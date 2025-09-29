import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';
@JsonSerializable()
class Model {
  final String nombre;
  final String url;
  final List<String> programas; // <- ahora sí existe

  Model({required this.nombre, required this.url, required this.programas});

  factory Model.fromJson(Map<String, dynamic> json) => _$ModelFromJson(json);
  Map<String, dynamic> toJson() => _$ModelToJson(this);
}
