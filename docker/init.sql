-- Activation de l'extension pgvector
CREATE EXTENSION IF NOT EXISTS vector;

-- Base de données de test (pour le CI et les tests d'intégration)
CREATE DATABASE ijeaf_test;
GRANT ALL PRIVILEGES ON DATABASE ijeaf_test TO ijeaf;
