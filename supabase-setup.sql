-- Administradores já configurados: joaovictorfelaco@gmail.com e matheusflp.work@gmail.com
-- Cole tudo no SQL Editor do Supabase e clique em Run.

create table if not exists public.cars (
  id bigint generated always as identity primary key,
  m text not null, n text not null, y int not null, km text not null, p int not null,
  mot numeric not null, cb text not null, car text not null, cor text not null default '',
  cons numeric, d boolean not null default false, laudo boolean not null default false,
  hide boolean not null default false, fotos text[] not null default '{}', pos int not null default 0,
  created_at timestamptz not null default now()
);
create table if not exists public.config (
  id int primary key default 1 check (id = 1),
  wa text not null default '', instagram text not null default '', facebook text not null default '',
  ent numeric not null default 30, parcelas int not null default 48, taxa numeric not null default 2
);
insert into public.config (id) values (1) on conflict do nothing;

alter table public.cars enable row level security;
alter table public.config enable row level security;

-- Visitantes só leem carros não ocultos e a configuração
create policy "site le carros visiveis" on public.cars for select to anon, authenticated using (hide = false);
create policy "site le config" on public.config for select to anon, authenticated using (true);
-- Só o administrador altera
create policy "admin carros" on public.cars for all to authenticated
  using ((auth.jwt() ->> 'email') in ('joaovictorfelaco@gmail.com','matheusflp.work@gmail.com')) with check ((auth.jwt() ->> 'email') in ('joaovictorfelaco@gmail.com','matheusflp.work@gmail.com'));
create policy "admin config" on public.config for all to authenticated
  using ((auth.jwt() ->> 'email') in ('joaovictorfelaco@gmail.com','matheusflp.work@gmail.com')) with check ((auth.jwt() ->> 'email') in ('joaovictorfelaco@gmail.com','matheusflp.work@gmail.com'));

-- Fotos
insert into storage.buckets (id, name, public) values ('fotos', 'fotos', true) on conflict (id) do nothing;
create policy "fotos publicas" on storage.objects for select to anon, authenticated using (bucket_id = 'fotos');
create policy "admin envia fotos" on storage.objects for insert to authenticated
  with check (bucket_id = 'fotos' and (auth.jwt() ->> 'email') in ('joaovictorfelaco@gmail.com','matheusflp.work@gmail.com'));
create policy "admin troca fotos" on storage.objects for update to authenticated
  using (bucket_id = 'fotos' and (auth.jwt() ->> 'email') in ('joaovictorfelaco@gmail.com','matheusflp.work@gmail.com'));
create policy "admin apaga fotos" on storage.objects for delete to authenticated
  using (bucket_id = 'fotos' and (auth.jwt() ->> 'email') in ('joaovictorfelaco@gmail.com','matheusflp.work@gmail.com'));
