import 'package:flutter/material.dart';
import 'package:my_app_teste/core/acoes_criacao.dart';
import 'package:my_app_teste/modules/home/dto/abas_home.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/dto/situacao_cadastro.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_campo_busca.dart';
import 'package:my_app_teste/core/widgets/app_carregando.dart';
import 'package:my_app_teste/core/widgets/app_chip_filtro.dart';
import 'package:my_app_teste/core/widgets/app_dialogo_confirmacao.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';
import 'package:my_app_teste/modules/categoria/dto/categoria.dart';
import 'package:my_app_teste/modules/categoria/dto/filtro_categorias.dart';
import 'package:my_app_teste/modules/categoria/page/categoria_form_page.dart';
import 'package:my_app_teste/modules/categoria/service/categoria_service.dart';
import 'package:my_app_teste/modules/categoria/widgets/cartao_categoria.dart';

/// Cadastro de categorias de produto.
///
/// Cuida de estado, carga e navegação: o recorte vive em
/// [FiltroCategorias] e cada linha em [CartaoCategoria].
///
/// A listagem pede `apenasAtivos: false` de propósito — o filtro "Inativas"
/// precisa ter o que mostrar, e é por ele que uma categoria volta.
class CategoriaPage extends StatefulWidget {
  const CategoriaPage({super.key});

  @override
  State<CategoriaPage> createState() => _CategoriaPageState();
}

class _CategoriaPageState extends State<CategoriaPage> {
  final _servico = CategoriaService();
  final _busca = TextEditingController();

  List<Categoria> _categorias = [];
  FiltroCategorias _filtro = const FiltroCategorias();
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    // Registra a acao do "+" da barra inferior para esta aba.
    AcoesCriacao.registrar(TitulosAba.categorias, _abrirFormulario);
    _carregar();
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Dados
  // ---------------------------------------------------------------------

  Future<void> _carregar({bool mostrarCarregando = true}) async {
    if (mostrarCarregando) {
      setState(() {
        _carregando = true;
        _erro = null;
      });
    }
    try {
      final lista = await _servico.listar(apenasAtivos: false);
      if (mounted) {
        setState(() {
          _categorias = lista;
          _erro = null;
        });
      }
    } on ApiError catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _erro = 'Não foi possível carregar as categorias.');
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _limparFiltros() {
    _busca.clear();
    setState(() => _filtro = const FiltroCategorias());
  }

  // ---------------------------------------------------------------------
  // Ações
  // ---------------------------------------------------------------------

  Future<void> _abrirFormulario({Categoria? categoria}) async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CategoriaFormPage(categoria: categoria),
      ),
    );
    if (salvou != true || !mounted) return;
    _avisar(
      categoria == null ? 'Categoria cadastrada.' : 'Categoria atualizada.',
      sucesso: true,
    );
    await _carregar();
  }

  Future<bool> _confirmarMudanca(Categoria c, {required bool inativar}) async {
    final acao = inativar ? 'Inativar' : 'Reativar';
    return await AppDialogoConfirmacao.mostrar(
          context,
          titulo: '$acao categoria',
          mensagem: inativar
              ? 'Deseja inativar "${c.nome}"? Ela poderá ser reativada '
                    'depois pelo filtro "Inativos".'
              : 'Deseja reativar "${c.nome}"?',
          rotuloConfirmar: acao,
          tom: inativar ? TomConfirmacao.destrutivo : TomConfirmacao.positivo,
        ) ??
        false;
  }

  /// Aplica a mudança de situação e recarrega.
  Future<void> _alternarSituacao(Categoria c, {required bool inativar}) async {
    if (c.id == null) return;
    if (!await _confirmarMudanca(c, inativar: inativar)) return;

    try {
      if (inativar) {
        await _servico.inativar(c.id!);
      } else {
        await _servico.ativar(c);
      }
      _avisar(
        'Categoria "${c.nome}" ${inativar ? 'inativada' : 'reativada'}.',
        sucesso: true,
      );
      await _carregar();
    } on ApiError catch (e) {
      _avisar('Erro: ${e.message}');
    }
  }

  void _avisar(String mensagem, {bool sucesso = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: sucesso ? AppTema.sucesso : AppTema.erro,
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTema.fundo,
    floatingActionButton: FloatingActionButton(
      backgroundColor: AppTema.primaria,
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
      onPressed: _abrirFormulario,
      child: const Icon(Icons.add_rounded),
    ),
    body: SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 12),
          _filtros(),
          Expanded(
            child: RefreshIndicator(
              color: AppTema.primaria,
              onRefresh: () => _carregar(mostrarCarregando: false),
              child: _corpo(),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _filtros() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
    child: Column(
      children: [
        AppCampoBusca(
          controle: _busca,
          dica: 'Buscar por nome ou descrição…',
          aoMudar: (v) => setState(() => _filtro = _filtro.copiarCom(texto: v)),
        ),
        const SizedBox(height: 10),
        AppFileiraChips(
          recuoLateral: 0,
          chips: [
            for (final situacao in SituacaoCadastro.values)
              AppChipFiltro(
                rotulo: situacao.rotulo,
                selecionado: _filtro.situacao == situacao,
                aoTocar: () => setState(
                  () => _filtro = _filtro.copiarCom(situacao: situacao),
                ),
              ),
          ],
        ),
      ],
    ),
  );

  Widget _corpo() {
    if (_carregando) return const AppCarregando();
    if (_erro != null) {
      return _rolavel(
        AppEstadoVazio(
          icone: Icons.cloud_off_rounded,
          titulo: 'Não foi possível carregar',
          mensagem: _erro!,
          rotuloBotao: 'Tentar novamente',
          iconeBotao: Icons.refresh_rounded,
          aoTocarBotao: _carregar,
        ),
      );
    }

    final filtradas = _filtro.aplicar(_categorias);
    if (filtradas.isEmpty) {
      return _rolavel(
        _filtro.vazio
            ? AppEstadoVazio(
                icone: Icons.category_outlined,
                titulo: 'Nenhuma categoria cadastrada',
                mensagem:
                    'As categorias organizam o catálogo e a vitrine de '
                    'produtos. Cadastre a primeira para começar.',
                rotuloBotao: 'Nova categoria',
                aoTocarBotao: _abrirFormulario,
              )
            : AppEstadoVazio(
                icone: Icons.search_off_rounded,
                titulo: 'Nada encontrado',
                mensagem: 'Nenhuma categoria corresponde aos filtros.',
                rotuloBotao: 'Limpar filtros',
                iconeBotao: Icons.filter_alt_off_rounded,
                secundario: true,
                aoTocarBotao: _limparFiltros,
              ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      itemCount: filtradas.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final categoria = filtradas[i];
        final ativa = categoria.ativo ?? true;
        return CartaoCategoria(
          categoria: categoria,
          aoEditar: () => _abrirFormulario(categoria: categoria),
          aoInativar: () => _alternarSituacao(categoria, inativar: true),
          aoReativar: () => _alternarSituacao(categoria, inativar: false),
          aoArrastar: () async {
            await _alternarSituacao(categoria, inativar: ativa);
            // O card continua na lista: a categoria trocou de situação, não
            // deixou de existir.
            return false;
          },
        );
      },
    );
  }

  /// Mantém o conteúdo rolável mesmo quando cabe na tela — sem isso o
  /// "puxar para atualizar" não funciona nos estados de erro e de vazio.
  Widget _rolavel(Widget filho) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(16, 40, 16, 90),
    children: [filho],
  );
}
