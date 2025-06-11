DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO users (name, email) VALUES
('John Doe', 'john.remote@remote.com'),
('Jane Smith', 'jane_remote@remote.org'),
('Alice Johnson', 'alice_remote@remote.com'),
('Bob Lee', 'bob_remote@remote.net'),
('Eve Adams', 'eve_remote@remote.co');