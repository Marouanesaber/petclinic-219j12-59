
-- Pet Clinic Database
-- MySQL Script
-- Database settings:
-- hostname: localhost
-- port: 3306
-- username: root
-- password: root

-- Drop database if exists
DROP DATABASE IF EXISTS pet_clinic;

-- Create database
CREATE DATABASE pet_clinic;

-- Use database
USE pet_clinic;

-- Create users table
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  profilePicture VARCHAR(255) DEFAULT NULL,
  role ENUM('admin', 'vet', 'user') NOT NULL DEFAULT 'user',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create owners table
CREATE TABLE owners (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  address VARCHAR(255),
  city VARCHAR(50),
  telephone VARCHAR(20),
  email VARCHAR(100) UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Create pet types table
CREATE TABLE pet_types (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL
);

-- Create pets table
CREATE TABLE pets (
  id INT PRIMARY KEY AUTO_INCREMENT,
  owner_id INT NOT NULL,
  name VARCHAR(50) NOT NULL,
  type_id INT NOT NULL,
  breed VARCHAR(50),
  date_of_birth DATE,
  gender ENUM('male', 'female', 'unknown') NOT NULL DEFAULT 'unknown',
  hospital_id VARCHAR(20) UNIQUE,
  notes TEXT,
  photo VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (owner_id) REFERENCES owners(id) ON DELETE CASCADE,
  FOREIGN KEY (type_id) REFERENCES pet_types(id)
);

-- Create vets table
CREATE TABLE vets (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  specialization VARCHAR(100),
  phone VARCHAR(20),
  email VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Create visit types table
CREATE TABLE visit_types (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  description TEXT
);

-- Create appointments table
CREATE TABLE appointments (
  id INT PRIMARY KEY AUTO_INCREMENT,
  pet_id INT NOT NULL,
  vet_id INT,
  visit_type_id INT,
  appointment_date DATE NOT NULL,
  appointment_time TIME NOT NULL,
  status ENUM('scheduled', 'completed', 'cancelled', 'no-show') NOT NULL DEFAULT 'scheduled',
  notes TEXT,
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE,
  FOREIGN KEY (vet_id) REFERENCES vets(id) ON DELETE SET NULL,
  FOREIGN KEY (visit_type_id) REFERENCES visit_types(id),
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Create consultations table
CREATE TABLE consultations (
  id INT PRIMARY KEY AUTO_INCREMENT,
  pet_id INT NOT NULL,
  vet_id INT,
  consultation_date DATE NOT NULL,
  chief_complaint TEXT,
  diagnosis TEXT,
  treatment TEXT,
  notes TEXT,
  charge DECIMAL(10, 2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE,
  FOREIGN KEY (vet_id) REFERENCES vets(id) ON DELETE SET NULL
);

-- Create vital signs table
CREATE TABLE vital_signs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  consultation_id INT NOT NULL,
  temperature DECIMAL(5, 2),
  heart_rate INT,
  respiratory_rate INT,
  weight DECIMAL(6, 2),
  recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (consultation_id) REFERENCES consultations(id) ON DELETE CASCADE
);

-- Create vaccine types table
CREATE TABLE vaccine_types (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  description TEXT
);

-- Create vaccinations table
CREATE TABLE vaccinations (
  id INT PRIMARY KEY AUTO_INCREMENT,
  pet_id INT NOT NULL,
  vaccine_type_id INT NOT NULL,
  administered_by INT,
  administered_date DATE NOT NULL,
  expiry_date DATE,
  dose VARCHAR(50),
  batch_number VARCHAR(50),
  temperature DECIMAL(5, 2),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE,
  FOREIGN KEY (vaccine_type_id) REFERENCES vaccine_types(id),
  FOREIGN KEY (administered_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Create lab test types table
CREATE TABLE lab_test_types (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  normal_range VARCHAR(100)
);

-- Create laboratory tests table
CREATE TABLE laboratory_tests (
  id INT PRIMARY KEY AUTO_INCREMENT,
  pet_id INT NOT NULL,
  test_type_id INT NOT NULL,
  sample_date DATE NOT NULL,
  result_date DATE,
  result TEXT,
  is_abnormal BOOLEAN DEFAULT FALSE,
  notes TEXT,
  performed_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE,
  FOREIGN KEY (test_type_id) REFERENCES lab_test_types(id),
  FOREIGN KEY (performed_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Create surgery types table
CREATE TABLE surgery_types (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  description TEXT
);

-- Create surgeries table
CREATE TABLE surgeries (
  id INT PRIMARY KEY AUTO_INCREMENT,
  pet_id INT NOT NULL,
  surgery_type_id INT NOT NULL,
  performed_by INT,
  surgery_date DATE NOT NULL,
  start_time TIME,
  end_time TIME,
  anesthesia VARCHAR(100),
  procedure_notes TEXT,
  complications TEXT,
  post_op_notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE,
  FOREIGN KEY (surgery_type_id) REFERENCES surgery_types(id),
  FOREIGN KEY (performed_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Create medication table
CREATE TABLE medications (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  dosage_form VARCHAR(50),
  strength VARCHAR(50),
  manufacturer VARCHAR(100)
);

-- Create prescriptions table
CREATE TABLE prescriptions (
  id INT PRIMARY KEY AUTO_INCREMENT,
  consultation_id INT,
  pet_id INT NOT NULL,
  medication_id INT NOT NULL,
  dosage VARCHAR(100),
  frequency VARCHAR(100),
  duration VARCHAR(100),
  start_date DATE,
  end_date DATE,
  instructions TEXT,
  prescribed_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (consultation_id) REFERENCES consultations(id) ON DELETE SET NULL,
  FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE,
  FOREIGN KEY (medication_id) REFERENCES medications(id),
  FOREIGN KEY (prescribed_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Create invoices table
CREATE TABLE invoices (
  id INT PRIMARY KEY AUTO_INCREMENT,
  owner_id INT NOT NULL,
  pet_id INT,
  invoice_date DATE NOT NULL,
  total_amount DECIMAL(10, 2) NOT NULL,
  paid_amount DECIMAL(10, 2) DEFAULT 0,
  status ENUM('pending', 'paid', 'cancelled') NOT NULL DEFAULT 'pending',
  payment_method VARCHAR(50),
  payment_date DATE,
  notes TEXT,
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (owner_id) REFERENCES owners(id) ON DELETE CASCADE,
  FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE SET NULL,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Create invoice items table
CREATE TABLE invoice_items (
  id INT PRIMARY KEY AUTO_INCREMENT,
  invoice_id INT NOT NULL,
  item_type ENUM('consultation', 'vaccination', 'laboratory', 'surgery', 'medication', 'other') NOT NULL,
  item_id INT,
  description VARCHAR(255) NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  unit_price DECIMAL(10, 2) NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
);

-- Create locations table
CREATE TABLE locations (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  address VARCHAR(255),
  city VARCHAR(50),
  phone VARCHAR(20),
  email VARCHAR(100),
  is_active BOOLEAN DEFAULT TRUE
);

-- Create settings table
CREATE TABLE settings (
  id INT PRIMARY KEY AUTO_INCREMENT,
  setting_key VARCHAR(100) NOT NULL UNIQUE,
  setting_value TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create notifications table
CREATE TABLE notifications (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  title VARCHAR(100) NOT NULL,
  message TEXT NOT NULL,
  type ENUM('info', 'success', 'warning', 'error') NOT NULL DEFAULT 'info',
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create user_settings table for storing user preferences
CREATE TABLE user_settings (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL UNIQUE,
  theme VARCHAR(20) DEFAULT 'light',
  font_size VARCHAR(10) DEFAULT 'medium',
  notifications_enabled BOOLEAN DEFAULT TRUE,
  email_notifications BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Insert initial data
-- Insert pet types
INSERT INTO pet_types (name) VALUES 
('Dog'),
('Cat'),
('Bird'),
('Rabbit'),
('Hamster'),
('Guinea Pig'),
('Reptile'),
('Other');

-- Insert visit types
INSERT INTO visit_types (name, description) VALUES 
('Wellness Check', 'Routine health examination'),
('Vaccination', 'Administration of vaccines'),
('Illness', 'Examination for specific health concerns'),
('Follow-up', 'Follow-up appointment after treatment'),
('Emergency', 'Urgent care for acute conditions');

-- Insert vaccine types
INSERT INTO vaccine_types (name, description) VALUES 
('Rabies', 'Protection against rabies virus'),
('DHPP', 'Distemper, Hepatitis, Parainfluenza, Parvovirus for dogs'),
('FVRCP', 'Feline Viral Rhinotracheitis, Calicivirus, Panleukopenia for cats'),
('Bordetella', 'Protection against kennel cough in dogs'),
('Leptospirosis', 'Protection against bacterial infection in dogs'),
('Lyme Disease', 'Protection against tick-borne disease in dogs');

-- Insert lab test types
INSERT INTO lab_test_types (name, description, normal_range) VALUES 
('Complete Blood Count', 'Evaluates overall health and detects disorders', 'Varies by parameter'),
('Blood Chemistry', 'Measures kidney, liver, and pancreatic function', 'Varies by parameter'),
('Urinalysis', 'Evaluates kidney function and detects urinary disorders', 'Varies by parameter'),
('Fecal Examination', 'Detects parasites and abnormalities in stool', 'Negative for parasites'),
('Heartworm Test', 'Detects heartworm infection', 'Negative');

-- Insert surgery types
INSERT INTO surgery_types (name, description) VALUES 
('Spay', 'Ovariohysterectomy - removal of ovaries and uterus'),
('Neuter', 'Removal of testes in males'),
('Dental Cleaning', 'Professional teeth cleaning under anesthesia'),
('Mass Removal', 'Surgical removal of tumors or growths'),
('Fracture Repair', 'Surgical repair of broken bones'),
('Exploratory Surgery', 'Diagnostic surgery to investigate an issue');

-- Insert initial admin user
INSERT INTO users (name, email, password, role) VALUES 
('Admin User', 'admin@petclinic.com', '$2y$10$8eVX9AO5yJ.mQXbfBpeZ7.0xrhUPhPaXGt1zXGmCQ7umKitQKj.oq', 'admin');
-- Note: Password is 'admin123' (hashed)

-- Insert initial vet user
INSERT INTO users (name, email, password, role) VALUES 
('Dr. John Smith', 'jsmith@petclinic.com', '$2y$10$8eVX9AO5yJ.mQXbfBpeZ7.0xrhUPhPaXGt1zXGmCQ7umKitQKj.oq', 'vet');

-- Insert sample vets
INSERT INTO vets (user_id, first_name, last_name, specialization, phone, email) VALUES 
(2, 'John', 'Smith', 'General Practice', '123-456-7890', 'jsmith@petclinic.com'),
(NULL, 'Sarah', 'Johnson', 'Surgery', '234-567-8901', 'sjohnson@petclinic.com'),
(NULL, 'Michael', 'Brown', 'Dermatology', '345-678-9012', 'mbrown@petclinic.com');

-- Insert locations
INSERT INTO locations (name, address, city, phone, email) VALUES 
('Main Clinic', '123 Main St', 'Anytown', '123-456-7890', 'info@petclinic.com'),
('Downtown Branch', '456 Center Ave', 'Anytown', '234-567-8901', 'downtown@petclinic.com'),
('Northside Office', '789 North Blvd', 'Anytown', '345-678-9012', 'north@petclinic.com');

-- Insert settings
INSERT INTO settings (setting_key, setting_value) VALUES 
('clinic_name', 'PetClinic'),
('clinic_address', '123 Main St, Anytown'),
('clinic_phone', '123-456-7890'),
('clinic_email', 'info@petclinic.com'),
('clinic_hours', 'Mon-Fri: 8am-6pm, Sat: 9am-2pm, Sun: Closed'),
('appointment_interval', '30'), -- minutes
('currency_symbol', '$'),
('tax_rate', '7.5'), -- percentage
('invoice_prefix', 'INV-'),
('default_theme', 'light');

-- Insert sample notifications
INSERT INTO notifications (user_id, title, message, type, is_read) VALUES
(1, 'New Appointment', 'You have a new appointment scheduled for tomorrow', 'info', false),
(1, 'Vaccination Due', 'Max is due for his annual vaccinations', 'warning', false),
(1, 'Payment Received', 'Payment for INV-001 has been received', 'success', true);

-- Insert user settings for existing users
INSERT INTO user_settings (user_id, theme, font_size) VALUES
(1, 'light', 'medium'),
(2, 'dark', 'large');

-- Create procedures
DELIMITER //

-- Procedure to add a new pet with owner
CREATE PROCEDURE AddPetWithOwner(
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_telephone VARCHAR(20),
    IN p_pet_name VARCHAR(50),
    IN p_pet_type VARCHAR(50),
    IN p_breed VARCHAR(50),
    IN p_dob DATE,
    IN p_gender VARCHAR(10)
)
BEGIN
    DECLARE owner_id_var INT;
    DECLARE pet_type_id_var INT;
    DECLARE hospital_id_var VARCHAR(20);
    
    -- Check if owner exists
    SELECT id INTO owner_id_var FROM owners WHERE email = p_email LIMIT 1;
    
    -- If owner doesn't exist, create new owner
    IF owner_id_var IS NULL THEN
        INSERT INTO owners (first_name, last_name, email, telephone)
        VALUES (p_first_name, p_last_name, p_email, p_telephone);
        
        SET owner_id_var = LAST_INSERT_ID();
    END IF;
    
    -- Get pet type id
    SELECT id INTO pet_type_id_var FROM pet_types WHERE name = p_pet_type LIMIT 1;
    
    -- Generate hospital ID (PETCXXXX format)
    SET hospital_id_var = CONCAT('PETC', LPAD(FLOOR(RAND() * 10000), 4, '0'));
    
    -- Insert pet
    INSERT INTO pets (owner_id, name, type_id, breed, date_of_birth, gender, hospital_id)
    VALUES (owner_id_var, p_pet_name, pet_type_id_var, p_breed, p_dob, p_gender, hospital_id_var);
    
    -- Return the new pet and owner info
    SELECT 
        p.id AS pet_id, 
        p.name AS pet_name, 
        p.hospital_id,
        o.id AS owner_id,
        CONCAT(o.first_name, ' ', o.last_name) AS owner_name
    FROM pets p
    JOIN owners o ON p.owner_id = o.id
    WHERE p.id = LAST_INSERT_ID();
END//

-- Procedure to schedule an appointment
CREATE PROCEDURE ScheduleAppointment(
    IN p_pet_id INT,
    IN p_vet_id INT,
    IN p_visit_type VARCHAR(50),
    IN p_date DATE,
    IN p_time TIME,
    IN p_notes TEXT,
    IN p_created_by INT
)
BEGIN
    DECLARE visit_type_id_var INT;
    
    -- Get visit type id
    SELECT id INTO visit_type_id_var FROM visit_types WHERE name = p_visit_type LIMIT 1;
    
    -- Insert appointment
    INSERT INTO appointments (pet_id, vet_id, visit_type_id, appointment_date, appointment_time, notes, created_by)
    VALUES (p_pet_id, p_vet_id, visit_type_id_var, p_date, p_time, p_notes, p_created_by);
    
    -- Return the new appointment info
    SELECT 
        a.id AS appointment_id,
        p.name AS pet_name,
        CONCAT(v.first_name, ' ', v.last_name) AS vet_name,
        vt.name AS visit_type,
        a.appointment_date,
        a.appointment_time,
        a.status
    FROM appointments a
    JOIN pets p ON a.pet_id = p.id
    JOIN vets v ON a.vet_id = v.id
    JOIN visit_types vt ON a.visit_type_id = vt.id
    WHERE a.id = LAST_INSERT_ID();
END//

-- Procedure to add a new consultation
CREATE PROCEDURE AddConsultation(
    IN p_pet_id INT,
    IN p_vet_id INT,
    IN p_consultation_date DATE,
    IN p_chief_complaint TEXT,
    IN p_diagnosis TEXT,
    IN p_treatment TEXT,
    IN p_notes TEXT,
    IN p_charge DECIMAL(10, 2)
)
BEGIN
    -- Insert consultation
    INSERT INTO consultations (pet_id, vet_id, consultation_date, chief_complaint, diagnosis, treatment, notes, charge)
    VALUES (p_pet_id, p_vet_id, p_consultation_date, p_chief_complaint, p_diagnosis, p_treatment, p_notes, p_charge);
    
    -- Return the new consultation info
    SELECT 
        c.id AS consultation_id,
        p.name AS pet_name,
        CONCAT(v.first_name, ' ', v.last_name) AS vet_name,
        c.consultation_date,
        c.diagnosis,
        c.charge
    FROM consultations c
    JOIN pets p ON c.pet_id = p.id
    JOIN vets v ON c.vet_id = v.id
    WHERE c.id = LAST_INSERT_ID();
END//

-- Procedure to add laboratory test
CREATE PROCEDURE AddLaboratoryTest(
    IN p_pet_id INT,
    IN p_test_type_name VARCHAR(100),
    IN p_sample_date DATE,
    IN p_result TEXT,
    IN p_is_abnormal BOOLEAN,
    IN p_notes TEXT,
    IN p_performed_by INT
)
BEGIN
    DECLARE test_type_id_var INT;
    
    -- Get test type id
    SELECT id INTO test_type_id_var FROM lab_test_types WHERE name = p_test_type_name LIMIT 1;
    
    -- Insert laboratory test
    INSERT INTO laboratory_tests (pet_id, test_type_id, sample_date, result_date, result, is_abnormal, notes, performed_by)
    VALUES (p_pet_id, test_type_id_var, p_sample_date, CURDATE(), p_result, p_is_abnormal, p_notes, p_performed_by);
    
    -- Return the new laboratory test info
    SELECT 
        lt.id AS test_id,
        p.name AS pet_name,
        ltt.name AS test_name,
        lt.sample_date,
        lt.result_date,
        lt.result,
        lt.is_abnormal
    FROM laboratory_tests lt
    JOIN pets p ON lt.pet_id = p.id
    JOIN lab_test_types ltt ON lt.test_type_id = ltt.id
    WHERE lt.id = LAST_INSERT_ID();
END//

-- Procedure to add vaccination
CREATE PROCEDURE AddVaccination(
    IN p_pet_id INT,
    IN p_vaccine_type_name VARCHAR(100),
    IN p_administered_by INT,
    IN p_administered_date DATE,
    IN p_expiry_date DATE,
    IN p_dose VARCHAR(50),
    IN p_batch_number VARCHAR(50),
    IN p_notes TEXT
)
BEGIN
    DECLARE vaccine_type_id_var INT;
    
    -- Get vaccine type id
    SELECT id INTO vaccine_type_id_var FROM vaccine_types WHERE name = p_vaccine_type_name LIMIT 1;
    
    -- Insert vaccination
    INSERT INTO vaccinations (pet_id, vaccine_type_id, administered_by, administered_date, expiry_date, dose, batch_number, notes)
    VALUES (p_pet_id, vaccine_type_id_var, p_administered_by, p_administered_date, p_expiry_date, p_dose, p_batch_number, p_notes);
    
    -- Return the new vaccination info
    SELECT 
        v.id AS vaccination_id,
        p.name AS pet_name,
        vt.name AS vaccine_name,
        v.administered_date,
        v.expiry_date,
        v.batch_number
    FROM vaccinations v
    JOIN pets p ON v.pet_id = p.id
    JOIN vaccine_types vt ON v.vaccine_type_id = vt.id
    WHERE v.id = LAST_INSERT_ID();
END//

-- Procedure to add surgery
CREATE PROCEDURE AddSurgery(
    IN p_pet_id INT,
    IN p_surgery_type_name VARCHAR(100),
    IN p_performed_by INT,
    IN p_surgery_date DATE,
    IN p_start_time TIME,
    IN p_end_time TIME,
    IN p_anesthesia VARCHAR(100),
    IN p_procedure_notes TEXT,
    IN p_complications TEXT,
    IN p_post_op_notes TEXT
)
BEGIN
    DECLARE surgery_type_id_var INT;
    
    -- Get surgery type id
    SELECT id INTO surgery_type_id_var FROM surgery_types WHERE name = p_surgery_type_name LIMIT 1;
    
    -- Insert surgery
    INSERT INTO surgeries (pet_id, surgery_type_id, performed_by, surgery_date, start_time, end_time, anesthesia, procedure_notes, complications, post_op_notes)
    VALUES (p_pet_id, surgery_type_id_var, p_performed_by, p_surgery_date, p_start_time, p_end_time, p_anesthesia, p_procedure_notes, p_complications, p_post_op_notes);
    
    -- Return the new surgery info
    SELECT 
        s.id AS surgery_id,
        p.name AS pet_name,
        st.name AS surgery_type,
        s.surgery_date,
        s.start_time,
        s.end_time,
        CONCAT(u.name) AS performed_by
    FROM surgeries s
    JOIN pets p ON s.pet_id = p.id
    JOIN surgery_types st ON s.surgery_type_id = st.id
    LEFT JOIN users u ON s.performed_by = u.id
    WHERE s.id = LAST_INSERT_ID();
END//

-- Procedure to update user settings
CREATE PROCEDURE UpdateUserSettings(
    IN p_user_id INT,
    IN p_theme VARCHAR(20),
    IN p_font_size VARCHAR(10),
    IN p_notifications_enabled BOOLEAN,
    IN p_email_notifications BOOLEAN
)
BEGIN
    -- Check if settings exist for user
    DECLARE settings_exist INT;
    SELECT COUNT(*) INTO settings_exist FROM user_settings WHERE user_id = p_user_id;
    
    -- Insert or update settings
    IF settings_exist > 0 THEN
        UPDATE user_settings 
        SET 
            theme = p_theme,
            font_size = p_font_size,
            notifications_enabled = p_notifications_enabled,
            email_notifications = p_email_notifications,
            updated_at = CURRENT_TIMESTAMP
        WHERE user_id = p_user_id;
    ELSE
        INSERT INTO user_settings (user_id, theme, font_size, notifications_enabled, email_notifications)
        VALUES (p_user_id, p_theme, p_font_size, p_notifications_enabled, p_email_notifications);
    END IF;
    
    -- Return the updated settings
    SELECT * FROM user_settings WHERE user_id = p_user_id;
END//

DELIMITER ;
