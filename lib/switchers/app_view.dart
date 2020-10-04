import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cokut/bloc_listener/my_bloc_listener.dart';
import 'package:cokut/cubit/authentication/authentication_cubit.dart';
import 'package:cokut/cubit/firebase_app/firebase_app_cubit.dart';
import 'package:cokut/cubit/login_form/login_cubit.dart';
import 'package:cokut/cubit/cart/cart_cubit.dart';
import 'package:cokut/cubit/restaurant_cubit/restaurant_cubit.dart';
import 'package:cokut/cubit/user_data/user_data_cubit.dart';
import 'package:cokut/presentation/screens/auth_screen.dart';
import 'package:cokut/presentation/screens/home_screen.dart';
import 'package:cokut/presentation/screens/loading_screen.dart';
import 'package:cokut/presentation/screens/otp_screen.dart';
import 'package:cokut/presentation/screens/address_screen.dart';
import 'package:cokut/presentation/screens/meal_cat_screen.dart';
import 'package:cokut/presentation/screens/restaurants_list_screen.dart';
import 'package:cokut/presentation/screens/store_screen.dart';
import 'package:cokut/infrastructure/repositories/cart_repo.dart';
import 'package:cokut/infrastructure/repositories/restaurant_repo.dart';
import 'package:cokut/infrastructure/repositories/user_repo.dart';
import 'package:cokut/infrastructure/repositories/auth_repo.dart';
import 'package:cokut/models/meal.dart';

class AppView extends StatefulWidget {
  @override
  _AppViewState createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState;

  var blocs = [
    BlocProvider<AuthenticationCubit>(
      create: (ctx) => AuthenticationCubit(
        ctx.repository<AuthenticationRepository>(),
      ),
    ),
    BlocProvider<LoginCubit>(
      create: (ctx) => LoginCubit(
        ctx.repository<AuthenticationRepository>(),
      ),
    ),
    BlocProvider<CartCubit>(
      create: (ctx) => CartCubit(
        ctx.repository<CartRepository>(),
      ),
    ),
    BlocProvider<RestaurantCubit>(
      create: (ctx) => RestaurantCubit(
        ctx.repository<RestaurantRepository>(),
        ctx.repository<AuthenticationRepository>(),
      ),
    ),
    BlocProvider<UserDataCubit>(
      create: (ctx) => UserDataCubit(
        ctx.repository<UserRepository>(),
        ctx.repository<AuthenticationRepository>(),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: blocs,
      child: MaterialApp(
        title: 'Cokut',
        navigatorKey: _navigatorKey,
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.montserratTextTheme(
            Theme.of(context).textTheme.copyWith(
                  bodyText1: Theme.of(context).textTheme.bodyText1.copyWith(
                        color: Colors.grey[600],
                      ),
                  headline6: Theme.of(context).textTheme.headline6.copyWith(
                        color: Colors.blueGrey[600],
                        fontSize: 18,
                        letterSpacing: -.4,
                        fontWeight: FontWeight.w400,
                      ),
                ),
          ),
        ),
        routes: {
          '/home': (ctx) => HomeScreen(),
          '/auth': (ctx) => AuthScreen(),
          '/otp': (ctx) => Otp(),
          '/loading': (ctx) => LoadingScreen(),
          '/restaurants': (ctx) => RestaurantListScreen(),
          '/homemade': (ctx) => RestaurantListScreen(isHomeMade: true),
          '/store': (ctx) => RestaurantScreen(),
          '/specials': (ctx) => MealCategoryScreen(
                mealType: MealType.special,
                title: "Specials",
              ),
          '/spicey': (ctx) => MealCategoryScreen(
                mealType: MealType.spicey,
                title: "Spicey",
              ),
          '/address': (ctx) => AddressScreen(),
        },
        home: BlocBuilder<FirebaseAppCubit, FirebaseAppState>(
          builder: (context, state) {
            print(state);
            if (state is FirebaseAppLoaded) {
              return AuthBlocDecider(_navigator);
            } else {
              return LoadingScreen();
            }
          },
        ),
      ),
    );
  }
}