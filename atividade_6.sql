create table pedidos(
id serial primary key,
cliente varchar (100) not null,
valor_total numeric(10, 2) not null default 0.00,
data_criacao timestamp default current_timestamp
);

create table itens_pedidos(
id serial primary key,
produto_id int references pedidos(id) on delete cascade,
produto_nome varchar (100) not null,
quantidade int not null,
preco_unidade numeric (10, 2) not null
);

create or replace function fn_recalculo_total_pedidos()
returns trigger as $$
declare
	v_pedido_id int;
begin
	if(tg_op = 'delete') then
		v_pedido_id :=old.pedido_id;
	else
		v_pedido_id := new.pedido_id;
	end if;

update pedidos
set valor_total = coalesce ((
	select sum (quantidade * preco_unidade)
	from itens_pedido
	
), 0.00)
where pedido_id = v_pedido_id;

if (tg_op 'delete') then
	return old;
end if;
return new;
end;
$$ language plpgsql;

