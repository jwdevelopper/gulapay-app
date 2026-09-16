import 'package:flutter/material.dart';
import 'package:my_app_teste/core/acoes_criacao.dart';
import 'package:my_app_teste/modules/home/dto/abas_home.dart';
import 'package:my_app_teste/core/api_error.dart';
import 'package:my_app_teste/core/auth_session.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_campo_busca.dart';
import 'package:my_app_teste/core/widgets/app_carregando.dart';
import 'package:my_app_teste/core/widgets/app_chip_filtro.dart';
import 'package:my_app_teste/core/widgets/app_dialogo_confirmacao.dart';
import 'package:my_app_teste/core/widgets/app_estado_vazio.dart';
import 'package:my_app_teste/modules/usuario/dto/filtro_usuarios.dart';
import 'package:my_app_teste/modules/usuario/dto/rotulos_usuario.dart';
import 'package:my_app_teste/modules/usuario/dto/usuario_response.dart';
import 'package:my_app_teste/modules/usuario/page/usuario_form_page.dart';
import 'package:my_app_teste/modules/usuario/service/usuario_service.dart';
import 'package:my_app_teste/modules/usuario/widgets/cartao_usuario.dart';

/// Cadastro de usuários com login.
///
/// Cuida de estado, carga e navegação: o recorte vive em [FiltroUsuarios],
/// as traduções em [RotulosUsuario] e cada linha em [CartaoUsuario].
///
/// A tela é restrita a administradores — a checagem é local, pelo perfil no
/// JWT, e o backend recusa de novo do lado dele. Sem o gate, um caixa veria
/// a lista antes de tomar 403 na primeira ação.
class UsuarioListaPagina extends StatefulWidget {
  const UsuarioListaPagina({super.key});

  @override
  State<UsuarioListaPagina> createState() => _UsuarioListaPaginaState();
}

class _UsuarioListaPaginaState extends State<UsuarioListaPagina> {
  final _servico = UsuarioServico();
  final _busca = TextEditingController();

  List<UsuarioResposta> _usuarios = [];
  FiltroUsuarios _filtro = const FiltroUsuarios();
  bool _carregando = true;
  bool _autorizado = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    // Registra a acao do "+" da barra inferior para esta aba.
    AcoesCriacao.registrar(TitulosAba.usuarios, _abrirFormulario);
    _inicializar();
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Dados
  // ---------------------------------------------------------------------

  Future<void> _inicializar() async {
    final ehAdmin = await SessaoAutenticacao.ehAdministrador();
    if (!mounted) return;
    setState(() => _autorizado = ehAdmin);
    if (ehAdmin) {
      await _carregar();
    } else {
      setState(() => _carregando = false);
    }
  }

  Future<void> _carregar({bool mostrarCarregando = true}) async {
    if (mostrarCarregando) {
      setState(() {
        _carregando = true;
        _erro = null;
      });
    }
    try {
      final lista = await _servico.listar();
      if (mounted) {
        setState(() {
          _usuarios = lista;
          _erro = null;
        });
      }
    } on ApiError catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _erro = 'Não foi possível carregar os usuários.');
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _limparFiltros() {
    _busca.clear();
    setState(() => _filtro = const FiltroUsuarios());
  }

  // ---------------------------------------------------------------------
  // Ações
  // ---------------------------------------------------------------------

  Future<void> _abrirFormulario({UsuarioResposta? usuario}) async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => UsuarioFormularioPagina(usuario: usuario),
      ),
    );
    if (salvou != true || !mounted) return;
    _avisar(
      usuario == null ? 'Usuário cadastrado.' : 'Usuário atualizado.',
      sucesso: true,
    );
    await _carregar();
  }

  Future<bool> _confirmarExclusao(UsuarioResposta u) async =>
      await AppDialogoConfirmacao.exclusao(
        context,
        titulo: 'Excluir usuário',
        mensagem: 'Deseja realmente excluir "${u.nome ?? u.login}"?',
      ) ??
      false;

  /// Exclui e devolve se deu certo — o `Dismissible` usa o retorno para
  /// decidir se o card some ou volta ao lugar.
  Future<bool> _excluir(UsuarioResposta u) async {
    if (u.id == null) return false;
    try {
      await _servico.deletar(u.id!);
      if (!mounted) return false;
      setState(() => _usuarios.removeWhere((x) => x.id == u.id));
      _avisar('Usuário "${u.nome ?? u.login}" excluído.', sucesso: true);
      return true;
    } on ApiError catch (e) {
      _avisar('Erro ao excluir: ${e.message}');
      return false;
    }
  }

  Future<void> _excluirPeloMenu(UsuarioResposta u) async {
    if (await _confirmarExclusao(u)) await _excluir(u);
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
  Widget build(BuildContext context) {
    if (!_autorizado && !_carregando) return _acessoNegado();

    return Scaffold(
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
  }

  Widget _acessoNegado() => const Scaffold(
    backgroundColor: AppTema.fundo,
    body: Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: AppEstadoVazio(
          icone: Icons.lock_outline_rounded,
          titulo: 'Acesso restrito',
          mensagem: 'Apenas administradores podem gerenciar usuários.',
        ),
      ),
    ),
  );

  Widget _filtros() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
    child: Column(
      children: [
        AppCampoBusca(
          controle: _busca,
          dica: 'Buscar por nome ou login…',
          aoMudar: (v) => setState(() => _filtro = _filtro.copiarCom(texto: v)),
        ),
        const SizedBox(height: 10),
        AppFileiraChips(
          recuoLateral: 0,
          chips: [
            AppChipFiltro(
              rotulo: 'Todos',
              selecionado: _filtro.perfil == null,
              aoTocar: () => setState(
                () => _filtro = _filtro.copiarCom(limparPerfil: true),
              ),
            ),
            for (final perfil in RotulosUsuario.perfis)
              AppChipFiltro(
                rotulo: RotulosUsuario.perfil(perfil),
                selecionado: _filtro.perfil == perfil,
                aoTocar: () =>
                    setState(() => _filtro = _filtro.alternarPerfil(perfil)),
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

    final filtrados = _filtro.aplicar(_usuarios);
    if (filtrados.isEmpty) {
      return _rolavel(
        _filtro.vazio
            ? AppEstadoVazio(
                icone: Icons.people_outline_rounded,
                titulo: 'Nenhum usuário cadastrado',
                mensagem:
                    'Cadastre os administradores, caixas e garçons que vão '
                    'usar o sistema.',
                rotuloBotao: 'Novo usuário',
                aoTocarBotao: _abrirFormulario,
              )
            : AppEstadoVazio(
                icone: Icons.search_off_rounded,
                titulo: 'Nada encontrado',
                mensagem: 'Nenhum usuário corresponde aos filtros aplicados.',
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
      itemCount: filtrados.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final usuario = filtrados[i];
        return CartaoUsuario(
          usuario: usuario,
          aoEditar: () => _abrirFormulario(usuario: usuario),
          aoExcluir: () => _excluirPeloMenu(usuario),
          aoConfirmarArrastar: () async {
            if (!await _confirmarExclusao(usuario)) return false;
            return _excluir(usuario);
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
