import 'package:flutter/material.dart';
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
/// continua lá depois de passar por Mesas e voltar.
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

  /// Posição da bolha na barra inferior. Não acompanha [_indiceAba]: quando
  /// a aba aberta não está na barra, a bolha fica sobre o botão "Mais".
  int _indiceBolha = 0;

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

  List<AbaPrincipal> get _abasDaBarra =>
      _abasVisiveis.where((aba) => aba.fixaNaBarra).toList();

  Future<void> _carregarPerfil() async {
    final admin = await SessaoAutenticacao.ehAdministrador();
    if (!mounted) return;
    setState(() {
      _ehAdministrador = admin;
      // A lista de abas encolhe para quem não é admin; se a aba aberta caiu
      // fora dela, volta para o início.
      if (_indiceAba >= _abasVisiveis.length) _indiceAba = 0;
      _sincronizarBolha();
    });
  }

  /// Alinha a bolha da barra com a aba aberta.
  void _sincronizarBolha() {
    final atual = _abasVisiveis[_indiceAba];
    final naBarra = _abasDaBarra.indexOf(atual);
    // Fora da barra, a bolha descansa sobre o "Mais" — a última posição.
    _indiceBolha = naBarra == -1 ? _abasDaBarra.length : naBarra;
  }

  /// Abre uma aba pelo índice em [_abasVisiveis].
  void _irParaAba(int indice) {
    if (indice < 0 || indice >= _abasVisiveis.length) return;
    setState(() {
      _indiceAba = indice;
      _sincronizarBolha();
    });
  }

  /// Abre uma aba pelo título (ver [TitulosAba]). Ignora um título que não
  /// está visível ao perfil atual.
  void _abrirAbaPeloTitulo(String titulo) {
    final indice = indiceDaAba(_abasVisiveis, titulo);
    if (indice >= 0) _irParaAba(indice);
  }

  void _aoTocarNaBarra(int indiceNaBarra) {
    final aba = _abasDaBarra[indiceNaBarra];
    _irParaAba(_abasVisiveis.indexOf(aba));
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
      MaterialPageRoute(builder: (_) => LoginPage()),
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
      // Fechar o menu tocando fora não escolhe aba nenhuma: a bolha volta
      // para onde estava.
      onDrawerChanged: (aberto) {
        if (!aberto) setState(_sincronizarBolha);
      },
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
        abas: _abasDaBarra,
        indiceVisual: _indiceBolha,
        aoTocarAba: _aoTocarNaBarra,
        aoTocarMais: () {
          setState(() => _indiceBolha = _abasDaBarra.length);
          _chaveScaffold.currentState?.openDrawer();
        },
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
