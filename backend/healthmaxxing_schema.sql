-- ============================================================
-- HealthMaxxing — AC-02 Personalized Health & Workout Planner
-- Database schema (MySQL 8.0+)
-- Generated from finalized ERD
-- ============================================================

CREATE DATABASE IF NOT EXISTS healthmaxxing
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE healthmaxxing;

-- ------------------------------------------------------------
-- 1. USERS & ROLES
-- ------------------------------------------------------------

CREATE TABLE users (
    user_id         INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(150) NOT NULL,
    email           VARCHAR(150) NOT NULL,
    username        VARCHAR(50)  NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,
    `role`           ENUM('klien', 'pt') NOT NULL,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uq_users_email (email),
    UNIQUE KEY uq_users_username (username)
) ENGINE=InnoDB;

CREATE TABLE client_profiles (
    client_id       INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT NOT NULL,
    assigned_pt_id  INT NULL,
    birth_date      DATE NULL,
    gender          ENUM('male', 'female') NULL,
    height_cm       DECIMAL(5,2) NULL,
    weight_current  DECIMAL(5,2) NULL,
    weight_target   DECIMAL(5,2) NULL,
    allergies       TEXT NULL,
    activity_level  ENUM('sedentary', 'light', 'moderate', 'active', 'very_active') NULL,
    `status`         ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uq_client_profiles_user (user_id),
    KEY idx_client_profiles_pt (assigned_pt_id),

    CONSTRAINT fk_client_profiles_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_client_profiles_pt
        FOREIGN KEY (assigned_pt_id) REFERENCES users(user_id)
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 2. DATA MASTER
-- ------------------------------------------------------------

CREATE TABLE exercise_reference (
    exercise_id       INT AUTO_INCREMENT PRIMARY KEY,
    name              VARCHAR(150) NOT NULL,
    category          VARCHAR(100) NULL,
    calories_per_unit DECIMAL(6,2) NULL
) ENGINE=InnoDB;

CREATE TABLE food_reference (
    food_id     INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(150) NOT NULL,
    calories    INT NULL,
    protein_g   DECIMAL(6,2) NULL,
    carbs_g     DECIMAL(6,2) NULL,
    fat_g       DECIMAL(6,2) NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 3a. WORKOUT & MEAL PLANS (generated weekly, reviewed by PT)
-- ------------------------------------------------------------

CREATE TABLE workout_plans (
    plan_id         INT AUTO_INCREMENT PRIMARY KEY,
    client_id       INT NOT NULL,
    week_start_date DATE NOT NULL,
    `status`         ENUM('pending', 'approved', 'overridden') NOT NULL DEFAULT 'pending',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    KEY idx_workout_plans_client_week (client_id, week_start_date),

    CONSTRAINT fk_workout_plans_client
        FOREIGN KEY (client_id) REFERENCES client_profiles(client_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE workout_plan_items (
    item_id       INT AUTO_INCREMENT PRIMARY KEY,
    plan_id       INT NOT NULL,
    exercise_id   INT NOT NULL,
    day_of_week   ENUM('mon','tue','wed','thu','fri','sat','sun') NOT NULL,
    `sets`        INT NULL,
    reps          INT NULL,
    is_completed  BOOLEAN NOT NULL DEFAULT FALSE,

    KEY idx_workout_items_plan (plan_id),

    CONSTRAINT fk_workout_items_plan
        FOREIGN KEY (plan_id) REFERENCES workout_plans(plan_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_workout_items_exercise
        FOREIGN KEY (exercise_id) REFERENCES exercise_reference(exercise_id)
) ENGINE=InnoDB;

CREATE TABLE meal_plans (
    plan_id         INT AUTO_INCREMENT PRIMARY KEY,
    client_id       INT NOT NULL,
    week_start_date DATE NOT NULL,
    `status`         ENUM('pending', 'approved', 'overridden') NOT NULL DEFAULT 'pending',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    KEY idx_meal_plans_client_week (client_id, week_start_date),

    CONSTRAINT fk_meal_plans_client
        FOREIGN KEY (client_id) REFERENCES client_profiles(client_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE meal_plan_items (
    item_id       INT AUTO_INCREMENT PRIMARY KEY,
    plan_id       INT NOT NULL,
    food_id       INT NOT NULL,
    meal_type     ENUM('breakfast', 'lunch', 'dinner', 'snack') NOT NULL,
    is_completed  BOOLEAN NOT NULL DEFAULT FALSE,

    KEY idx_meal_items_plan (plan_id),

    CONSTRAINT fk_meal_items_plan
        FOREIGN KEY (plan_id) REFERENCES meal_plans(plan_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_meal_items_food
        FOREIGN KEY (food_id) REFERENCES food_reference(food_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 3b. TRANSAKSI / LOG HARIAN
-- ------------------------------------------------------------

CREATE TABLE daily_logs (
    log_id           INT AUTO_INCREMENT PRIMARY KEY,
    client_id        INT NOT NULL,
    log_date         DATE NOT NULL,
    weight_kg        DECIMAL(5,2) NULL,
    steps            INT NOT NULL DEFAULT 0,
    water_liters     DECIMAL(4,2) NOT NULL DEFAULT 0,
    calories_burned  INT NOT NULL DEFAULT 0,
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uq_daily_logs_client_date (client_id, log_date),

    CONSTRAINT fk_daily_logs_client
        FOREIGN KEY (client_id) REFERENCES client_profiles(client_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE targets (
    target_id           INT AUTO_INCREMENT PRIMARY KEY,
    client_id           INT NOT NULL,
    week_start_date     DATE NOT NULL,
    target_steps        INT NULL,
    target_water_liters DECIMAL(4,2) NULL,
    target_calories     INT NULL,
    `source`            ENUM('ai', 'manual') NOT NULL DEFAULT 'ai',
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uq_targets_client_week (client_id, week_start_date),

    CONSTRAINT fk_targets_client
        FOREIGN KEY (client_id) REFERENCES client_profiles(client_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 4. HASIL ANALISIS AI
-- ------------------------------------------------------------

CREATE TABLE ai_analysis_results (
    analysis_id         INT AUTO_INCREMENT PRIMARY KEY,
    client_id           INT NOT NULL,
    reviewed_by_pt_id   INT NULL,
    week_start_date     DATE NOT NULL,
    ai_output           JSON NULL,
    final_output        JSON NULL,
    `status`            ENUM('pending', 'approved', 'overridden') NOT NULL DEFAULT 'pending',
    reviewed_at         DATETIME NULL,
    created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,

    KEY idx_ai_results_client_week (client_id, week_start_date),

    CONSTRAINT fk_ai_results_client
        FOREIGN KEY (client_id) REFERENCES client_profiles(client_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_ai_results_pt
        FOREIGN KEY (reviewed_by_pt_id) REFERENCES users(user_id)
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- NOTIFICATIONS (AI insight & reminders)
-- ------------------------------------------------------------

CREATE TABLE notifications (
    notification_id  INT AUTO_INCREMENT PRIMARY KEY,
    user_id          INT NOT NULL,
    type             ENUM('ai_insight', 'reminder', 'system') NOT NULL,
    title            VARCHAR(150) NOT NULL,
    message          TEXT NOT NULL,
    is_read          BOOLEAN NOT NULL DEFAULT FALSE,
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,

    KEY idx_notifications_user (user_id),

    CONSTRAINT fk_notifications_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 5. AUDIT LOG / OBSERVABILITY
-- ------------------------------------------------------------

CREATE TABLE audit_logs (
    audit_id     INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT NULL,
    `action`     VARCHAR(100) NOT NULL,
    entity_type  VARCHAR(100) NULL,
    entity_id    INT NULL,
    details      JSON NULL,
    severity     ENUM('info', 'warning', 'error') NOT NULL DEFAULT 'info',
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,

    KEY idx_audit_logs_user (user_id),
    KEY idx_audit_logs_created (created_at),

    CONSTRAINT fk_audit_logs_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE SET NULL
) ENGINE=InnoDB;
