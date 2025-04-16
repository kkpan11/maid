part of 'package:maid/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool submitting = false;
  bool obscurePassword = true;

  Future<void> logIn() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    final email = emailController.text;
    final password = passwordController.text;

    try {
      setState(() => submitting = true);

      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      setState(() => submitting = false);

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/chat');
    } 
    on AuthException catch (error) {
      setState(() => submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating
        ),
      );
    } 
    catch (error) {
      setState(() => submitting = false);
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(exception: error),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: buildForm(context),
      ),
    ),
  );

  Widget buildForm(BuildContext context) => Form(
    key: formKey,
    child: SingleChildScrollView(
      child: buildColumn(context),
    ),
  );

  Widget buildColumn(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        AppLocalizations.of(context)!.login,
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      buildEmailField(),
      const SizedBox(height: 16),
      buildPasswordField(),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: submitting ? null : logIn,
        child: Text(AppLocalizations.of(context)!.login),
      ),
      const SizedBox(height: 16),
      buildRow(context),
    ],
  );

  Widget buildEmailField() => TextFormField(
    controller: emailController,
    decoration: InputDecoration(
      label: Text(AppLocalizations.of(context)!.email),
    ),
    validator: (val) {
      if (val == null || val.isEmpty) {
        return AppLocalizations.of(context)!.required;
      }
      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(val)) {
        return AppLocalizations.of(context)!.invalidEmail;
      }
      return null;
    },
    keyboardType: TextInputType.emailAddress,
  );

  Widget buildPasswordField() => TextFormField(
    controller: passwordController,
    obscureText: obscurePassword,
    decoration: InputDecoration(
      label: Text(AppLocalizations.of(context)!.password),
      suffixIcon: IconButton(
        onPressed: () => setState(() => obscurePassword = !obscurePassword),
        icon: obscurePassword
            ? const Icon(Icons.visibility_off)
            : const Icon(Icons.visibility),
      ),
    ),
    validator: (val) {
      if (val == null || val.isEmpty) {
        return AppLocalizations.of(context)!.required;
      }
      return null;
    },
  );

  Widget buildRow(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      TextButton(
        onPressed: () => Navigator.of(context).pushReplacementNamed('/register'),
        child: Text(AppLocalizations.of(context)!.createAccount),
      ),
      TextButton(
        onPressed: () => Navigator.of(context).pushReplacementNamed('/reset-password'),
        child: Text(AppLocalizations.of(context)!.resetPassword),
      ),
    ],
  );
}