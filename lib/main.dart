
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Perfil com Foto e Localização',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const TelaPerfil(),
    );
  }
}

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  // Dados do perfil
  File? foto;
  String nomeUsuario = '';

  // Dados da localização
  String localizacao = 'Localização ainda não obtida';
  bool localizacaoObtida = false;
  bool buscandoLocalizacao = false;

  // Escolher foto da câmera ou galeria
  Future<void> escolherFoto(ImageSource origem) async {
    try {
      final picker = ImagePicker();

      final imagem = await picker.pickImage(
        source: origem,
      );

      if (imagem != null) {
        if (!mounted) return;

        setState(() {
          foto = File(imagem.path);
        });
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível selecionar a foto.'),
        ),
      );
    }
  }

  // Remover foto do perfil
  void removerFoto() {
    setState(() {
      foto = null;
    });
  }

  // Obter localização atual
  Future<void> obterLocalizacao() async {
    setState(() {
      buscandoLocalizacao = true;
    });

    try {
      final servicoAtivo =
          await Geolocator.isLocationServiceEnabled();

      if (!servicoAtivo) {
        atualizarErroLocalizacao(
          'Ative o GPS do dispositivo.',
        );
        return;
      }

      var permissao = await Geolocator.checkPermission();

      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }

      if (permissao == LocationPermission.denied) {
        atualizarErroLocalizacao(
          'Permissão de localização negada.',
        );
        return;
      }

      if (permissao == LocationPermission.deniedForever) {
        atualizarErroLocalizacao(
          'Permissão negada permanentemente. '
          'Libere-a nas configurações.',
        );
        return;
      }

      final posicao = await Geolocator.getCurrentPosition();

      if (!mounted) return;

      setState(() {
        localizacao =
            'Latitude: ${posicao.latitude.toStringAsFixed(4)}\n'
            'Longitude: ${posicao.longitude.toStringAsFixed(4)}';

        localizacaoObtida = true;
        buscandoLocalizacao = false;
      });
    } catch (_) {
      atualizarErroLocalizacao(
        'Não foi possível obter a localização.',
      );
    }
  }

  // Tratamento de erros da localização
  void atualizarErroLocalizacao(String mensagem) {
    if (!mounted) return;

    setState(() {
      localizacao = mensagem;
      localizacaoObtida = false;
      buscandoLocalizacao = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Foto do perfil
                CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage:
                      foto != null ? FileImage(foto!) : null,
                  child: foto == null
                      ? const Icon(
                          Icons.person,
                          size: 70,
                          color: Colors.blue,
                        )
                      : null,
                ),

                const SizedBox(height: 20),

                // Nome exibido no perfil
                Text(
                  nomeUsuario.isEmpty
                      ? 'Meu Perfil'
                      : nomeUsuario,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // Campo para digitar nome
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Nome do usuário',
                    hintText: 'Digite seu nome',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (valor) {
                    setState(() {
                      nomeUsuario = valor;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Botão para abrir a câmera
                ElevatedButton.icon(
                  onPressed: () =>
                      escolherFoto(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Tirar foto'),
                ),

                const SizedBox(height: 8),

                // Botão para abrir a galeria
                ElevatedButton.icon(
                  onPressed: () =>
                      escolherFoto(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Escolher da galeria'),
                ),

                const SizedBox(height: 8),

                // Botão para remover foto
                ElevatedButton.icon(
                  onPressed: foto == null ? null : removerFoto,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remover foto'),
                ),

                const SizedBox(height: 25),

                const Divider(),

                const SizedBox(height: 20),

                const Text(
                  'Minha Localização',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                // Ícone muda após obter localização
                Icon(
                  localizacaoObtida
                      ? Icons.location_on
                      : Icons.location_searching,
                  size: 45,
                  color: localizacaoObtida
                      ? Colors.green
                      : Colors.grey,
                ),

                const SizedBox(height: 10),

                // Latitude e longitude
                Text(
                  localizacao,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 20),

                // Botão para obter ou atualizar localização
                ElevatedButton.icon(
                  onPressed: buscandoLocalizacao
                      ? null
                      : obterLocalizacao,
                  icon: buscandoLocalizacao
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          localizacaoObtida
                              ? Icons.refresh
                              : Icons.my_location,
                        ),
                  label: Text(
                    buscandoLocalizacao
                        ? 'Obtendo localização...'
                        : localizacaoObtida
                            ? 'Atualizar localização'
                            : 'Usar minha localização',
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
