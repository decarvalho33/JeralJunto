# Jeral Junto (Gather2Gather) — Instructions / Dev Guide

Este documento explica **a estrutura do projeto**, **onde codar**, **o que vai em cada diretório**, e **como desenvolver em equipe** sem bagunçar o repositório.

> Objetivo: qualquer pessoa do time conseguir abrir o projeto e saber exatamente onde mexer.

---

## ✅ O que é este app?

O Jeral Junto é um app de coordenação privada de grupos ("party") em eventos ao vivo (Carnaval), com foco em uso durante o evento, porém teremos as seguintes features:

- criação e entrada em parties (convite)
- planos do grupo (o que fazer agora/depois)
- localização em tempo real (reencontro rápido)
- botão de pânico em casos de perigo

**Importante:** Não iremos lançar android ou IOS nesse carnaval, mas teremos um site (web) otimizado para mobile que irá **validar nossa ideia**, ou seja, será uma espécie de beta test. O app precisa ser forte em:
- tempo real
- rede ruim / instabilidade
- economia de bateria
- atualizações frequentes (location + planos)
- **lidar com as limitações de transferência de dados do pacote free do supabase**

---

## 🧰 Pré-requisitos (local)

- Flutter instalado e configurado
- Git

Verificação:
```bash
flutter doctor
```

---

## 🚀 Comandos essenciais (dia a dia)

### Instalar dependências

```bash
flutter pub get
```

### Rodar testes

```bash
flutter test
```

### Atualizar dependências (opcional)

Ver o que está desatualizado:

```bash
flutter pub outdated
```

---

## 📁 Estrutura atual do repositório (raiz)

Você verá algo assim:

- `.dart_tool/`
- `.idea/`
- `android/`
- `build/`
- `ios/`
- `lib/`
- `linux/`
- `macos/`
- `test/`
- `web/`
- `windows/`
- `.gitignore`
- `.metadata`
- `analysis_options.yaml`
- `pubspec.lock`
- `pubspec.yaml`
- `README.md`

### ✅ O que cada pasta significa (muito importante)

#### `lib/` ✅ (VOCÊS VÃO CODAR AQUI)

É o **coração** do app. Quase tudo de lógica e UI fica aqui.

> Regra: **se for código do app, ele deve estar em `lib/`.**

---

#### `test/` ✅ (VOCÊS VÃO CODAR AQUI)

Testes unitários e de widget.

---

#### `build/` ❌ (GERADO)

Artefatos gerados pelo build. Não versionar.

---

#### `.dart_tool/` ❌ (GERADO)

Cache/metadata do Dart/Flutter. Não versionar.

---

#### `.idea/` ❌ (IDE)

Config do IntelliJ/Android Studio. Geralmente não versionar.

---

#### `web/`, `windows/`, `macos/`, `linux/` ⚠️ (multiplataforma)

Flutter cria suporte a várias plataformas.
Nosso foco de produto para a versão beta para esse carnaval é **web**.

---

#### `pubspec.yaml` ✅ (importante)

Arquivo principal de dependências e assets.

---

#### `pubspec.lock` ✅ (IMPORTANTE versionar)

Trava versões exatas dos pacotes para todos terem build igual.

---

#### `analysis_options.yaml` ✅

Regras de lint e análise estática.

---

#### `.metadata` ✅

Metadata do Flutter. Normalmente fica.

---

## 🧱 Estrutura recomendada dentro do `lib/`

Pra equipe conseguir crescer sem virar bagunça, vamos padronizar assim:

```
lib/
  main.dart
  app/
    router/
    di/
    app_widget.dart
  core/
    config/
    constants/
    errors/
    helpers/
    network/
    theme/
    widgets/
  features/
    auth/
    party/
    plans/
    location/
    invite/
```

### O que vai em cada uma?

#### `lib/main.dart`

Ponto de entrada. Deve ser **curto**.

- inicializações (ex.: Supabase init)
- chamar `runApp(AppWidget())`

---

#### `lib/app/`

Coisas globais do app.

- `app_widget.dart`: MaterialApp, tema, rotas, providers globais.
- `router/`: navegação, rotas nomeadas, guards.
- `di/`: injeção de dependências (se usarmos).

---

#### `lib/core/`

Código reutilizável e "infra".

- `config/`: configurações (ex.: endpoints, env)
- `constants/`: constantes (strings, tamanhos, chaves)
- `errors/`: erros/padrões (AppException, etc.)
- `helpers/`: utilitários (formatadores, debouncers, etc.)
- `network/`: camada de rede (se houver além do Supabase)
- `theme/`: tema, cores, tipografia
- `widgets/`: widgets genéricos reutilizáveis (botões, loaders, etc.)

---

#### `lib/features/`

Aqui ficam as "partes" do produto separadas por domínio.

Exemplos para nosso MVP:

