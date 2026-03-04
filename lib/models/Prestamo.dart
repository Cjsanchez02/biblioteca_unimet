import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'MaterialBibliografico.dart';

class Prestamo {
  String id; 
  String correoSolicitante;
  DateTime fechaSolicitud;
  DateTime fechaDevolucion; 
  double multa;
  String materialId; 
  String tituloMaterial; 
  String estado; // "solicitado", "devuelto", "atrasado", "prestado"

  Prestamo({
    required this.id,
    required this.correoSolicitante,
    required this.fechaSolicitud,
    required this.fechaDevolucion,
    this.multa = 0.0,
    required this.materialId,
    required this.tituloMaterial,
    required this.estado,
    
  });

  
  double calcularMulta() {
    //terminar
    return multa; 
  }

  // App a Firebase
  Map<String, dynamic> toMap() {
    return {
      'correoSolicitante': correoSolicitante,
      'fechaSolicitud': fechaSolicitud, 
      'fechaDevolucion': fechaDevolucion,
      'multa': multa,
      'materialId': materialId,
      'tituloMaterial': tituloMaterial,
      'estado': estado,
    };
  }
}