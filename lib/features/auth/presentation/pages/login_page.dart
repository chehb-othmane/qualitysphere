import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _logoController;
  late AnimationController _formController;
  late Animation<double> _logoAnimation;
  late Animation<double> _formAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Animation du logo
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    // Animation du formulaire
    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _formAnimation = CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(_formAnimation);

    // Démarrer les animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _formController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _formController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        LoginSubmitted(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final textColor = isDarkMode
        ? const Color(0xFFF1F5F9)
        : const Color(0xFF1E293B);
    final inputColor = isDarkMode
        ? const Color(0xFF1E293B)
        : const Color(0xFFF1F5F9);
    final primaryColor = const Color(0xFF4F46E5);
    final secondaryColor = const Color(0xFF22D3EE);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/dashboard', (route) => false);
          }
          if (state.status == AuthStatus.failure && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: const Color(0xFFEF4444),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == AuthStatus.loading;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo and Header
                      ScaleTransition(
                        scale: _logoAnimation,
                        child: Container(
                          height: 80,
                          width: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/icons/logo.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeTransition(
                        opacity: _formAnimation,
                        child: Column(
                          children: [
                            Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: textColor.withOpacity(0.6),
                                ),
                                children: [
                                  const TextSpan(text: 'Log in to '),
                                  TextSpan(
                                    text: 'QualitySphere',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? secondaryColor
                                          : primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Email Field
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _formAnimation,
                          child: _AnimatedTextField(
                            label: 'Email Address',
                            hintText: 'Enter your email address',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textColor: textColor,
                            inputColor: inputColor,
                            primaryColor: primaryColor,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Invalid email';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _formAnimation,
                          child: _AnimatedPasswordField(
                            label: 'Password',
                            hintText: 'Enter your password',
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            onToggleVisibility: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            textColor: textColor,
                            inputColor: inputColor,
                            primaryColor: primaryColor,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 4) {
                                return 'At least 4 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Forgot Password
                      FadeTransition(
                        opacity: _formAnimation,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _AnimatedTextLink(
                            text: 'Forgot Password?',
                            onTap: () {
                              // TODO: Implement password recovery
                            },
                            color: isDarkMode ? secondaryColor : primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _formAnimation,
                          child: _AnimatedGradientButton(
                            onPressed: isLoading ? null : _onLoginPressed,
                            isLoading: isLoading,
                            primaryColor: primaryColor,
                            text: 'Log In',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sign Up Link
                      FadeTransition(
                        opacity: _formAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor.withOpacity(0.6),
                              ),
                            ),
                            _AnimatedTextLink(
                              text: 'Sign Up',
                              onTap: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                              color: isDarkMode ? secondaryColor : primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ],
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

// Widget de champ de texte animé avec effet hover
class _AnimatedTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final Color textColor;
  final Color inputColor;
  final Color primaryColor;
  final String? Function(String?)? validator;

  const _AnimatedTextField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.textColor,
    required this.inputColor,
    required this.primaryColor,
    this.keyboardType,
    this.validator,
  });

  @override
  State<_AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<_AnimatedTextField> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.textColor.withOpacity(0.8),
            ),
          ),
        ),
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()
              ..translate(0.0, _isHovered ? -2.0 : 0.0),
            child: TextFormField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: widget.textColor,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(color: widget.textColor.withOpacity(0.4)),
                filled: true,
                fillColor: widget.inputColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _isHovered
                        ? widget.primaryColor.withOpacity(0.3)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              validator: widget.validator,
            ),
          ),
        ),
      ],
    );
  }
}

// Widget de champ de mot de passe animé avec effet hover
class _AnimatedPasswordField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final Color textColor;
  final Color inputColor;
  final Color primaryColor;
  final String? Function(String?)? validator;

  const _AnimatedPasswordField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
    required this.textColor,
    required this.inputColor,
    required this.primaryColor,
    this.validator,
  });

  @override
  State<_AnimatedPasswordField> createState() => _AnimatedPasswordFieldState();
}

class _AnimatedPasswordFieldState extends State<_AnimatedPasswordField> {
  bool _isHovered = false;
  bool _isIconHovered = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.textColor.withOpacity(0.8),
            ),
          ),
        ),
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()
              ..translate(0.0, _isHovered ? -2.0 : 0.0),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: widget.textColor,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(color: widget.textColor.withOpacity(0.4)),
                filled: true,
                fillColor: widget.inputColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _isHovered
                        ? widget.primaryColor.withOpacity(0.3)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
                suffixIcon: MouseRegion(
                  onEnter: (_) => setState(() => _isIconHovered = true),
                  onExit: (_) => setState(() => _isIconHovered = false),
                  child: IconButton(
                    icon: AnimatedScale(
                      scale: _isIconHovered ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        widget.obscureText
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: _isIconHovered
                            ? widget.primaryColor
                            : widget.textColor.withOpacity(0.4),
                      ),
                    ),
                    onPressed: widget.onToggleVisibility,
                  ),
                ),
              ),
              validator: widget.validator,
            ),
          ),
        ),
      ],
    );
  }
}

// Widget de bouton avec gradient animé et effet hover
class _AnimatedGradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color primaryColor;
  final String text;

  const _AnimatedGradientButton({
    required this.onPressed,
    required this.isLoading,
    required this.primaryColor,
    required this.text,
  });

  @override
  State<_AnimatedGradientButton> createState() =>
      _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<_AnimatedGradientButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..scale(_isHovered ? 1.02 : 1.0)
          ..translate(0.0, _isHovered ? -2.0 : 0.0),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF22D3EE), Color(0xFF4F46E5)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withOpacity(_isHovered ? 0.4 : 0.25),
                blurRadius: _isHovered ? 24 : 20,
                offset: Offset(0, _isHovered ? 6 : 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                alignment: Alignment.center,
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        widget.text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget de lien texte animé avec effet hover
class _AnimatedTextLink extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final Color color;

  const _AnimatedTextLink({
    required this.text,
    required this.onTap,
    required this.color,
  });

  @override
  State<_AnimatedTextLink> createState() => _AnimatedTextLinkState();
}

class _AnimatedTextLinkState extends State<_AnimatedTextLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: widget.color,
            decoration: _isHovered
                ? TextDecoration.underline
                : TextDecoration.none,
          ),
          child: Text(widget.text),
        ),
      ),
    );
  }
}
