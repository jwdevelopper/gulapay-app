import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_barra_acoes.dart';
import 'package:my_app_teste/core/widgets/app_campo_texto.dart';
import 'package:my_app_teste/core/widgets/app_dica.dart';
import 'package:my_app_teste/core/widgets/app_rotulo.dart';
import 'package:my_app_teste/modules/categoria/dto/categoria.dart';
import 'package:my_app_teste/modules/categoria/service/categoria_service.dart';

class CategoriaFormPage extends StatefulWidget {
  final Categoria? categoria;
  const CategoriaFormPage({super.key, this.categoria});

  bool get ehEdicao => categoria != null;

  @override
  State<CategoriaFormPage> createState() => _CategoriaFormPageState();
}

class _CategoriaFormPageState extends State<CategoriaFormPage> {
  static const int _limiteNome = 100;
  static const int _limiteDescricao = 255;

  final _chaveFormulario = GlobalKey<FormState>();
  final _servico = CategoriaService();

  final _controleNome = TextEditingController();
  final _controleDescricao = TextEditingController();

  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    final c = widget.categoria;
    if (c != null) {
      _controleNome.text = c.nome;
      _controleDescricao.text = c.descricao ?? '';
    }
  }

  @override
  void dispose() {
    _controleNome.dispose();
    _controleDescricao.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_chaveFormulario.currentState!.validate()) return;

    final nova = Categoria(
      id: widget.categoria?.id,
      nome: _controleNome.text.trim(),
      descricao: _controleDescricao.text.trim().isEmpty
          ? null
          : _controleDescricao.text.trim(),
      ativo: widget.categoria?.ativo,
    );

    setState(() => _carregando = true);
    try {
      if (widget.ehEdicao) {
        await _servico.atualizar(widget.categoria!.id!, nova);
      } else {
        await _servico.criar(nova);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTema.fundo,
      appBar: AppBar(
        backgroundColor: AppTema.fundo,
        foregroundColor: AppTema.textoEscuro,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.ehEdicao ? 'Editar categoria' : 'Nova categoria',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTema.textoEscuro,
              ),
            ),
            const Text(
              'Cardápio · Identidade',
              style: TextStyle(fontSize: 12, color: AppTema.textoSecundario),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Form(
                  key: _chaveFormulario,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppRotulo(
                        'Nome *',
                        contador:
                            '${_controleNome.text.length}/$_limiteNome',
                      ),
                      const SizedBox(height: 6),
                      AppCampoTexto(
                        controle: _controleNome,
                        dica: 'Ex.: Pratos principais',
                        tamanhoMax: _limiteNome,
                        aoMudar: (_) => setState(() {}),
                        validador: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return 'Informe o nome';
                          if (t.length < 2) return 'Mínimo de 2 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      AppRotulo(
                        'Descrição',
                        opcional: true,
                        contador:
                            '${_controleDescricao.text.length}/$_limiteDescricao',
                      ),
                      const SizedBox(height: 6),
                      AppCampoTexto(
                        controle: _controleDescricao,
                        dica:
                            'Detalhes, ingredientes, acompanhamentos...',
                        tamanhoMax: _limiteDescricao,
                        aoMudar: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 18),
                      const AppDica(
                        'Use um nome curto e claro. A descrição aparece no '
                        'cardápio digital pro cliente.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AppBarraAcoes(
              textoConfirmar: widget.ehEdicao ? 'Atualizar' : 'Salvar',
              iconeConfirmar:
                  const FaIcon(FontAwesomeIcons.chevronRight, size: 14),
              carregando: _carregando,
              aoCancelar: () => Navigator.pop(context),
              aoConfirmar: _salvar,
            ),
          ],
        ),
      ),
    );
  }
}
