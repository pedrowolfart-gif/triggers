create table clientes (
id serial primary key,
nome varchar (150) not null,
total_compras numeric (10, 2) default 0.00
);

create table pedidos (
id serial primary key,
nome varchar (150) not null,
cliente_id int not null,
valor_total numeric (10, 2) not null,
data_pedido timestamp default current_timestamp,

foreign key (cliente_id) references clientes(id)
);

create or replace function fn_atualizar_total_cliente()
returns trigger as $$
declare
	v_cliente_id int;
	begin
	if(tg_op = 'delete') then
		v_cliente_id := old.cliente_id;
	else 
		v_cliente_id := new.cliente_id;
	end if;

update clientes 
set total_compras = coalesce ((
	select sum (valor_total)
	from pedidos
	where cliente_id = v_cliente_id
), 0.00)
where id = v_cliente_id;

if (tg_op = 'update' and old.cliente_id is distinct from new.cliente_id) then
	update clientes
	set total_compras = coalesce ((
		select sum (valor_total)
		from pedidos
		where cliente_id = old.cliente_id
	), 0.00)
	where id = old.cliente_id;
end if;

return null;
end;
$$ language plpgsql;

create trigger trg_atualiza_total_pedidos
after insert or delete on pedidos 
for each row
execute function fn_atualizar_total_cliente()

insert into clientes (nome) values 
('pedro'),
('ana');

insert into pedidos (cliente_id, valor_total) values 
(1, 150.00)