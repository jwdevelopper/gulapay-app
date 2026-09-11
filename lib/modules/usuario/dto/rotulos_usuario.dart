/// Perfis de acesso e as suas traduções.
///
/// Espelha o enum `Perfil` do backend. Entregador não entra: ele é um
/// recurso cadastrado, sem login no sistema (seção 3.5).
class RotulosUsuario {
  const RotulosUsuario._();

  static const administrador = 'ADMINISTRADOR';
  static const caixa = 'CAIXA';
  static const garcom = 'GARCOM';

  /// Todos os perfis com login, na ordem de abrangência de acesso.
  static const perfis = [administrador, caixa, garcom];

  /// Nome legível do perfil.
  static String perfil(String? valor) => switch (valor) {
    administrador => 'Administrador',
    caixa => 'Caixa',
    garcom => 'Garçom',
    _ => valor ?? '-',
  };

  /// Só o perfil `GARCOM` tem percentual de comissão (seção 4.2) — é o que
  /// decide se o formulário mostra esse campo.
  static bool exigeComissao(String? valor) => valor == garcom;
}
