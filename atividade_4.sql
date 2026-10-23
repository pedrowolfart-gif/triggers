CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE clientes_deletados_log (
    id SERIAL PRIMARY KEY,
    cliente_id INT,
    nome VARCHAR(100),
    email VARCHAR(100),
    data_remocao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION fn_soft_delete_cliente()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO clientes_deletados_log (cliente_id, nome, email)
    VALUES (OLD.id, OLD.nome, OLD.email);

    UPDATE clientes SET ativo = FALSE WHERE id = OLD.id;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_soft_delete_cliente
BEFORE DELETE ON clientes
FOR EACH ROW
EXECUTE FUNCTION fn_soft_delete_cliente();

INSERT INTO clientes (nome, email) VALUES 
('Arthur Melzi', 'arthur@email.com'),
('Carla Souza', 'carla@email.com'),
('Pedro Lima', 'pedro@email.com');

SELECT * FROM clientes ORDER BY id;
DELETE FROM clientes WHERE id = 1;
SELECT * FROM clientes ORDER BY id;
SELECT * FROM clientes_deletados_log ORDER BY id;
DELETE FROM clientes WHERE id IN (2, 3);
SELECT * FROM clientes ORDER BY id;
SELECT * FROM clientes_deletados_log ORDER BY id;
DELETE FROM clientes WHERE id = 999;

DELETE FROM clientes WHERE id = 1;
SELECT cliente_id, COUNT(*) AS qtd_logs
FROM clientes_deletados_log
GROUP BY cliente_id
ORDER BY cliente_id;

SELECT * FROM clientes WHERE ativo = TRUE;

SELECT c.id, c.nome, c.email, c.ativo, l.data_remocao
FROM clientes c
JOIN clientes_deletados_log l ON l.cliente_id = c.id
ORDER BY l.data_remocao;