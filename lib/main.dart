import 'package:flutter/material.dart';

// Core
import 'app/core/app/tag_pilot_app.dart';
import 'app/core/services/app_initialization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await AppInitializationService.initializeServices();

  runApp(const TagPilotApp());
}
