// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthLoadingState extends AuthState {}

class AuthenticatedState extends AuthState {}

class UnAuthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final String error;
  const AuthErrorState({
    required this.error,
  });
}

class AuthenticatedUserDetailRequestSuccessState extends AuthState {
  final UserModel user;
  const AuthenticatedUserDetailRequestSuccessState({
    required this.user,
  });
}
