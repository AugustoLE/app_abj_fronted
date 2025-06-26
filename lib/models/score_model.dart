class ScoreModel {
  String nombreJuego;
  int aciertos;
  int fallos;
  double? tiempo;
  String? nivel; // Nuevo campo para nivel
  DateTime? fecha;

  ScoreModel({
    required this.nombreJuego,
    required this.aciertos,
    required this.fallos,
    this.tiempo,
    this.nivel,
    this.fecha,
  });

  factory ScoreModel.fromJson(Map<String, dynamic> json) {
    return ScoreModel(
      nombreJuego: json['nombre_juego'],
      aciertos: json['aciertos'],
      fallos: json['fallos'],
      tiempo: (json['tiempo'] != null) ? json['tiempo'].toDouble() : null,
      nivel: json['nivel'],
      fecha: (json['fecha'] != null) ? DateTime.parse(json['fecha']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre_juego': nombreJuego,
      'aciertos': aciertos,
      'fallos': fallos,
      if (tiempo != null) 'tiempo': tiempo,
      if (nivel != null) 'nivel': nivel,
      if (fecha != null) 'fecha': fecha!.toIso8601String(),
    };
  }
}