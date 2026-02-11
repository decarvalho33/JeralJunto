# Supabase Schema Snapshot (frontend-focused)

This document is based on the SQL outputs provided in the prompt. It focuses on what the frontend needs to know: schema map, tables/columns, relationships, views, functions/RPC, triggers, RLS/policies, and grants. Sections that could not be derived from the provided outputs are called out explicitly.

## Database Info

- db: postgres
- db_user: postgres
- postgres_version: PostgreSQL 17.6 on aarch64-unknown-linux-gnu, compiled by gcc (GCC) 13.2.0, 64-bit
- server_version: 17.6
- search_path: "$user", public, extensions

## Schemas

| schema | owner |
| --- | --- |
| auth | supabase_admin |
| extensions | postgres |
| graphql | supabase_admin |
| graphql_public | supabase_admin |
| pgbouncer | pgbouncer |
| public | pg_database_owner |
| realtime | supabase_admin |
| storage | supabase_admin |
| vault | supabase_admin |

## Public Schema (app data)

### Tables and Columns

#### public."Usuario"

| column | type | nullable | default | identity | generated | comment |
| --- | --- | --- | --- | --- | --- | --- |
| created_at | timestamp with time zone | false | now() |  |  |  |
| nome | text | true |  |  |  |  |
| email | text | true |  |  |  |  |
| idade | bigint | true |  |  |  |  |
| id | uuid | false | gen_random_uuid() |  |  |  |
| avatar_url | text | true |  |  |  |  |

Notes:
- The provided column export starts at ordinal_position 2 and skips ordinal_position 5. If there are additional columns in positions 1/5, they are not present in the source output.

#### public."Party"

| column | type | nullable | default | identity | generated | comment |
| --- | --- | --- | --- | --- | --- | --- |
| id | bigint | false |  | d |  |  |
| created_at | timestamp with time zone | false | now() |  |  |  |
| nome | text | true |  |  |  |  |
| idCriador | uuid | false |  |  |  |  |

#### public."Party_Usuario"

| column | type | nullable | default | identity | generated | comment |
| --- | --- | --- | --- | --- | --- | --- |
| id | bigint | false |  | d |  |  |
| created_at | timestamp with time zone | false | now() |  |  |  |
| idParty | bigint | true |  |  |  |  |
| idUsuario | uuid | true |  |  |  |  |

#### public."Bloco"

| column | type | nullable | default | identity | generated | comment |
| --- | --- | --- | --- | --- | --- | --- |
| id | bigint | false |  | d |  |  |
| created_at | timestamp with time zone | false | now() |  |  |  |
| nome | text | true |  |  |  |  |
| cidade | text | true |  |  |  |  |
| bairro | text | true |  |  |  |  |
| rua | text | true |  |  |  |  |
| horaInicio | timestamp without time zone | true |  |  |  |  |
| horaTermino | timestamp without time zone | true |  |  |  |  |

Notes:
- The provided column export skips ordinal_position 7. If there is a column in that position, it is not present in the source output.

#### public."Party_Bloco"

| column | type | nullable | default | identity | generated | comment |
| --- | --- | --- | --- | --- | --- | --- |
| id | bigint | false |  | d |  |  |
| created_at | timestamp with time zone | false | now() |  |  |  |
| idParty | bigint | true |  |  |  |  |
| idBloco | bigint | true |  |  |  |  |

#### public."Localizacao"

| column | type | nullable | default | identity | generated | comment |
| --- | --- | --- | --- | --- | --- | --- |
| id | bigint | false |  | d |  |  |
| created_at | timestamp with time zone | false | now() |  |  |  |
| idUsuario | uuid | true |  |  |  |  |
| ultimaAtt | timestamp with time zone | true | now() |  |  |  |
| posicao | geography | true |  |  |  |  |
| saudeBateria | bigint | true |  |  |  |  |

Notes:
- The provided column export skips ordinal_position 4 and 5. If there are additional columns in those positions, they are not present in the source output.

#### public.spatial_ref_sys

PostGIS system table. Columns are: srid, auth_name, auth_srid, srtext, proj4text.

### Relationships (Foreign Keys)

| from | to | on delete |
| --- | --- | --- |
| public."Usuario".id | auth.users.id | CASCADE |
| public."Party"."idCriador" | public."Usuario".id | (no action) |
| public."Party_Usuario"."idParty" | public."Party".id | CASCADE |
| public."Party_Usuario"."idUsuario" | public."Usuario".id | CASCADE |
| public."Party_Bloco"."idParty" | public."Party".id | CASCADE |
| public."Party_Bloco"."idBloco" | public."Bloco".id | CASCADE |
| public."Localizacao"."idUsuario" | public."Usuario".id | CASCADE |

