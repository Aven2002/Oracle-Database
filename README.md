# Oracle-Database
Advance Database System - Relational Database


# Step 1 : Create System
    1. Create a New Connection
        Username: SYS
        Password: Enter your SYS password.
        Role: SYSDBA (important for SYS user)

    2. Test if success then create

# Step 2 : Create User
    1. Creating tables, views, and managing sessions.
        CREATE USER mock_user IDENTIFIED BY 1234;
        GRANT DBA TO mock_user;

    2. Granting privileges on directories (CREATE ANY DIRECTORY, READ, WRITE) requires explicit permission, as it involves access to the file system. 
       UTL_FILE: This is a PL/SQL package that handles reading and writing files on the server. 
        CREATE OR REPLACE DIRECTORY my_dir AS 'C:\';
        GRANT CREATE PROCEDURE TO mock_user;
        GRANT CREATE ANY DIRECTORY TO mock_user;
        GRANT READ, WRITE ON DIRECTORY my_dir TO mock_user;
        GRANT EXECUTE ON SYS.UTL_FILE TO mock_user;

    3. CREATE USER (Same way as create new connection)
        Username: mock_user
        Password: 1234

# Step 4 : Date Import
    1. Run the code in Db_Structure.sql -- Create Tables & Indexes

# Step 5 : Date Import
    1. Run the code in Data_Import.sql step by step to avoid unexpected issues  -- Import Data from csv file
        path：C:\Users\Lenovo\Desktop\
        filename： Global_Superstore.csv