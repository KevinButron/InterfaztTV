// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Model _$ModelFromJson(Map<String, dynamic> json) => Model(
  nombre: json['nombre'] as String,
  url: json['url'] as String,
  programas: (json['programas'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ModelToJson(Model instance) => <String, dynamic>{
  'nombre': instance.nombre,
  'url': instance.url,
  'programas': instance.programas,
};
