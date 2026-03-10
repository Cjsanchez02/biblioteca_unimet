import 'package:cloud_firestore/cloud_firestore.dart';

class Donacion {
  final String? id;
  final double monto;
  final String moneda;
  final DateTime fecha;
  final String? usuarioId;
  final String? usuarioEmail;
  final String? nombreUsuario;

  Donacion({
    this.id,
    required this.monto,
    required this.moneda,
    required this.fecha,
    this.usuarioId,
    this.usuarioEmail,
    this.nombreUsuario,
  });

  Map<String, dynamic> toMap() {
    return {
      'monto': monto,
      'moneda': moneda,
      'fecha': Timestamp.fromDate(fecha),
      'usuarioId': usuarioId,
      'usuarioEmail': usuarioEmail,
      'nombreUsuario': nombreUsuario,
    };
  }

  factory Donacion.fromMap(Map<String, dynamic> map, String id) {
    return Donacion(
      id: id,
      monto: (map['monto'] as num).toDouble(),
      moneda: map['moneda'] ?? '',
      fecha: (map['fecha'] as Timestamp).toDate(),
      usuarioId: map['usuarioId'],
      usuarioEmail: map['usuarioEmail'],
      nombreUsuario: map['nombreUsuario'],
    );
  }
}