Text diagram (public schema):

```
auth.users
  └─ public.Usuario (id)
       ├─ public.Party (idCriador)
       │    ├─ public.Party_Usuario (idParty, idUsuario)
       │    └─ public.Party_Bloco (idParty, idBloco)
       └─ public.Localizacao (idUsuario)
```

### Constraints (public)

| table | constraint | type | definition |
| --- | --- | --- | --- |
| public."Bloco" | Bloco_pkey | PRIMARY KEY | PRIMARY KEY (id) |
| public."Localizacao" | Localizacao_pkey | PRIMARY KEY | PRIMARY KEY (id) |
| public."Party" | Party_pkey | PRIMARY KEY | PRIMARY KEY (id) |
| public."Party_Bloco" | Party_Bloco_pkey | PRIMARY KEY | PRIMARY KEY (id) |
| public."Party_Bloco" | party_bloco_unique | UNIQUE | UNIQUE ("idParty", "idBloco") |
| public."Party_Usuario" | Party_Usuario_pkey | PRIMARY KEY | PRIMARY KEY (id) |
| public."Party_Usuario" | party_usuario_unique | UNIQUE | UNIQUE ("idParty", "idUsuario") |
| public."Usuario" | Usuario_pkey | PRIMARY KEY | PRIMARY KEY (id) |
| public.spatial_ref_sys | spatial_ref_sys_pkey | PRIMARY KEY | PRIMARY KEY (srid) |
| public.spatial_ref_sys | spatial_ref_sys_srid_check | CHECK | CHECK (srid > 0 AND srid <= 998999) |

### Indexes (public)

| table | index | unique | primary |
| --- | --- | --- | --- |
| public."Bloco" | "Bloco_pkey" | true | true |
| public."Localizacao" | "Localizacao_pkey" | true | true |
| public."Party" | "Party_pkey" | true | true |
| public."Party_Bloco" | "Party_Bloco_pkey" | true | true |
| public."Party_Bloco" | party_bloco_unique | true | false |
| public."Party_Usuario" | "Party_Usuario_pkey" | true | true |
| public."Party_Usuario" | party_usuario_unique | true | false |
| public."Usuario" | "Usuario_pkey" | true | true |
| public.spatial_ref_sys | spatial_ref_sys_pkey | true | true |

### RLS Status (public)

| table | rls_enabled | rls_forced |
| --- | --- | --- |
| public."Bloco" | true | false |
| public."Localizacao" | true | false |
| public."Party" | false | false |
| public."Party_Bloco" | false | false |
| public."Party_Usuario" | false | false |
| public."Usuario" | false | false |
| public.spatial_ref_sys | false | false |

Important: policies only apply when RLS is enabled. The tables Party, Party_Bloco, Party_Usuario, and Usuario currently have RLS disabled, so the policies listed for them will not be enforced until RLS is turned on.

### Policies (public)

| table | policy | command | roles | using | with_check |
| --- | --- | --- | --- | --- | --- |
| public."Bloco" | Permitir inserção para usuários logados | INSERT | public |  | (auth.uid() IS NOT NULL) |
| public."Bloco" | Permitir leitura para todos | SELECT | public | true |  |
| public."Bloco" | bloco_insert_authenticated | INSERT | public |  | (auth.uid() IS NOT NULL) |
| public."Localizacao" | Membros da Party veem localização | SELECT | public | (EXISTS ( SELECT 1 FROM ("Party_Usuario" pu1 JOIN "Party_Usuario" pu2 ON ((pu1."idParty" = pu2."idParty"))) WHERE ((pu1."idUsuario" = auth.uid()) AND (pu2."idUsuario" = "Localizacao"."idUsuario")))) |  |
| public."Localizacao" | Usuários podem apagar seu rastro | DELETE | public | (auth.uid() = "idUsuario") |  |
| public."Party" | party_insert_authenticated | INSERT | public |  | (auth.uid() IS NOT NULL) |
| public."Party" | party_select_if_member | SELECT | public | (id IN ( SELECT "Party_Usuario"."idParty" FROM "Party_Usuario" WHERE ("Party_Usuario"."idUsuario" = auth.uid()))) |  |
| public."Party_Bloco" | Apenas admin gerencia o cronograma | INSERT | public |  | (auth.uid() = ( SELECT "Party"."idCriador" FROM "Party" WHERE ("Party".id = "Party_Bloco"."idParty"))) |
| public."Party_Bloco" | party_bloco_delete_if_member | DELETE | public | is_party_member("idParty") |  |
| public."Party_Bloco" | party_bloco_insert_if_member | INSERT | public |  | is_party_member("idParty") |
| public."Party_Bloco" | party_bloco_select_if_member | SELECT | public | is_party_member("idParty") |  |
| public."Party_Usuario" | Usuários podem sair da party | DELETE | public | (auth.uid() = "idUsuario") |  |
| public."Party_Usuario" | party_usuario_delete_self | DELETE | public | ("idUsuario" = auth.uid()) |  |
| public."Party_Usuario" | party_usuario_insert_self | INSERT | public |  | ((auth.uid() IS NOT NULL) AND ("idUsuario" = auth.uid())) |
| public."Party_Usuario" | party_usuario_select_if_member | SELECT | public | is_party_member("idParty") |  |
| public."Party_Usuario" | permit_select_own_membership | SELECT | public | (auth.uid() = "idUsuario") |  |
| public."Party_Usuario" | usuario_le_proprios_registros | SELECT | public | (auth.uid() = "idUsuario") |  |
| public."Usuario" | usuario_insert_own | INSERT | authenticated |  | (id = auth.uid()) |
| public."Usuario" | usuario_select_own | SELECT | public | (id = auth.uid()) |  |
| public."Usuario" | usuario_update_own | UPDATE | public | (id = auth.uid()) | (id = auth.uid()) |

