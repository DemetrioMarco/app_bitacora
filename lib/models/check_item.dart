class CheckItem {
  int id;
  String title;
  bool checked;
  String? observacion;
  int orden;

  CheckItem({
    required this.id,
    required this.title,
    this.checked = false,
    this.observacion,
    required this.orden,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'checked': checked ? 1 : 0,
        'observacion': observacion,
        'orden': orden,
      };
}