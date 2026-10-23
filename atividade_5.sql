CREATE TABLE reservas (
    id SERIAL PRIMARY KEY,
    numero_quarto INT NOT NULL,
    data_checkin DATE NOT NULL,
    data_checkout DATE NOT NULL,
    valor_diaria NUMERIC(10, 2) NOT NULL,
    valor_total NUMERIC(10, 2)
);

CREATE OR REPLACE FUNCTION fn_processa_reserva()
RETURNS TRIGGER AS $$
DECLARE
    dias_estadia INT;
BEGIN

    IF NEW.data_checkout <= NEW.data_checkin THEN
        RAISE EXCEPTION 'A data de check-out (%) precisa ser posterior à data de check-in (%)!', 
            NEW.data_checkout, NEW.data_checkin;
    END IF;


    dias_estadia := NEW.data_checkout - NEW.data_checkin;

    NEW.valor_total := dias_estadia * NEW.valor_diaria;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_processa_reserva
BEFORE INSERT OR UPDATE ON reservas
FOR EACH ROW
EXECUTE FUNCTION fn_processa_reserva();

INSERT INTO reservas (numero_quarto, data_checkin, data_checkout, valor_diaria)
VALUES (101, '2026-11-01', '2026-11-06', 200.00),
 (102, '2026-12-24', '2026-12-25', 350.00),
 (103, '2026-12-28', '2027-01-03', 190.00),
 (104, '2026-11-10', '2026-11-13', 200.00);

SELECT * FROM reservas ORDER BY id;

UPDATE reservas
SET data_checkout = '2026-11-08'
WHERE id = 1;

UPDATE reservas
SET valor_diaria = 250.00
WHERE id = 1;

UPDATE reservas
SET data_checkout = '2026-10-30'
WHERE id = 1;

UPDATE reservas
SET valor_total = 1.00
WHERE id = 1;

SELECT
    id,
    numero_quarto,
    data_checkin,
    data_checkout,
    (data_checkout - data_checkin) AS diarias,
    valor_diaria,
    valor_total
FROM reservas
ORDER BY id;