Notes:
- There are duplicate policies for some actions (e.g., Bloco insert; Party_Usuario select/delete). Consider consolidating if you enable RLS.
- Localizacao has SELECT and DELETE policies only; INSERT/UPDATE would be blocked under RLS unless handled via service_role or new policies.

### Public schema sequences (grants)

| sequence | grantee | privileges |
| --- | --- | --- |
| public.Bloco_id_seq | anon | USAGE |
| public.Bloco_id_seq | authenticated | USAGE |
| public.Bloco_id_seq | service_role | USAGE |
| public.Localizacao_id_seq | anon | USAGE |
| public.Localizacao_id_seq | authenticated | USAGE |
| public.Localizacao_id_seq | service_role | USAGE |
| public.Party_id_seq | anon | USAGE |
| public.Party_id_seq | authenticated | USAGE |
| public.Party_id_seq | service_role | USAGE |
| public.Party_Bloco_id_seq | anon | USAGE |
| public.Party_Bloco_id_seq | authenticated | USAGE |
| public.Party_Bloco_id_seq | service_role | USAGE |
| public.Party_Usuario_id_seq | anon | USAGE |
| public.Party_Usuario_id_seq | authenticated | USAGE |
| public.Party_Usuario_id_seq | service_role | USAGE |

### Public functions (RPC) - app-specific

| function | signature | return | volatility | security_definer | owner | grants (EXECUTE) |
| --- | --- | --- | --- | --- | --- | --- |
| create_party | (p_nome text) | "Party" | v | false | postgres | anon, authenticated, service_role |
| join_party | (p_party_id bigint) | void | v | false | postgres | anon, authenticated, service_role |
| leave_party | (p_party_id bigint) | void | v | false | postgres | anon, authenticated, service_role |
| attach_bloco | (p_party_id bigint, p_bloco_id bigint) | void | v | false | postgres | anon, authenticated, service_role |
| detach_bloco | (p_party_id bigint, p_bloco_id bigint) | void | v | false | postgres | anon, authenticated, service_role |
| create_bloco_and_attach | (p_party_id bigint, p_nome text, p_cidade text, p_bairro text, p_rua text, p_hora_inicio timestamp with time zone, p_hora_termino timestamp with time zone) | "Bloco" | v | false | postgres | anon, authenticated, service_role |
| is_party_member | (p_party_id bigint) | boolean | s | false | postgres | anon, authenticated, service_role |
| handle_new_user | () | trigger | v | true | postgres | anon, authenticated, service_role |

Notes:
- These functions are callable by anon/authenticated/service_role based on routine grants.
- No function definitions were provided in the 12.2 output, so only metadata is included here.

## Supabase/System Schemas (summary)

### auth

Tables (RLS enabled): audit_log_entries, flow_state, identities, instances, mfa_amr_claims, mfa_challenges, mfa_factors, one_time_tokens, refresh_tokens, saml_providers, saml_relay_states, schema_migrations, sessions, sso_domains, sso_providers, users.
Tables (RLS disabled): oauth_authorizations, oauth_client_states, oauth_clients, oauth_consents.

