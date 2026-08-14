CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email           VARCHAR(255) UNIQUE NOT NULL,
    password_hash   VARCHAR(255) NOT NULL,
    full_name       VARCHAR(255) NOT NULL,
    phone_number    VARCHAR(20) UNIQUE NOT NULL,
    role            VARCHAR(20) NOT NULL CHECK (role IN ('CLIENT', 'PROVIDER', 'ADMIN')),
    profile_image_url TEXT,
    location        GEOGRAPHY(POINT, 4326),
    address         TEXT,
    is_available    BOOLEAN DEFAULT true,
    rating          DECIMAL(3,2) DEFAULT 0.00,
    total_reviews   INTEGER DEFAULT 0,
    fcm_token       VARCHAR(255),
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE service_categories (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(100) UNIQUE NOT NULL,
    description     TEXT,
    icon_name       VARCHAR(50) NOT NULL,
    base_price      DECIMAL(10,2) DEFAULT 0.00,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE provider_skills (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id     INTEGER NOT NULL REFERENCES service_categories(id) ON DELETE CASCADE,
    experience_years INTEGER DEFAULT 0,
    hourly_rate     DECIMAL(10,2),
    verified        BOOLEAN DEFAULT false,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(provider_id, category_id)
);

CREATE TABLE jobs (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id       UUID NOT NULL REFERENCES users(id),
    provider_id     UUID REFERENCES users(id),
    category_id     INTEGER NOT NULL REFERENCES service_categories(id),
    title           VARCHAR(255) NOT NULL,
    description     TEXT,
    status          VARCHAR(20) NOT NULL DEFAULT 'REQUESTED'
                    CHECK (status IN ('REQUESTED','MATCHED','IN_PROGRESS','COMPLETED','CANCELLED')),
    location        GEOGRAPHY(POINT, 4326),
    address         TEXT,
    scheduled_at    TIMESTAMPTZ,
    started_at      TIMESTAMPTZ,
    completed_at    TIMESTAMPTZ,
    estimated_cost  DECIMAL(10,2),
    final_cost      DECIMAL(10,2),
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE payments (
    id                          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id                      UUID NOT NULL REFERENCES jobs(id),
    client_id                   UUID NOT NULL REFERENCES users(id),
    provider_id                 UUID REFERENCES users(id),
    amount                      DECIMAL(10,2) NOT NULL,
    mpesa_checkout_request_id   VARCHAR(100),
    mpesa_receipt_number        VARCHAR(50),
    status                      VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                                CHECK (status IN ('PENDING','HELD','RELEASED','REFUNDED','FAILED')),
    escrow_held_at              TIMESTAMPTZ,
    released_at                 TIMESTAMPTZ,
    created_at                  TIMESTAMPTZ DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE reviews (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id          UUID NOT NULL REFERENCES jobs(id) UNIQUE,
    reviewer_id     UUID NOT NULL REFERENCES users(id),
    reviewee_id     UUID NOT NULL REFERENCES users(id),
    rating          INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment         TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Spatial indexes
CREATE INDEX idx_users_location ON users USING GIST(location);
CREATE INDEX idx_jobs_location ON jobs USING GIST(location);

-- B-tree indexes
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_available ON users(is_available) WHERE is_available = true;
CREATE INDEX idx_jobs_status ON jobs(status);
CREATE INDEX idx_jobs_client ON jobs(client_id);
CREATE INDEX idx_jobs_provider ON jobs(provider_id);
CREATE INDEX idx_provider_skills_prov ON provider_skills(provider_id);
CREATE INDEX idx_provider_skills_cat ON provider_skills(category_id);
CREATE INDEX idx_payments_job ON payments(job_id);
CREATE INDEX idx_payments_status ON payments(status);
