// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patient_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PatientTask {

 String get id;/// Server-assigned, monotonically increasing.
 int get version; String get title; TaskStatus get status; TaskPriority get priority;/// e.g. "Patient/123"
 String get patientReference;/// Server time of the last accepted write.
 DateTime get lastModified; DateTime? get dueDate;/// e.g. "Practitioner/45"
 String? get assignee;
/// Create a copy of PatientTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatientTaskCopyWith<PatientTask> get copyWith => _$PatientTaskCopyWithImpl<PatientTask>(this as PatientTask, _$identity);

  /// Serializes this PatientTask to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PatientTask&&(identical(other.id, id) || other.id == id)&&(identical(other.version, version) || other.version == version)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.patientReference, patientReference) || other.patientReference == patientReference)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.assignee, assignee) || other.assignee == assignee));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,version,title,status,priority,patientReference,lastModified,dueDate,assignee);

@override
String toString() {
  return 'PatientTask(id: $id, version: $version, title: $title, status: $status, priority: $priority, patientReference: $patientReference, lastModified: $lastModified, dueDate: $dueDate, assignee: $assignee)';
}


}

/// @nodoc
abstract mixin class $PatientTaskCopyWith<$Res>  {
  factory $PatientTaskCopyWith(PatientTask value, $Res Function(PatientTask) _then) = _$PatientTaskCopyWithImpl;
@useResult
$Res call({
 String id, int version, String title, TaskStatus status, TaskPriority priority, String patientReference, DateTime lastModified, DateTime? dueDate, String? assignee
});




}
/// @nodoc
class _$PatientTaskCopyWithImpl<$Res>
    implements $PatientTaskCopyWith<$Res> {
  _$PatientTaskCopyWithImpl(this._self, this._then);

  final PatientTask _self;
  final $Res Function(PatientTask) _then;

/// Create a copy of PatientTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? version = null,Object? title = null,Object? status = null,Object? priority = null,Object? patientReference = null,Object? lastModified = null,Object? dueDate = freezed,Object? assignee = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,patientReference: null == patientReference ? _self.patientReference : patientReference // ignore: cast_nullable_to_non_nullable
as String,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,assignee: freezed == assignee ? _self.assignee : assignee // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PatientTask].
extension PatientTaskPatterns on PatientTask {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PatientTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PatientTask() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PatientTask value)  $default,){
final _that = this;
switch (_that) {
case _PatientTask():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PatientTask value)?  $default,){
final _that = this;
switch (_that) {
case _PatientTask() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int version,  String title,  TaskStatus status,  TaskPriority priority,  String patientReference,  DateTime lastModified,  DateTime? dueDate,  String? assignee)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PatientTask() when $default != null:
return $default(_that.id,_that.version,_that.title,_that.status,_that.priority,_that.patientReference,_that.lastModified,_that.dueDate,_that.assignee);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int version,  String title,  TaskStatus status,  TaskPriority priority,  String patientReference,  DateTime lastModified,  DateTime? dueDate,  String? assignee)  $default,) {final _that = this;
switch (_that) {
case _PatientTask():
return $default(_that.id,_that.version,_that.title,_that.status,_that.priority,_that.patientReference,_that.lastModified,_that.dueDate,_that.assignee);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int version,  String title,  TaskStatus status,  TaskPriority priority,  String patientReference,  DateTime lastModified,  DateTime? dueDate,  String? assignee)?  $default,) {final _that = this;
switch (_that) {
case _PatientTask() when $default != null:
return $default(_that.id,_that.version,_that.title,_that.status,_that.priority,_that.patientReference,_that.lastModified,_that.dueDate,_that.assignee);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PatientTask implements PatientTask {
  const _PatientTask({required this.id, required this.version, required this.title, required this.status, required this.priority, required this.patientReference, required this.lastModified, this.dueDate, this.assignee});
  factory _PatientTask.fromJson(Map<String, dynamic> json) => _$PatientTaskFromJson(json);

@override final  String id;
/// Server-assigned, monotonically increasing.
@override final  int version;
@override final  String title;
@override final  TaskStatus status;
@override final  TaskPriority priority;
/// e.g. "Patient/123"
@override final  String patientReference;
/// Server time of the last accepted write.
@override final  DateTime lastModified;
@override final  DateTime? dueDate;
/// e.g. "Practitioner/45"
@override final  String? assignee;

/// Create a copy of PatientTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PatientTaskCopyWith<_PatientTask> get copyWith => __$PatientTaskCopyWithImpl<_PatientTask>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PatientTaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PatientTask&&(identical(other.id, id) || other.id == id)&&(identical(other.version, version) || other.version == version)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.patientReference, patientReference) || other.patientReference == patientReference)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.assignee, assignee) || other.assignee == assignee));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,version,title,status,priority,patientReference,lastModified,dueDate,assignee);

@override
String toString() {
  return 'PatientTask(id: $id, version: $version, title: $title, status: $status, priority: $priority, patientReference: $patientReference, lastModified: $lastModified, dueDate: $dueDate, assignee: $assignee)';
}


}

/// @nodoc
abstract mixin class _$PatientTaskCopyWith<$Res> implements $PatientTaskCopyWith<$Res> {
  factory _$PatientTaskCopyWith(_PatientTask value, $Res Function(_PatientTask) _then) = __$PatientTaskCopyWithImpl;
@override @useResult
$Res call({
 String id, int version, String title, TaskStatus status, TaskPriority priority, String patientReference, DateTime lastModified, DateTime? dueDate, String? assignee
});




}
/// @nodoc
class __$PatientTaskCopyWithImpl<$Res>
    implements _$PatientTaskCopyWith<$Res> {
  __$PatientTaskCopyWithImpl(this._self, this._then);

  final _PatientTask _self;
  final $Res Function(_PatientTask) _then;

/// Create a copy of PatientTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? version = null,Object? title = null,Object? status = null,Object? priority = null,Object? patientReference = null,Object? lastModified = null,Object? dueDate = freezed,Object? assignee = freezed,}) {
  return _then(_PatientTask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,patientReference: null == patientReference ? _self.patientReference : patientReference // ignore: cast_nullable_to_non_nullable
as String,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,assignee: freezed == assignee ? _self.assignee : assignee // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
