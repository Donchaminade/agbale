-- Création de la base de données
CREATE DATABASE IF NOT EXISTS agbale_api
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_general_ci;

USE agbale_api;

-- ==========================
-- Table : utilisateurs
-- ==========================
CREATE TABLE utilisateurs (
    id_utilisateur INT AUTO_INCREMENT PRIMARY KEY,
    nom_complet VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    mot_de_passe VARCHAR(255) NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================
-- Table : contacts
-- ==========================
CREATE TABLE contacts (
    id_contact INT AUTO_INCREMENT PRIMARY KEY,
    id_utilisateur INT NOT NULL,
    nom_contact VARCHAR(150) NOT NULL,
    numero VARCHAR(20),
    email VARCHAR(150),
    note_importance ENUM('faible','moyenne','élevée') DEFAULT 'moyenne',
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_utilisateur) REFERENCES utilisateurs(id_utilisateur) ON DELETE CASCADE
);

-- ==========================
-- Table : social_medias
-- ==========================
CREATE TABLE social_medias (
    id_social INT AUTO_INCREMENT PRIMARY KEY,
    id_contact INT NOT NULL,
    plateforme VARCHAR(50) NOT NULL, -- ex: Facebook, LinkedIn, WhatsApp
    lien VARCHAR(255) NOT NULL,
    FOREIGN KEY (id_contact) REFERENCES contacts(id_contact) ON DELETE CASCADE
);

-- ==========================
-- Table : notes_todos
-- ==========================
CREATE TABLE notes_todos (
    id_note INT AUTO_INCREMENT PRIMARY KEY,
    id_utilisateur INT NOT NULL,
    titre VARCHAR(150) NOT NULL,
    contenu TEXT,
    type ENUM('note','todo') DEFAULT 'note',
    statut ENUM('en_attente','en_cours','terminé') DEFAULT 'en_attente',
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_echeance DATE NULL,
    FOREIGN KEY (id_utilisateur) REFERENCES utilisateurs(id_utilisateur) ON DELETE CASCADE
);

