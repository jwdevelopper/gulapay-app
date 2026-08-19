import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_barra_acoes.dart';
import 'package:my_app_teste/modules/categoria/dto/categoria.dart';
import 'package:my_app_teste/modules/categoria/service/categoria_service.dart';
import 'package:my_app_teste/modules/categoria/widgets/categoria_form_campos.dart';

class CategoriaFormPage extends StatefulWidget {
  const CategoriaFormPage({super.key, this.categoria});

  final Categoria? categoria;

  bool get ehEdicao => categoria != null;

  @override
  State<CategoriaFormPage> createState() => _CategoriaFormPageState();
}

class _CategoriaFormPageState extends State<CategoriaFormPage> {
  static const _limiteNome = 100;
  static const _limiteDescricao = 255;

  final _chaveFormulario = GlobalKey<FormState>();
  final _servico = CategoriaService();
  final _controleNome = TextEditingController();
  final _controleDescricao = TextEditingController();

  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    final categoria = widget.categoria;
    if (categoria == null) return;
    _controleNome.text = categoria.nome;
    _controleDescricao.text = categoria.descricao ?? '';
  }

  @override
  void dispose() {
    _controleNome.dispose();
    _controleDescricao.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_chaveFormulario.currentState!.validate()) return;

    final descricao = _controleDescricao.text.trim();
    final categoria = Categoria(
      id: widget.categoria?.id,
      nome: _controleNome.text.trim(),
      descricao: descricao.isEmpty ? null : descricao,
      ativo: widget.categoria?.ativo,
    );

    setState(() => _carregando = true);
    try {
      if (widget.ehEdicao) {
        await _servico.atualizar(widget.categoria!.id!, categoria);
      } else {
        await _servico.criar(categoria);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiError catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${erro.message}'),
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
        title: _TituloFormularioCategoria(ehEdicao: widget.ehEdicao),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Form(
                  key: _chaveFormulario,
                  child: CategoriaFormCampos(
                    controleNome: _controleNome,
                    controleDescricao: _controleDescricao,
                    limiteNome: _limiteNome,
                    limiteDescricao: _limiteDescricao,
                    aoMudar: () => setState(() {}),
                  ),
                ),
              ),
            ),
            AppBarraAcoes(
              textoConfirmar: widget.ehEdicao ? 'Atualizar' : 'Salvar',
              iconeConfirmar: const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 14,
              ),
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

class _TituloFormularioCategoria extends StatelessWidget {
  const _TituloFormularioCategoria({required this.ehEdicao});

  final bool ehEdicao;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          ehEdicao ? 'Editar categoria' : 'Nova categoria',
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
    );
  }
}
