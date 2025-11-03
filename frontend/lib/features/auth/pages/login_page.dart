import 'package:flutter/material.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/auth/pages/signup_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/home/pages/home_page.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // TODO: implement dispose
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void logInUser() {
    if (formKey.currentState!.validate()) {
      context.read<AuthCubit>().logIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //SingleChildScrollView to have an scrol in the screen
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          // TODO: implement listener
          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          } else if (state is AuthLoggedIn) {
            Navigator.pushAndRemoveUntil(
              context,
              HomePage.route(),
              (_) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //We will copy the previous textfield we designed to avoid time consuming
                        // Image.asset("assets/images/login2.png", width: 200),
                        // const SizedBox(height: 20),
                        Text(
                          "Welcome back",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(hintText: "Enter Email"),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.trim().contains('@')) {
                              return "Email field is invalid";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        //Password field
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            hintText: 'Enter Password',
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                value.trim().length <= 6) {
                              return "Password field is invalid";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        //Login button
                        ElevatedButton(
                          onPressed: logInUser,
                          child: Text(
                            'SIGN UP',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),

                        const SizedBox(height: 12),

                        //Sign up button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(fontSize: 16),
                            ),
                            TextButton(
                              onPressed: () {
                                //Navigate to sign up
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LogInPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
