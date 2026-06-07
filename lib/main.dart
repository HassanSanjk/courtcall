import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_viewmodel.dart';
import 'features/auth/login/login_screen.dart';
import 'repositories/player_repository.dart';
import 'repositories/venue_repository.dart';
import 'repositories/session_repository.dart';
import 'repositories/payment_repository.dart';
import 'repositories/rsvp_repository.dart';
import 'repositories/firebase/firebase_auth_repository.dart';
import 'repositories/firebase/firebase_player_repository.dart';
import 'repositories/firebase/firebase_venue_repository.dart';
import 'repositories/firebase/firebase_session_repository.dart';
import 'repositories/firebase/firebase_payment_repository.dart';
import 'repositories/firebase/firebase_rsvp_repository.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authViewModel = AuthViewModel(
    authRepository: FirebaseAuthRepository(),
  );
  authViewModel.initialize();

  runApp(MyApp(authViewModel: authViewModel));
}

class MyApp extends StatelessWidget {
  final AuthViewModel authViewModel;
  const MyApp({super.key, required this.authViewModel});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authViewModel),
        Provider<PlayerRepository>(
          create: (_) => FirebasePlayerRepository(),
        ),
        Provider<VenueRepository>(
          create: (_) => FirebaseVenueRepository(),
        ),
        Provider<SessionRepository>(
          create: (_) => FirebaseSessionRepository(),
        ),
        Provider<PaymentRepository>(
          create: (_) => FirebasePaymentRepository(),
        ),
        Provider<RsvpRepository>(
          create: (_) => FirebaseRsvpRepository(),
        ),
      ],
      child: MaterialApp(
        title: 'CourtCall',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        navigatorKey: rootNavigatorKey,
        home: const LoginScreen(),
      ),
    );
  }
}