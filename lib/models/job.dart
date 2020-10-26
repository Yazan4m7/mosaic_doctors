class Job{
  String id;
  String unitNum;
  String typeId;
  String color;
  String style;
  String materialId;

  @override
  String toString() {
    return 'CaseDetails{id: $id, unitNum: $unitNum, typeId: $typeId, color: $color, style: $style, materialId: $materialId}';
  }

  Job({this.id, this.unitNum, this.typeId, this.color, this.style,
      this.materialId});
  Job.optional(this.id, this.unitNum, this.typeId, this.color, this.style,
    this.materialId);

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
        id : json['id']==null? "N/A":json['id'],
        unitNum : json['unit_num']==null? "N/A":json['unit_num'],
        typeId : json['type']==null? "N/A":json['type'],
        color : json['color']==null? "N/A":json['color'],
      style : json['style']==null? "N/A":json['style'],
      materialId : json['material_id']==null? "N/A":json['material_id'],
    );
  }
}