import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'providers/facility_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const FOMApp());
}

class FOMApp extends StatelessWidget {
  const FOMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()..add(CheckAuthRequested())),
        ChangeNotifierProvider(create: (_) => FacilityProvider()),
      ],
      child: MaterialApp(
        title: 'FOM - Facilities Office Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const AdminHomeScreen();
            }
            if (state is AuthLoading) {
              return const Scaffold(
                backgroundColor: Color(0xFF0A1628),
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFF29B6F6)),
                ),
              );
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
