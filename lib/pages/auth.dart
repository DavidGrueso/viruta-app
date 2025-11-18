
import 'package:flutter/material.dart';
import 'home.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Credenciales válidas (puedes reemplazar esto con una llamada a API)
  static const String _validUsername = 'admin';
  static const String _validPassword = '12345';

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simular delay de validación
    await Future.delayed(const Duration(milliseconds: 500));

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Por favor completa los campos';
      });
      return;
    }

    if (username == _validUsername && password == _validPassword) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Usuario o contraseña incorrectos';
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 254, 250), 
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Image(
                      image: AssetImage('lib/assets/viruta_logo.png'),
                      height: 80,
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      "VIRUTA",
                      style: TextStyle(
                        fontSize: 55,
                        letterSpacing: 4,
                        color: Color.fromARGB(255, 49, 122, 52),
                        fontFamily: 'roboto',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Campo de usuario
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(193, 0, 0, 0).withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Usuario',
                    hintStyle: TextStyle( fontSize: 14),
                    prefixIcon: const Icon(Icons.person),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 36),
                  ),
                  ),
                ),
                const SizedBox(height: 23),

                // Campo de contraseña
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(193, 0, 0, 0).withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      hintText: 'Contraseña',
                      hintStyle: TextStyle( fontSize: 14),
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Mensaje de error
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(0, 0, 0, 0),
                    ),
                    child: Row(
                      children: [
                        Icon( Icons.error, color: Colors.red.shade800,),
                        const SizedBox(width: 8),
                        Text(
                        _errorMessage!,
                        style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),

                // Botón de iniciar sesión
                SizedBox(
                  width: 222,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: const Color.fromARGB(255, 92, 163, 94),
                      shadowColor: Colors.greenAccent
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Iniciar sesión',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),


                const SizedBox(height: 20),
                const Text( 
                  'o inicia sesión con',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 103, 103, 103),
                  ),
                ),
                const SizedBox(height: 20),

                // Botones de inicio rápido
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [ 
                    IconButton( 
                      onPressed: () {}, 
                      icon: const Icon(Icons.account_circle),
                      style: IconButton.styleFrom( backgroundColor: const Color.fromARGB(255, 212, 247, 225), foregroundColor: const Color.fromARGB(255, 19, 45, 26)),
                      ),
                    const SizedBox(width: 10),
                    IconButton( 
                      onPressed: () {}, 
                      icon: const Icon(Icons.apple),
                      style: IconButton.styleFrom( backgroundColor: const Color.fromARGB(255, 212, 247, 225), foregroundColor: const Color.fromARGB(255, 19, 45, 26)),
                      ),

                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¿No tienes una cuenta? Puedes crearla aquí:'),
                    //const SizedBox(width: 2),
                    TextButton(onPressed: () {}, child: const Text('Crear cuenta')),
                  ],
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}