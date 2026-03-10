# Healthcare Relational Database Design

This project implements a relational healthcare database using T-SQL and Microsoft SQL Server based on a set of business rules provided for a database design assignment.

The goal was to design a normalized schema that models relationships between patients, physicians, treatments, medications, and prescriptions while enforcing data integrity through constraints and keys.

## Entity Relationship Diagram

![Healthcare Database ERD](diagrams/healthcare_erd.png)

## Database Schema Overview

The database includes the following core entities:

- **patient** – stores patient demographic and contact information
- **physician** – stores physician details and specialties
- **treatment** – stores treatment information
- **medication** – stores medication records
- **prescription** – links patients and medications
- **patient_treatment** – links patients, physicians, and treatments
- **administration_lu** – bridge table connecting prescriptions and treatments

## Skills Demonstrated

- T-SQL
- Microsoft SQL Server
- Relational database design
- Entity-relationship modeling
- Primary and foreign key constraints
- Data integrity enforcement
- Many-to-many relationship modeling

## Project Context

This project was completed as part of a database systems course. Students were given business rules and required to design and implement a relational database schema that enforced those rules through SQL constraints, keys, and table relationships.
