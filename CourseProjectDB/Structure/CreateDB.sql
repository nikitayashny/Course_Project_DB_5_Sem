ALTER SESSION SET CONTAINER = CDB$ROOT;

CREATE PLUGGABLE DATABASE CP_YNS_PDB
   ADMIN USER CP_YNS_ADMIN IDENTIFIED BY 1234 
   FILE_NAME_CONVERT = ('C:\OracleDB\oradata\XE\pdbseed', 'C:\OracleDB\oradata\XE\cp_yns_pdb')
   DEFAULT TABLESPACE users
   DATAFILE 'C:\OracleDB\oradata\XE\cp_yns_pdb\system01.dbf' SIZE 100M AUTOEXTEND ON;
   
alter session set container = CP_YNS_PDB
alter pluggable database CP_YNS_PDB open read write



CREATE PLUGGABLE DATABASE TEST_PDB2
   ADMIN USER TEST_ADMIN2 IDENTIFIED BY 123 
   FILE_NAME_CONVERT = ('C:\OracleDB\oradata\XE\pdbseed', 'C:\OracleDB\oradata\XE\test_pdb2')
   DEFAULT TABLESPACE users
   DATAFILE 'C:\OracleDB\oradata\XE\test_pdb2\system01.dbf' SIZE 100M AUTOEXTEND ON;
   
   CREATE PLUGGABLE DATABASE zxc_pdb
   ADMIN USER zxc_admin IDENTIFIED BY 123 
   FILE_NAME_CONVERT = ('C:\OracleDB\oradata\XE\pdbseed', 'C:\OracleDB\oradata\XE\zxc_pdb')
   DEFAULT TABLESPACE users
   DATAFILE 'C:\OracleDB\oradata\XE\zxc_pdb\system01.dbf' SIZE 100M AUTOEXTEND ON;