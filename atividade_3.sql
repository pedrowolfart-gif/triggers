CREATE TABLE funcionarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    salario NUMERIC(10, 2) NOT NULL
);

CREATE TABLE historico_carreira (
    id SERIAL PRIMARY KEY,
    funcionario_id INT NOT NULL,
    cargo_antigo VARCHAR(50),
    cargo_novo VARCHAR(50),
    salario_antigo NUMERIC(10, 2),
    salario_novo NUMERIC(10, 2),
    data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION fn_log_alteracao_carreira()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.cargo IS DISTINCT FROM NEW.cargo OR OLD.salario IS DISTINCT FROM NEW.salario THEN
        INSERT INTO historico_carreira (funcionario_id, cargo_antigo, cargo_novo, salario_antigo, salario_novo)
        VALUES (OLD.id, OLD.cargo, NEW.cargo, OLD.salario, NEW.salario);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_carreira
AFTER UPDATE ON funcionarios
FOR EACH ROW
EXECUTE FUNCTION fn_log_alteracao_carreira()

INSERT INTO funcionarios (nome, cargo, salario) VALUES ('Maria Santos', 'Desenvolvedora Jr', 3500.00);

INSERT INTO funcionarios (nome, cargo, salario) VALUES ('João Silva', 'Analista de RH', 4200.00);

UPDATE funcionarios
SET cargo = 'Desenvolvedora Pleno', salario = 5500.00
WHERE id = 1;

UPDATE funcionarios
SET salario = 4800.00
WHERE id = 2;

UPDATE funcionarios
SET cargo = 'Analista de RH Sênior'
WHERE id = 2;

UPDATE funcionarios
SET nome = 'Maria Santos Oliveira'
WHERE id = 1;

UPDATE funcionarios
SET salario = 5500.00
WHERE id = 1

SELECT * FROM historico_carreira ORDER BY id;

SELECT
    h.id,
    f.nome,
    h.cargo_antigo,
    h.cargo_novo,
    h.salario_antigo,
    h.salario_novo,
    h.salario_novo - h.salario_antigo AS variacao_salario,
    h.data_alteracao
FROM historico_carreira h
JOIN funcionarios f ON f.id = h.funcionario_id
ORDER BY h.data_alteracao;