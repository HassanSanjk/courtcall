import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_viewmodel.dart';
import 'repositories/player_repository.dart';
import 'repositories/venue_repository.dart';
import 'repositories/firebase/firebase_auth_repository.dart';
import 'repositories/firebase/firebase_player_repository.dart';
import 'repositories/firebase/firebase_venue_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            authRepository: FirebaseAuthRepository(),
          ),
        ),
        Provider<PlayerRepository>(
          create: (_) => FirebasePlayerRepository(),
        ),
        Provider<VenueRepository>(
          create: (_) => FirebaseVenueRepository(),
        ),
      ],
      child: MaterialApp.router(
        title: 'CourtCall',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: appRouter,
      ),
    );
  }
}