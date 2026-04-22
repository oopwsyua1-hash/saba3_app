import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLoading = false;
  bool _isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تسجيل الدخول')),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ غير متوقع'), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      final res = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (res.user != null) {
        // انشاء البروفايل بجدول profiles مع قيد 20 حرف للاسم
        await supabase.from('profiles').insert({
          'id': res.user!.id,
          'username': _usernameController.text.trim().substring(0, 20),
          'bio': '', // السيرة 60 حرف - نخليها فاضية بالبداية
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم انشاء الحساب بنجاح')),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ بالبروفايل: ${e.message}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ غير متوقع'), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'تسجيل الدخول' : 'حساب جديد')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'الايميل'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'كلمة السر'),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          if (!_isLogin)
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'اسم المستخدم',
                helperText: '20 حرف كحد اقصى',
              ),
              maxLength: 20, // قيد الـ 20 حرف اللي طلبتو
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : (_isLogin ? _signIn : _signUp),
            child: Text(_isLoading ? 'جاري التحميل...' : _isLogin ? 'دخول' : 'انشاء حساب'),
          ),
          TextButton(
            onPressed: () => setState(() => _isLogin = !_isLogin),
            child: Text(_isLogin ? 'ما عندك حساب؟ سجل هون' : 'عندك حساب؟ سجل دخول'),
          ),
        ],
      ),
    );
  }
}
