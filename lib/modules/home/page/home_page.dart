import 'package:flutter/material.dart';
import 'package:my_app_teste/core/acoes_criacao.dart';
import 'package:my_app_teste/core/api_client.dart';
import 'package:my_app_teste/core/auth_session.dart';
import 'package:my_app_teste/core/theme/app_tema.dart';
import 'package:my_app_teste/core/widgets/app_dialogo_confirmacao.dart';
import 'package:my_app_teste/modules/home/dto/aba_principal.dart';
import 'package:my_app_teste/modules/home/dto/abas_home.dart';
import 'package:my_app_teste/modules/home/widgets/barra_inferior_home.dart';
import 'package:my_app_teste/modules/home/widgets/folha_notificacoes.dart';
import 'package:my_app_teste/modules/home/widgets/menu_lateral.dart';
import 'package:my_app_teste/modules/login/page/login_page.dart';

/// Casca do app: AppBar, menu lateral, barra inferior e a aba aberta.
///
/// Cuida apenas da navegação entre abas. O catálogo de telas vive em
/// [construirAbas], e cada peça da casca em `widgets/`.
///
/// As páginas ficam num `IndexedStack`: todas montadas, só uma visível.
/// É o que preserva o estado de cada aba — a busca digitada em Produtos
/// continua lá depois de passar por Mesas e voltar — e também o que faz o
/// registro em [AcoesCriacao] acontecer uma única vez, na inicialização.
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _chaveScaffold = GlobalKey<ScaffoldState>();

  late final List<AbaPrincipal> _todasAbas = construirAbas(
    aoAbrirAba: _abrirAbaPeloTitulo,
  );

  /// Índice da aba aberta, dentro de [_abasVisiveis].
  int _indiceAba = 0;

  bool _ehAdministrador = false;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  // ---------------------------------------------------------------------
  // Abas
  // ---------------------------------------------------------------------

  List<AbaPrincipal> get _abasVisiveis =>
      _todasAbas.where((aba) => !aba.apenasAdmin || _ehAdministrador).toList();

  List<AbaPrincipal> get _abasFixas =>
      _abasVisiveis.where((aba) => aba.fixaNaBarra).toList();

  AbaPrincipal get _abaAtual {
    final abas = _abasVisiveis;
    return abas[_indiceAba.clamp(0, abas.length - 1)];
  }

  /// A ação de criar da aba aberta, se ela tiver uma.
  ///
  /// É `null` nas telas sem cadastro (Início, Mesas, Pedidos) — e é isso
  /// que faz o `+` aparecer ou não.
  VoidCallback? get _acaoDeCriar => AcoesCriacao.de(_abaAtual.tituloAppBar);

  /// Os itens da barra inferior, na ordem final.
  ///
  /// A barra é dinâmica:
  ///
  ///  * **tela sem cadastro** — as abas fixas nas posições naturais; se a
  ///    aba aberta veio do menu lateral, ela entra no meio para a bolha
  ///    ter onde pousar;
  ///  * **tela com cadastro** — a aba aberta vai para o **centro** e o `+`
  ///    ocupa o canto, cada um com o seu entalhe na curva.
  List<AbaPrincipal> get _itensDaBarra {
    final fixas = _abasFixas;
    final atual = _abaAtual;

    if (_acaoDeCriar == null) {
      if (fixas.contains(atual)) return fixas;
      return List<AbaPrincipal>.of(fixas)..insert(fixas.length ~/ 2, atual);
    }

    final itens = List<AbaPrincipal>.of(fixas)..remove(atual);
    itens.insert((itens.length + 1) ~/ 2, atual);
    return itens;
  }

  Future<void> _carregarPerfil() async {
    final admin = await SessaoAutenticacao.ehAdministrador();
    if (!mounted) return;
    setState(() {
      _ehAdministrador = admin;
      // A lista de abas encolhe para quem não é admin; se a aba aberta caiu
      // fora dela, volta para o início.
      if (_indiceAba >= _abasVisiveis.length) _indiceAba = 0;
    });
  }

  /// Abre uma aba pelo índice em [_abasVisiveis].
  void _irParaAba(int indice) {
    if (indice < 0 || indice >= _abasVisiveis.length) return;
    setState(() => _indiceAba = indice);
  }

  /// Abre uma aba pelo título (ver [TitulosAba]). Ignora um título que não
  /// está visível ao perfil atual.
  void _abrirAbaPeloTitulo(String titulo) {
    final indice = indiceDaAba(_abasVisiveis, titulo);
    if (indice >= 0) _irParaAba(indice);
  }

  void _aoTocarNaBarra(int indiceNaBarra) {
    final itens = _itensDaBarra;
    if (indiceNaBarra >= itens.length) return;
    _irParaAba(_abasVisiveis.indexOf(itens[indiceNaBarra]));
  }

  void _aoSelecionarNoMenu(int indice) {
    Navigator.pop(context);
    _irParaAba(indice);
  }

  // ---------------------------------------------------------------------
  // Sessão
  // ---------------------------------------------------------------------

  Future<void> _confirmarSaida() async {
    final sair = await AppDialogoConfirmacao.mostrar(
      context,
      titulo: 'Sair',
      mensagem: 'Deseja encerrar a sessão?',
      rotuloConfirmar: 'Sair',
      icone: Icons.logout_rounded,
    );
    if (sair != true || !mounted) return;

    await ApiClient.removerToken();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final abas = _abasVisiveis;
    final indice = _indiceAba.clamp(0, abas.length - 1);

    return Scaffold(
      key: _chaveScaffold,
      backgroundColor: AppTema.fundo,
      drawer: MenuLateralHome(
        abas: abas,
        selecionado: indice,
        aoSelecionar: _aoSelecionarNoMenu,
      ),
      appBar: _appBar(abas[indice].tituloAppBar),
      body: IndexedStack(
        index: indice,
        children: [for (final aba in abas) aba.pagina],
      ),
      bottomNavigationBar: BarraInferiorHome(
        itens: _itensDaBarra,
        abaAtual: _abaAtual,
        aoTocarAba: _aoTocarNaBarra,
        aoTocarAdicionar: _acaoDeCriar,
      ),
    );
  }

  PreferredSizeWidget _appBar(String titulo) => AppBar(
    title: Text(
      titulo,
      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTema.texto),
    ),
    backgroundColor: AppTema.fundo,
    foregroundColor: AppTema.texto,
    iconTheme: const IconThemeData(color: AppTema.primariaEscura),
    elevation: 0,
    actions: [
      IconButton(
        tooltip: 'Notificações',
        onPressed: () => abrirFolhaNotificacoes(context),
        icon: const Icon(Icons.notifications_outlined),
      ),
      IconButton(
        tooltip: 'Sair',
        onPressed: _confirmarSaida,
        icon: const Icon(Icons.logout_rounded),
      ),
      const SizedBox(width: 4),
    ],
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, color: AppTema.borda),
    ),
  );
}
