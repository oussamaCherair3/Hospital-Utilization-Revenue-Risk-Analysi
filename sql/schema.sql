CREATE TABLE patients (
    id UUID PRIMARY KEY,                  
    birthdate DATE NOT NULL,              
    deathdate DATE,                      
    prefix VARCHAR(10),                   
    first VARCHAR(100) NOT NULL,         
    last VARCHAR(100) NOT NULL,           
    suffix VARCHAR(10),                  
    maiden VARCHAR(100),                  
    marital CHAR(1),                      
    gender CHAR(1) NOT NULL,              
    race VARCHAR(50),                     
    ethnicity VARCHAR(50),               
    birthplace VARCHAR(100),              
    address VARCHAR(200),                 
    city VARCHAR(100),                   
    state VARCHAR(50),                   
    county VARCHAR(100),                  
    zip VARCHAR(10),                      
    lat DOUBLE PRECISION,                
    lon DOUBLE PRECISION,                 
);

CREATE TABLE encounters (
    id UUID PRIMARY KEY,
    patient UUID REFERENCES patients(id) NOT NULL,
    start DATE NOT NULL,
    payer UUID REFERENCES payers(id) NOT NULL,
    base_encounter_cost NUMERIC,
    total_claim_cost NUMERIC,
    payer_coverage NUMERIC,
    reasoncode VARCHAR(30),
    reasondescription VARCHAR(200),
    encounterclass VARCHAR(50),
    code VARCHAR(50),
    organization UUID REFERENCES organizations(id) NOT NULL,
    description VARCHAR(200),
    stop DATE
);

CREATE TABLE procedures (
    patient UUID REFERENCES patients(id) NOT NULL,
    encounter UUID REFERENCES encounters(id) NOT NULL,
    code VARCHAR(50) NOT NULL,
    description VARCHAR(255),
    start DATE NOT NULL,
    stop DATE,
    base_cost NUMERIC,
    reasoncode VARCHAR(50),
    reasondescription VARCHAR(255)
);

CREATE TABLE payers (
    id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    city VARCHAR(100),
    state_headquarters VARCHAR(2),
    zip VARCHAR(10),
    phone VARCHAR(20)
)

CREATE TABLE organizations (
    id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(2),
    zip VARCHAR(10),
    lat DOUBLE PRECISION,
    lon DOUBLE PRECISION
);