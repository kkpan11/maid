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
    } catch (error) {
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
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: buildForm(context),
          ),
        ),
      );

  Widget buildForm(BuildContext context) => Form(
    key: formKey,
    child: ListView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      children: [
        buildEmailField(),
        const SizedBox(height: 16),
        buildPasswordField(),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: submitting ? null : logIn,
          child: const Text('Login'),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed('/register'),
          child: const Text('Create an account'),
        ),
      ],
    ),
  );

  Widget buildEmailField() => TextFormField(
    controller: emailController,
    decoration: const InputDecoration(
      label: Text('Email'),
    ),
    validator: (val) {
      if (val == null || val.isEmpty) {
        return 'Required';
      }
      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(val)) {
        return 'Please enter a valid email';
      }
      return null;
    },
    keyboardType: TextInputType.emailAddress,
  );

  Widget buildPasswordField() => TextFormField(
    controller: passwordController,
    obscureText: obscurePassword,
    decoration: InputDecoration(
      label: const Text('Password'),
      suffixIcon: IconButton(
        onPressed: () => setState(() => obscurePassword = !obscurePassword),
        icon: obscurePassword
            ? const Icon(Icons.visibility_off)
            : const Icon(Icons.visibility),
      ),
    ),
    validator: (val) {
      if (val == null || val.isEmpty) {
        return 'Required';
      }
      return null;
    },
  );
}
