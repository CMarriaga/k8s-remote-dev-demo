DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO users (name, email) VALUES
('John Doe', 'john.local@example.com'),
('Jane Smith', 'jane_local@example.org'),
('Alice Johnson', 'alice_local@example.com'),
('Bob Lee', 'bob.local123@example.net'),
('Eve Adams', 'eve-local@example.co');