Key FKs:
- auth.identities.user_id -> auth.users.id (CASCADE)
- auth.mfa_factors.user_id -> auth.users.id (CASCADE)
- auth.sessions.user_id -> auth.users.id (CASCADE)
- auth.refresh_tokens.session_id -> auth.sessions.id (CASCADE)
- auth.oauth_authorizations.client_id -> auth.oauth_clients.id (CASCADE)
- auth.oauth_authorizations.user_id -> auth.users.id (CASCADE)
- auth.oauth_consents.client_id -> auth.oauth_clients.id (CASCADE)
- auth.oauth_consents.user_id -> auth.users.id (CASCADE)
- auth.one_time_tokens.user_id -> auth.users.id (CASCADE)
- auth.saml_providers.sso_provider_id -> auth.sso_providers.id (CASCADE)
- auth.saml_relay_states.sso_provider_id -> auth.sso_providers.id (CASCADE)
- auth.saml_relay_states.flow_state_id -> auth.flow_state.id (CASCADE)
- auth.sso_domains.sso_provider_id -> auth.sso_providers.id (CASCADE)

### storage

Tables (RLS enabled): buckets, buckets_analytics, buckets_vectors, migrations, objects, prefixes, s3_multipart_uploads, s3_multipart_uploads_parts, vector_indexes.

Key FKs:
- storage.objects.bucket_id -> storage.buckets.id
- storage.prefixes.bucket_id -> storage.buckets.id
- storage.s3_multipart_uploads.bucket_id -> storage.buckets.id
- storage.s3_multipart_uploads_parts.bucket_id -> storage.buckets.id
- storage.s3_multipart_uploads_parts.upload_id -> storage.s3_multipart_uploads.id (CASCADE)
- storage.vector_indexes.bucket_id -> storage.buckets_vectors.id

Policies (storage.objects):
- avatars bucket: authenticated users can SELECT all, and INSERT/UPDATE/DELETE within their own folder (`split_part(name, '/', 1) = auth.uid()`)

### realtime

Tables: messages (RLS enabled), schema_migrations (RLS disabled), subscription (RLS disabled).

### vault

Tables: secrets (RLS disabled). View: decrypted_secrets.

## Views

- extensions.pg_stat_statements
- extensions.pg_stat_statements_info
- public.geography_columns (PostGIS metadata view)
- public.geometry_columns (PostGIS metadata view)
- vault.decrypted_secrets

## Triggers

| table | trigger | definition |
| --- | --- | --- |
| auth.users | on_auth_user_created | CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION handle_new_user() |
| realtime.subscription | tr_check_filters | CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters() |
| storage.buckets | enforce_bucket_name_length_trigger | CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length() |
| storage.objects | objects_delete_delete_prefix | CREATE TRIGGER objects_delete_delete_prefix AFTER DELETE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger() |
| storage.objects | objects_insert_create_prefix | CREATE TRIGGER objects_insert_create_prefix BEFORE INSERT ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.objects_insert_prefix_trigger() |
| storage.objects | objects_update_create_prefix | CREATE TRIGGER objects_update_create_prefix BEFORE UPDATE ON storage.objects FOR EACH ROW WHEN (new.name <> old.name OR new.bucket_id <> old.bucket_id) EXECUTE FUNCTION storage.objects_update_prefix_trigger() |
| storage.objects | update_objects_updated_at | CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column() |
| storage.prefixes | prefixes_create_hierarchy | CREATE TRIGGER prefixes_create_hierarchy BEFORE INSERT ON storage.prefixes FOR EACH ROW WHEN (pg_trigger_depth() < 1) EXECUTE FUNCTION storage.prefixes_insert_trigger() |
| storage.prefixes | prefixes_delete_hierarchy | CREATE TRIGGER prefixes_delete_hierarchy AFTER DELETE ON storage.prefixes FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger() |

## Types and Enums (selected)

Enums from provided output:

| schema | enum | values |
| --- | --- | --- |
| auth | aal_level | aal1, aal2, aal3 |
| auth | code_challenge_method | s256, plain |
| auth | factor_status | unverified, verified |
| auth | factor_type | totp, webauthn, phone |
| auth | oauth_authorization_status | pending, approved, denied, expired |
| auth | oauth_client_type | public, confidential |
| auth | oauth_registration_type | dynamic, manual |
| auth | oauth_response_type | code |
| auth | one_time_token_type | confirmation_token, reauthentication_token, recovery_token, email_change_token_new, email_change_token_current, phone_change_token |
| realtime | action | INSERT, UPDATE, DELETE, TRUNCATE, ERROR |
| realtime | equality_op | eq, neq, lt, lte, gt, gte, in |
| storage | buckettype | STANDARD, ANALYTICS, VECTOR |

Composite types were also listed for most tables and views in auth/public/realtime/storage/vault; see the SQL output if needed.

## Missing From Provided Outputs

The following sections could not be fully documented because the corresponding query results were not included in the prompt:

- Table comments (04)
- Table/view grants (09.1)
- Function definitions (12.2)
- Materialized views (11)
- Extensions list (15)
- Realtime publications (16)
- Roles and memberships (17)

If you can provide those outputs, I can extend this document without guessing.
 