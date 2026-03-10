SET ANSI_WARNINGS ON;
GO

USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = N'js22bz')
BEGIN
    ALTER DATABASE js22bz SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE js22bz;
END;
GO

IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'js22bz')
    CREATE DATABASE js22bz;
GO

USE js22bz;
GO

/* PATIENT */
IF OBJECT_ID(N'dbo.patient', N'U') IS NOT NULL
    DROP TABLE dbo.patient;
GO

CREATE TABLE dbo.patient
(
    pat_id       SMALLINT     NOT NULL IDENTITY(1,1),
    pat_ssn      INT          NOT NULL CHECK (pat_ssn > 0 AND pat_ssn <= 999999999),
    pat_fname    VARCHAR(15)  NOT NULL,
    pat_lname    VARCHAR(30)  NOT NULL,
    pat_street   VARCHAR(30)  NOT NULL,
    pat_city     VARCHAR(30)  NOT NULL,
    pat_state    CHAR(2)      NOT NULL DEFAULT 'FL',
    pat_zip      CHAR(9)      NOT NULL CHECK (pat_zip LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    pat_phone    BIGINT       NOT NULL,
    pat_email    VARCHAR(100) NOT NULL,
    pat_dob      DATE         NOT NULL,

    pat_gender   CHAR(1)      NOT NULL,
    pat_notes    VARCHAR(255) NULL,

    CONSTRAINT pk_patient       PRIMARY KEY (pat_id),
    CONSTRAINT ux_pat_ssn       UNIQUE (pat_ssn),
    CONSTRAINT ck_patient_gender CHECK (pat_gender IN ('m','f'))
);
GO

/* PHYSICIAN */
IF OBJECT_ID(N'dbo.physician', N'U') IS NOT NULL
    DROP TABLE dbo.physician;
GO

CREATE TABLE dbo.physician
(
    phy_id        SMALLINT     NOT NULL IDENTITY(1,1),
    phy_specialty VARCHAR(25)  NOT NULL,
    phy_fname     VARCHAR(15)  NOT NULL,
    phy_lname     VARCHAR(30)  NOT NULL,
    phy_street    VARCHAR(30)  NOT NULL,
    phy_city      VARCHAR(20)  NOT NULL,
    phy_state     CHAR(2)      NOT NULL DEFAULT 'FL',
    phy_zip       CHAR(9)      NOT NULL CHECK (phy_zip LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    phy_phone     BIGINT       NOT NULL,
    phy_fax       BIGINT       NULL,
    phy_email     VARCHAR(100) NOT NULL,
    phy_url       VARCHAR(100) NULL,
    phy_notes     VARCHAR(255) NULL,
    CONSTRAINT pk_physician PRIMARY KEY (phy_id),
    CONSTRAINT ux_phy_email UNIQUE (phy_email)
);
GO

/* TREATMENT */
IF OBJECT_ID(N'dbo.treatment', N'U') IS NOT NULL
    DROP TABLE dbo.treatment;
GO

CREATE TABLE dbo.treatment
(
    trt_id    SMALLINT     NOT NULL IDENTITY(1,1),
    trt_name  VARCHAR(255) NOT NULL,      -- description
    trt_price DECIMAL(8,2) NOT NULL CHECK (trt_price > 0),
    trt_notes VARCHAR(255) NULL,
    CONSTRAINT pk_treatment PRIMARY KEY (trt_id)
);
GO

/* MEDICATION */
IF OBJECT_ID(N'dbo.medication', N'U') IS NOT NULL
    DROP TABLE dbo.medication;
GO

CREATE TABLE dbo.medication
(
    med_id         SMALLINT      NOT NULL IDENTITY(1,1),
    med_name       VARCHAR(100)  NOT NULL,
    med_price      DECIMAL(5,2)  NOT NULL CHECK (med_price > 0),
    med_shelf_life DATE          NOT NULL,
    med_notes      VARCHAR(255)  NULL,
    CONSTRAINT pk_medication PRIMARY KEY (med_id)
);
GO

/* PRESCRIPTION   (patient–medication) */
IF OBJECT_ID(N'dbo.prescription', N'U') IS NOT NULL
    DROP TABLE dbo.prescription;
GO

CREATE TABLE dbo.prescription
(
    pre_id         SMALLINT     NOT NULL IDENTITY(1,1),
    pat_id         SMALLINT     NOT NULL,
    med_id         SMALLINT     NOT NULL,
    pre_date       DATE         NOT NULL,
    pre_dosage     VARCHAR(255) NOT NULL,
    pre_num_refills VARCHAR(3)  NULL,
    pre_notes      VARCHAR(255) NULL,
    CONSTRAINT pk_prescription PRIMARY KEY (pre_id),

    CONSTRAINT fk_prescription_patient
        FOREIGN KEY (pat_id)
        REFERENCES dbo.patient (pat_id),

    CONSTRAINT fk_prescription_medication
        FOREIGN KEY (med_id)
        REFERENCES dbo.medication (med_id)
);
GO

/* PATIENT_TREATMENT (patient–physician–treatment) */
IF OBJECT_ID(N'dbo.patient_treatment', N'U') IS NOT NULL
    DROP TABLE dbo.patient_treatment;
GO

CREATE TABLE dbo.patient_treatment
(
    ptr_id      SMALLINT     NOT NULL IDENTITY(1,1),
    pat_id      SMALLINT     NOT NULL,
    phy_id      SMALLINT     NOT NULL,
    trt_id      SMALLINT     NOT NULL,
    ptr_date    DATE         NOT NULL,
    ptr_start   TIME         NOT NULL,
    ptr_end     TIME         NOT NULL,
    ptr_results VARCHAR(255) NULL,
    ptr_notes   VARCHAR(255) NULL,
    CONSTRAINT pk_patient_treatment PRIMARY KEY (ptr_id),

    CONSTRAINT fk_pt_patient
        FOREIGN KEY (pat_id)
        REFERENCES dbo.patient (pat_id),

    CONSTRAINT fk_pt_physician
        FOREIGN KEY (phy_id)
        REFERENCES dbo.physician (phy_id),

    CONSTRAINT fk_pt_treatment
        FOREIGN KEY (trt_id)
        REFERENCES dbo.treatment (trt_id),

    -- Business rule: Each prescribed treatment on a specific date
    -- can be prescribed by only one physician to one patient.
    CONSTRAINT ux_patient_treatment UNIQUE (pat_id, trt_id, ptr_date)
);
GO

/* ADMINISTRATION_LU (bridge Prescription <-> Patient_Treatment) */
IF OBJECT_ID(N'dbo.administration_lu', N'U') IS NOT NULL
    DROP TABLE dbo.administration_lu;
GO

CREATE TABLE dbo.administration_lu
(
    pre_id SMALLINT NOT NULL,
    ptr_id SMALLINT NOT NULL,

    CONSTRAINT pk_administration_lu PRIMARY KEY (pre_id, ptr_id),

    CONSTRAINT fk_admin_prescription
        FOREIGN KEY (pre_id)
        REFERENCES dbo.prescription (pre_id),

    CONSTRAINT fk_admin_patient_treatment
        FOREIGN KEY (ptr_id)
        REFERENCES dbo.patient_treatment (ptr_id)
);
GO


/* SAMPLE DATA – 5 ROWS PER TABLE */

-- PATIENT
INSERT INTO dbo.patient
(pat_ssn, pat_fname, pat_lname, pat_street, pat_city, pat_state, pat_zip,
 pat_phone, pat_email, pat_dob, pat_gender, pat_notes)
VALUES
(111223333, 'John',   'Smith',   '101 Main St',      'Tallahassee', 'FL', '323011111',
 8505550001, 'john.smith@example.com', '1985-01-15', 'm', 'Allergic to penicillin'),
(222334444, 'Mary',   'Johnson', '202 Oak Ave',      'Tallahassee', 'FL', '323022222',
 8505550002, 'mary.johnson@example.com', '1990-05-20', 'f', NULL),
(333445555, 'Robert', 'Brown',   '303 Pine Rd',      'Jacksonville','FL', '322033333',
 9045550003, 'robert.brown@example.com', '1978-09-10', 'm', 'Diabetic'),
(444556666, 'Linda',  'Davis',   '404 River Dr',     'Orlando',     'FL', '328044444',
 4075550004, 'linda.davis@example.com', '1969-12-01', 'f', NULL),
(555667777, 'Carlos', 'Garcia',  '505 Lake View Ln', 'Miami',       'FL', '331055555',
 3055550005, 'carlos.garcia@example.com', '1995-03-08', 'm', 'Smoker');
GO

-- PHYSICIAN
INSERT INTO dbo.physician
(phy_specialty, phy_fname, phy_lname, phy_street, phy_city, phy_state, phy_zip,
 phy_phone, phy_fax, phy_email, phy_url, phy_notes)
VALUES
('Cardiology',   'Alice',  'Cooper',  '1 Heart Way',   'Tallahassee','FL','323018888',
 8505551001, 8505552001, 'acooper@clinic.com',  'http://cardio.example.com', NULL),
('Dermatology',  'Brian',  'Miller',  '2 Skin Blvd',   'Tallahassee','FL','323028888',
 8505551002, 8505552002, 'bmiller@clinic.com',  'http://derm.example.com', NULL),
('Pediatrics',   'Chloe',  'Wong',    '3 Kids Ct',     'Orlando',    'FL','328018888',
 4075551003, 4075552003, 'cwong@childhealth.com','http://peds.example.com','Evening clinic'),
('Oncology',     'David',  'Nguyen',  '4 Hope St',     'Miami',      'FL','331018888',
 3055551004, 3055552004, 'dnguyen@cancer.org',  'http://onco.example.com', NULL),
('Family Med',   'Emma',   'Lopez',   '5 Family Cir',  'Jacksonville','FL','322018888',
 9045551005, 9045552005, 'elopez@familyclinic.com','http://family.example.com','Weekend hours');
GO

-- TREATMENT
INSERT INTO dbo.treatment
(trt_name, trt_price, trt_notes)
VALUES
('Physical therapy session',  150.00, '45-minute session'),
('Chemotherapy infusion',    2500.00, 'Outpatient'),
('Allergy skin test',         200.00, NULL),
('Routine check-up',           90.00,  'Annual physical'),
('Wound dressing change',      75.00,  NULL);
GO

-- MEDICATION
INSERT INTO dbo.medication
(med_name, med_price, med_shelf_life, med_notes)
VALUES
('Atorvastatin 20mg',  35.50, '2026-12-31', NULL),
('Metformin 500mg',    18.25, '2025-06-30', 'Store below 25C'),
('Ibuprofen 200mg',     7.99, '2027-03-31', 'OTC'),
('Amoxicillin 500mg',  22.10, '2024-11-30', 'Refrigerate after opening'),
('Loratadine 10mg',    12.49, '2026-05-31', NULL);
GO

-- PRESCRIPTION (links patient & medication)
INSERT INTO dbo.prescription
(pat_id, med_id, pre_date, pre_dosage, pre_num_refills, pre_notes)
VALUES
(1, 1, '2025-01-10', '20mg once daily',      '3',  NULL),
(1, 5, '2025-01-10', '10mg once daily PRN',  '1',  'Seasonal allergies'),
(2, 3, '2025-02-01', '200mg every 8 hours',  '0',  'Post-procedure pain'),
(3, 2, '2025-02-15', '500mg twice daily',    '2',  NULL),
(4, 4, '2025-03-05', '500mg three times/day','0',  '7-day course');
GO

-- PATIENT_TREATMENT (links patient, physician, treatment)
INSERT INTO dbo.patient_treatment
(pat_id, phy_id, trt_id, ptr_date, ptr_start, ptr_end, ptr_results, ptr_notes)
VALUES
(1, 1, 4, '2025-01-10', '09:00', '09:20', 'Stable, routine visit', NULL),
(1, 1, 1, '2025-01-17', '10:00', '10:45', 'Improved mobility',     NULL),
(2, 3, 3, '2025-02-01', '13:00', '13:30', 'Mild reaction to test', 'Follow-up in 2 weeks'),
(3, 5, 4, '2025-02-15', '11:00', '11:20', 'Blood pressure controlled', NULL),
(4, 4, 2, '2025-03-05', '08:00', '11:30', 'First chemo cycle completed', 'Next cycle in 3 weeks');
GO

-- ADMINISTRATION_LU (which prescriptions were used in which treatments)
INSERT INTO dbo.administration_lu
(pre_id, ptr_id)
VALUES
(1, 1),
(2, 2), 
(3, 3),  
(4, 4), 
(5, 5); 
GO

/* SHOW DATA */
SELECT * FROM dbo.patient;
SELECT * FROM dbo.physician;
SELECT * FROM dbo.treatment;
SELECT * FROM dbo.medication;
SELECT * FROM dbo.prescription;
SELECT * FROM dbo.patient_treatment;
SELECT * FROM dbo.administration_lu;
GO
