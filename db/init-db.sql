-- Init DB: create produtos table and insert sample rows
CREATE TABLE IF NOT EXISTS produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(80),
    preco NUMERIC(10,2)
);

INSERT INTO produtos (nome, preco) VALUES
('Caneta', 3.50),
('Caderno', 12.90),
('Mochila', 89.90)
ON CONFLICT DO NOTHING;