- `auth/`: login anônimo / magic link / sessão
- `party/`: criar party, listar membros, regras de acesso
- `invite/`: convite via link/QR, aceitar convite
- `plans/`: criar plano do grupo, ver "agora/depois"
- `location/`: enviar e ver localização em tempo real

> Regra: tudo que é específico de um módulo do produto vai em `features/`.

---

## 🧩 Padrão interno de cada Feature (como organizar por dentro)

Para manter consistente, cada feature pode ter:

```
features/<feature_name>/
  data/
    datasource/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    pages/
    widgets/
    controllers/
```

### Explicação rápida

- **data/**: conversa com Supabase/API e transforma dados.
- **domain/**: regras de negócio puras (sem Flutter, sem Supabase).
- **presentation/**: telas, widgets, controllers/state.

> Se o time preferir simplificar no começo, dá para começar com:
> `presentation/` + `data/` e só criar `domain/` quando fizer sentido.

---

## 🗺️ Onde codar o quê? (guia direto)

### Vou criar uma nova tela

➡️ `lib/features/<feature>/presentation/pages/`

### Vou criar um widget reutilizável só daquela feature

➡️ `lib/features/<feature>/presentation/widgets/`

### Vou criar um componente reutilizável no app inteiro

➡️ `lib/core/widgets/`

### Vou criar uma função utilitária (ex.: formatar distância/tempo)

➡️ `lib/core/helpers/`

### Vou buscar dados no Supabase

➡️ `lib/features/<feature>/data/datasource/`

### Vou criar um repositório que encapsula Supabase

➡️ `lib/features/<feature>/data/repositories/`

### Vou criar regras de negócio (ex.: validar entrada em party)

➡️ `lib/features/<feature>/domain/usecases/`

---

## 🔐 Supabase — como configurar sem vazar segredo

### Regra de ouro

**NUNCA** commitar URL/KEY diretamente no código se o repo for público.

Opções seguras:

- `--dart-define` (recomendado)
- `.env` (com pacote, mas garantir no `.gitignore`)

### Exemplo com `--dart-define`

Rodar assim:

```bash
flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

No código, ler com:

```dart
String.fromEnvironment('SUPABASE_URL')
```

> O time pode guardar isso num "setup interno" (ex.: mensagem fixada no grupo).

---

## 📡 MVP "durante o Carnaval": implicações técnicas (o que muda na prática)

Mesmo que a arquitetura base continue igual, este MVP força algumas prioridades:

### 1) Realtime de localização

- enviar updates com frequência controlada
- lidar com rede ruim (fila/retry)
- não fritar bateria

**Onde isso fica:**

- `features/location/data/datasource/` (envio/recebimento)
- `features/location/presentation/controllers/` (estado + permissões)

### 2) Realtime de planos

Planos mudam rápido. Ideal:

- atualizar e refletir em tempo real
- ter estado local consistente

**Onde isso fica:**

- `features/plans/data/` (CRUD + stream)
- `features/plans/presentation/`

### 3) Party como boundary de privacidade

Toda query deve ser **scoped** por `party_id` e por membership.
Isso deve estar claro nos repositórios de data.

---

## 🧪 Testes (padrão mínimo)

- Testes de regra de negócio: `test/<feature>_usecase_test.dart`
- Testes de widget: `test/<page>_widget_test.dart`

Rodar:

```bash
flutter test
```

---

## 🧑‍🤝‍🧑 Fluxo de trabalho em equipe (simples e funcional)

### Branches

- `main`: estável
- `dev`: integração
- `feature/<nome>`: features
- `fix/<nome>`: correções

### Commits

Mensagens claras:

- `feat: add party creation`
- `fix: handle location permission denied`
- `refactor: split plan repository`

---

## ✅ Checklist antes de abrir PR

- [ ] `flutter pub get`
- [ ] `flutter test`
- [ ] `flutter run` no Android pelo menos
- [ ] sem segredos commitados
- [ ] código dentro de `lib/` organizado

---

## ❓ Dúvidas comuns

### "Posso codar direto no `main.dart`?"

Não. `main.dart` deve ficar curto.
UI e regras vão para `app/`, `core/`, `features/`.

### "Eu coloco lógica de Supabase dentro da tela?"

Não. Tela chama controller/usecase, que chama repository/datasource.

### "O que eu faço se eu precisar mexer em permissão de localização?"

- Android: `android/app/src/main/AndroidManifest.xml`
- iOS: `ios/Runner/Info.plist` (somente mac)

---

## 📌 TL;DR — onde mexer

✅ Você vai mexer quase sempre em:

- `lib/`
- `test/`
- `pubspec.yaml`

⚠️ Você mexe às vezes em:

- `android/` e `ios/` (permissões/configs)

❌ Você não mexe / não commita:

- `build/`
- `.dart_tool/`
- `.idea/`

---

**Fim.** Se o time decidir qual padrão de state management usar (Riverpod, BLoC, etc.), este guia será adaptado com templates de features.
