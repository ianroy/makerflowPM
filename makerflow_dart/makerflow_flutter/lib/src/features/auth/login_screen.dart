import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:makerflow_design/makerflow_design.dart';

import '../../state/providers.dart';

/// Skeleton login. Real email/password auth via serverpod_auth lands in
/// fl-0-auth-rbac-tenancy. Form is built accessibly: labelled fields,
/// autofill hints, error identification (WCAG 1.3.5 / 3.3.1 / 3.3.2).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO(fl-0): replace with serverpod_auth sign-in.
      ref.read(isSignedInProvider.notifier).state = true;
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = MakerflowTheme.of(context).colors;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: MfCard(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('MakerFlow PM',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: c.text)),
                  const SizedBox(height: 4),
                  Text('Sign in to your workspace',
                      style: TextStyle(color: c.muted)),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _email,
                    autofillHints: const [AutofillHints.email],
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        labelText: 'Email', border: OutlineInputBorder()),
                    validator: (v) =>
                        (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    autofillHints: const [AutofillHints.password],
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Password', border: OutlineInputBorder()),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter your password' : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(onPressed: _submit, child: const Text('Sign in')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
