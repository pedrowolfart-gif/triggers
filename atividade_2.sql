create table contas (
id serial primary key,
cliente varchar(150) not null,
saldo numeric (10, 2) not null default 0.00
);

create table movimentacoes (
id serial primary key,
conta_id int references contas(id),
tipo varchar (1) check (tipo in ('C', 'D')),
valor numeric (10, 2) not null,
data_movimentacao timestamp default current_timestamp
);

create or replace function fn_atualiza_saldo_conta()
returns trigger as $$
begin
	if NEW.tipo = 'C' THEN
		update contas set saldo = saldo + NEW.valor where id = NEW.conta_id;
	elsif NEW.tipo = 'D' THEN
		update contas set saldo = saldo - NEW.valor where id = NEW.conta_id;
	end if;
	return new;
end;
$$ language plpgsql;

create trigger trg_atualiza_saldo
after insert on movimentacoes
for each row
execute function fn_atualiza_saldo_conta();

INSERT INTO contas (cliente, saldo) VALUES ('João Silva', 500.00);

INSERT INTO movimentacoes (conta_id, tipo, valor) VALUES (1, 'D', 150.00);
SELECT * FROM contas WHERE id = 1;

SELECT * FROM movimentacoes WHERE conta_id = 1 ORDER BY id;