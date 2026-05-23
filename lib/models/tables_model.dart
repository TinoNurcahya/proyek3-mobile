import 'package:flutter/material.dart';

enum TableStatus { empty, occupied, processing }

class TableZone {
  final String id;
  final String label;
  final Rect rect; // normalized 0.0–1.0
  TableStatus status;
  double occupancyScore;

  TableZone({
    required this.id,
    required this.label,
    required this.rect,
    this.status = TableStatus.processing,
    this.occupancyScore = 0.0,
  });
}
