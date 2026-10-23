create table pedidos(
    id serial primary key,
    cliente varchar(100) not null,
    valor_total numeric(10, 2) not null default 0.00,
    data_criacao timestamp default current_timestamp
);

create table itens_pedidos(
    id serial primary key,
    pedido_id int references pedidos(id) on delete cascade,
    produto_nome varchar(100) not null,
    quantidade int not null,
    preco_unidade numeric(10, 2) not null
);

create or replace function fn_recalculo_total_pedidos()
returns trigger as $$
declare
    v_pedido_id int;
begin
    if (tg_op = 'DELETE') then
        v_pedido_id := old.pedido_id;
    else
        v_pedido_id := new.pedido_id;
    end if;

    update pedidos
    set valor_total = coalesce((
        select sum(quantidade * preco_unidade)
        from itens_pedidos
        where pedido_id = v_pedido_id
    ), 0.00)
    where id = v_pedido_id;

    if (tg_op = 'DELETE') then
        return old;
    end if;
    return new;
end;
$$ language plpgsql;

create trigger trg_atualiza_total_pedido
after insert or update or delete on itens_pedidos
for each row
execute function fn_recalculo_total_pedidos();


insert into pedidos (cliente) values ('Ana Souza'), ('Bruno Lima');
select * from pedidos order by id;   

insert into itens_pedidos (pedido_id, produto_nome, quantidade, preco_unidade) values (1, 'Mouse Gamer', 2, 150.00);
insert into itens_pedidos (pedido_id, produto_nome, quantidade, preco_unidade) values (1, 'Mousepad', 1, 50.00);
select * from pedidos order by id;   
update itens_pedidos set quantidade = 3 where id = 1;
select * from pedidos order by id;   
delete from itens_pedidos where id = 2;
select * from pedidos order by id;   
