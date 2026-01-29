# Deploy no Vercel (Flutter Web/PWA)

## Pré-requisitos
- Projeto Flutter configurado.
- Variáveis de ambiente definidas no Vercel:
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`

## Build local (web)
```bash
flutter pub get
flutter build web --web-renderer html --release \
  --dart-define=SUPABASE_URL="https://sua-url" \
  --dart-define=SUPABASE_ANON_KEY="sua-chave"
```

Para servir localmente o build:
```bash
python -m http.server --directory build/web 8080
```

## Deploy no Vercel
1. Crie um projeto no Vercel apontando para este repositório.
2. Configure as variáveis de ambiente (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) no painel do Vercel.
3. O build será executado via `scripts/vercel_build.sh` (configurado em `vercel.json`).
4. O output será servido de `build/web` com rewrite para SPA.

## Observações
- O renderer está fixado em HTML para reduzir peso inicial (CanvasKit é mais pesado).
- O `.env` não é carregado no Web. Use `--dart-define` ou as variáveis de ambiente do Vercel.
