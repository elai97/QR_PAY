// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/auth/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  AuthBloc({required this.authRepository}) : super(UnAuthenticatedState()) {
    on<SignInRequested>((event, emit) async {
      emit(AuthLoadingState());
      try {
        await authRepository.signIn(
            email: event.email, password: event.password);
        emit(AuthenticatedState());
      } catch (e) {
        emit(AuthErrorState(error: e.toString()));
        emit(UnAuthenticatedState());
      }
    });
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoadingState());
      try {
        await authRepository.signUp(
            email: event.email, password: event.password);
        emit(AuthenticatedState());
      } catch (e) {
        emit(AuthErrorState(error: e.toString()));
        emit(UnAuthenticatedState());
      }
    });
    on<GoogleSignInRequested>((event, emit) async {
      emit(AuthLoadingState());
      try {
        await authRepository.signInWithGoogle();
        emit(AuthenticatedState());
      } catch (e) {
        emit(AuthErrorState(error: e.toString()));
        emit(UnAuthenticatedState());
      }
    });
    on<SignOutRequested>((event, emit) async {
      emit(AuthLoadingState());
      await authRepository.signOut();
      emit(UnAuthenticatedState());
    });
  }
}
