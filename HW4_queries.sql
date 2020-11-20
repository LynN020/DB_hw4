CREATE SCHEMA `databasehw4a`;

 -- Error Code: 1046. No database selected
 -- Select the default DB to be used by double-clicking its name
 -- in the SCHEMAS list in the sidebar.	0.000 sec
CREATE TABLE `databasehw4`.EMPLOYEE (
     Fname          VARCHAR(15)      NOT NULL,
     Minit          CHAR,
     Lname          VARCHAR(15)      NOT NULL,
     Ssn            CHAR(9)          NOT NULL,
     Bdate          DATE,
     Address        VARCHAR(30),
     Sex            CHAR,
     Salary         DECIMAL(10, 2),
     Super_ssn      CHAR(9),
     Dno            INT              NOT NULL,
    CONSTRAINT EMP_PK
     PRIMARY KEY (Ssn),
    CONSTRAINT EMP_SUPER_FK
     FOREIGN KEY (Super_ssn) REFERENCES EMPLOYEE(Ssn)
                  ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT EMP_DEPT_FK
        FOREIGN KEY(Dno) REFERENCES DEPARTMENT(Dnumber)
                 ON DELETE SET DEFAULT ON UPDATE CASCADE ); 
 
 -- Remove constraints for pk and fk, save for ALTER TABLE employee (after CREATE TABLE department)
 CREATE TABLE databasehw4.EMPLOYEE ( 
	 Fname          VARCHAR(15)      NOT NULL,
     Minit          CHAR,
     Lname          VARCHAR(15)      NOT NULL,
     Ssn            CHAR(9)          NOT NULL,
     Bdate          DATE,
     Address        VARCHAR(30),
     Sex            CHAR,
     Salary         DECIMAL(10, 2),
     Super_ssn      CHAR(9),
     Dno            INT              NOT NULL); 
 
 -- CREATE TABLE DEPARTMENT ** constraints attached **
 CREATE TABLE databasehw4.DEPARTMENT (
    Dname          VARCHAR(15)      NOT NULL,
    Dnumber        INT              NOT NULL,
    Mgr_ssn        CHAR(9)          NOT NULL  DEFAULT '88866555',
    Mgr_start_date DATE,
   CONSTRAINT DEPT_PK
    PRIMARY KEY (Dnumber),
   CONSTRAINT DEPT_UK
    UNIQUE (Dname),
   CONSTRAINT DEPT_MGR_FK
    FOREIGN KEY (Mgr_ssn) REFERENCES EMPLOYEE (Ssn)
                 ON DELETE SET DEFAULT ON UPDATE CASCADE
);


 -- Error Code: 1822. Failed to add the foreign key constraint. 
 -- Missing index for constraint 'DEPT_MGR_FK' in the referenced table 'employee'	0.016 sec
 -- FIX: REMOVE CONSTRAINT FROM PARENT DEPARTMENT ENTITY 
CREATE TABLE databasehw4.DEPARTMENT (
     Dname          VARCHAR(15)      NOT NULL,
     Dnumber        INT              NOT NULL,
     Mgr_ssn        CHAR(9)          NOT NULL  DEFAULT '88866555',
     Mgr_start_date DATE); 
     
CREATE TABLE databasehw4.DEPT_LOCATIONS (
    Dnumber        INT              NOT NULL,
    Dlocation      VARCHAR(15)      NOT NULL); 

CREATE TABLE databasehw4.PROJECT (
    Pname          VARCHAR(15)      NOT NULL,
    Pnumber        INT              NOT NULL,
    Plocation      VARCHAR(15),
    Dnum           INT              NOT NULL
);
CREATE TABLE databasehw4.WORKS_ON (
    Essn           CHAR(9)          NOT NULL,
    Pno            INT              NOT NULL,
    Hours          DECIMAL(3, 1),
   CONSTRAINT WORKS_ON_PK
    PRIMARY KEY (Essn , Pno)
);

CREATE TABLE databasehw4.DEPENDENT (
    Essn           CHAR(9)          NOT NULL,
    Dependent_name VARCHAR(15)      NOT NULL,
    Sex            CHAR,
    Bdate          DATE,
    Relationship   VARCHAR(8),
   CONSTRAINT DEPENDENT_PK
    PRIMARY KEY (Essn , Dependent_name)
);

/*ALTER TABLE
add in constraints (pk and fk)*/
ALTER TABLE databasehw4.EMPLOYEE
	ADD(CONSTRAINT Emp_pk PRIMARY KEY(Ssn)); 
    
-- Error Code: 1215. Cannot add foreign key constraint
-- FIX: separate PK and FK constraint into 2 separate ALTER TABLES
ALTER TABLE databasehw4.EMPLOYEE
	ADD(
	CONSTRAINT Emp_super_fk FOREIGN KEY(Super_ssn) 
		REFERENCES EMPLOYEE(Ssn) 
		ON DELETE SET NULL ON UPDATE CASCADE); 
        
-- DEPENDENT CONSTRAINT - ran 
ALTER TABLE databasehw4.DEPENDENT ADD(
 CONSTRAINT DEPENDENT_EMP_FK
	FOREIGN KEY (Essn) REFERENCES EMPLOYEE (Ssn)); 


-- PROJECT PK CONSTRAINT - ran 
ALTER TABLE databasehw4.PROJECT ADD(
   CONSTRAINT PROJECT_PK
    PRIMARY KEY (Pnumber),
    UNIQUE (Pname)); 

-- WORKS_ON CONSTRAINTS - ran 
ALTER TABLE databasehw4.WORKS_ON ADD(
   CONSTRAINT WORKS_ON_EMP_FK
    FOREIGN KEY (Essn) REFERENCES EMPLOYEE (Ssn),
   CONSTRAINT WORKS_ON_PROJ_FK
    FOREIGN KEY (Pno) REFERENCES PROJECT (Pnumber)); 

-- DEPARTMENT'S PK CONSTRAINTS 
ALTER TABLE databasehw4.DEPARTMENT ADD (
    CONSTRAINT DEPT_PK
     PRIMARY KEY (Dnumber),
    CONSTRAINT DEPT_UK
     UNIQUE (Dname)); 
/* DEPARTMENT FK CONSTRAINT
-- Actually, DEFAULT works */
ALTER TABLE databasehw4.DEPARTMENT ADD (     
    CONSTRAINT DEPT_MGR_FK
     FOREIGN KEY (Mgr_ssn) REFERENCES EMPLOYEE(Ssn)
                  ON DELETE SET DEFAULT ON UPDATE CASCADE); 

-- EMPLOYEE CONSTRAINT
ALTER TABLE databasehw4.EMPLOYEE ADD(
    CONSTRAINT EMP_DEPT_FK
        FOREIGN KEY(Dno) REFERENCES DEPARTMENT(Dnumber)
                 ON DELETE SET DEFAULT ON UPDATE CASCADE ); 
-- PROJECT FK CONSTRAINT
ALTER TABLE databasehw4.PROJECT ADD (
	CONSTRAINT PROJECT_DEPT_FK FOREIGN KEY(Dnum) REFERENCES DEPARTMENT(Dnumber)); 
    
-- DEPT_LOCATIONS PK CONSTRAINT 
ALTER TABLE databasehw4.DEPT_LOCATIONS ADD(
	CONSTRAINT DEPT_LOCATIONS_PK PRIMARY KEY (Dnumber, Dlocation)); 
    
-- DEPT_LOCATIONS FK CONSTRAINT
ALTER TABLE databasehw4.DEPT_LOCATIONS ADD(
	CONSTRAINT DEPT_LOCATIONS_DEPT_FK FOREIGN KEY(Dnumber) 
		REFERENCES DEPARTMENT (Dnumber)
                 ON DELETE CASCADE ON UPDATE CASCADE);   
                 
/**** DML */

-- FIXES: Superssn to super_ssn, need STR_TO_DATE()
-- SOLVE CODE 1452: NULL for Super_ssn and Dno
INSERT INTO databasehw4.EMPLOYEE(FNAME, MINIT,LNAME,SSN,BDATE,ADDRESS,SEX,SALARY,SUPER_SSN,DNO) VALUES
('John','B','Smith',123456789, STR_TO_DATE('09-JAN-65', "%d-%b-%Y"),'731 Fondren, Houston, TX','M',30000,NULL,NULL);

-- Error Code: 1048. Column 'Dno' cannot be null	0.000 sec
-- FIX: create 1 record for Dept
-- DEPARTMENT'S PK CONSTRAINTS 
INSERT INTO databasehw4.DEPARTMENT(Dnumber) VALUES(5);

-- 0	9	21:44:48	INSERT INTO databasehw4.DEPARTMENT(Dnumber) VALUES(5)	
-- Error Code: 1364. Field 'Dname' doesn't have a default value	0.015 sec
INSERT INTO databasehw4.DEPARTMENT(Dname, Dnumber) VALUES('hq temp ', 5);

/* need to allow EMPLOYEE.Dno (DEPARTMENT.Dnumber) to accept NULL
1. modify it in the data type, then drop the fk constraint. 
2. add (temp) fk constraint to accept 
3. INSERT INTO data 
4. reinstall constraints of the fk of EMPLOYEE.Dno -- do we reinstall at the very end? or go through the process with each INSERT?*/
-- lets use DDL instead and remove NOT NULL
 ALTER TABLE databasehw4.DEPARTMENT MODIFY COLUMN 
    Dname          VARCHAR(15); -- don't think this worked 
ALTER TABLE databasehw4.EMPLOYEE DROP 
	CONSTRAINT EMP_DEPT_FK;     
-- Did ALTER TABLE ... MODIFY not work? try this guy instead 
ALTER TABLE `databasehw4`.`employee` 
CHANGE COLUMN `Dno` `Dno` INT NULL ;
ALTER TABLE databasehw4.EMPLOYEE ADD
	CONSTRAINT EMP_DEPT_FK FOREIGN KEY (Dno) REFERENCES DEPARTMENT(Dnumber)
    ON DELETE SET NULL ON UPDATE CASCADE; 
    
/*Recall Super_ssn (recursive) - temp remove NOT NULL from CREATE TABLE 
Dno (fk) - DROP fk constraint, CHANGE COLUMN Dno to int NULL*/
INSERT INTO databasehw4.EMPLOYEE(FNAME, MINIT,LNAME,SSN,BDATE,ADDRESS,SEX,SALARY,SUPER_SSN,DNO) VALUES
('John','B','Smith',123456789, STR_TO_DATE('09-JAN-65', "%d-%b-%Y"),'731 Fondren, Houston, TX','M',30000,NULL,NULL);
    SHOW CREATE TABLE databasehw4.EMPLOYEE;
UPDATE databasehw4.employee set bdate = STR_TO_DATE('09-JAN-1965', "%d-%b-%Y") where ssn = 123456789 
	and Super_ssn is null and dno is null;

/*Let's try to go back to EMPLOYEE data insert with current set up system*/
INSERT INTO databasehw4.EMPLOYEE(FNAME, MINIT,LNAME,SSN,BDATE,ADDRESS,SEX,SALARY,SUPER_SSN,DNO) VALUES
('Franklin','T','Wong',333445555,STR_TO_DATE('08-DEC-55', "%d-%b-%Y"),'635 Voss, Houston, TX','M',40000,NULL,NULL);
UPDATE databasehw4.employee set bdate = STR_TO_DATE('08-DEC-1955', "%d-%b-%Y") where ssn = 333445555
	and Super_ssn is null and dno is null;
    
-- need to run these 
INSERT INTO databasehw4.EMPLOYEE(FNAME, MINIT,LNAME,SSN,BDATE,ADDRESS,SEX,SALARY,SUPER_SSN,DNO) VALUES
('Alicia','J','Zelaya',999887777,STR_TO_DATE('19-JAN-68',"%d-%b-%Y"), '3321 Castle, Spring','F',25000,NULL,NULL);
UPDATE databasehw4.employee set bdate = STR_TO_DATE('19-JAN-1968',"%d-%b-%Y") where ssn = 999887777
	and Super_ssn is null and dno is null;

INSERT INTO databasehw4.EMPLOYEE(FNAME, MINIT,LNAME,SSN,BDATE,ADDRESS,SEX,SALARY,SUPER_SSN,DNO) VALUES
('Jennifer','S','Wallace',987654321,STR_TO_DATE('20-JUN-41', "%d-%b-%Y"),'291 Berry, Bellaire, TX','F',43000,NULL,NULL);
UPDATE databasehw4.employee set bdate = STR_TO_DATE('20-JUN-1941', "%d-%b-%Y") where ssn = 987654321
	and Super_ssn is null and dno is null;

INSERT INTO databasehw4.EMPLOYEE(FNAME, MINIT,LNAME,SSN,BDATE,ADDRESS,SEX,SALARY,SUPER_SSN,DNO) VALUES
('Ramesh','K','Narayan',666884444,STR_TO_DATE('15-SEP-62' , "%d-%b-%Y"),'975 Fire Oak, Humble, TX','M',38000, NULL,NULL);
UPDATE databasehw4.employee set bdate = STR_TO_DATE('15-SEP-1962' , "%d-%b-%Y") where ssn = 666884444
	and Super_ssn is null and dno is null;

INSERT INTO databasehw4.EMPLOYEE(FNAME, MINIT,LNAME,SSN,BDATE,ADDRESS,SEX,SALARY,SUPER_SSN,DNO) VALUES
('Joyce','A','English',453453453, STR_TO_DATE('31-JUL-72', "%d-%b-%Y"),'5631 Rice Houston','F',25000,NULL,NULL);
UPDATE databasehw4.employee set bdate = STR_TO_DATE('31-JUL-1972', "%d-%b-%Y") where ssn = 453453453
	and Super_ssn is null and dno is null;

INSERT INTO databasehw4.EMPLOYEE(FNAME, MINIT,LNAME,SSN,BDATE,ADDRESS,SEX,SALARY,SUPER_SSN,DNO) VALUES
('Ahmad','V','Jabbar',987987987,STR_TO_DATE('29-MAR-69', "%d-%b-%Y"),'980 Dallas, Houston','M',25000,NULL,NULL);
UPDATE databasehw4.employee set bdate = STR_TO_DATE('29-MAR-1969', "%d-%b-%Y") where ssn = 987987987
	and Super_ssn is null and dno is null;

INSERT INTO databasehw4.EMPLOYEE(FNAME, MINIT,LNAME,SSN,BDATE,ADDRESS,SEX,SALARY,SUPER_SSN,DNO) VALUES
('James','E','Borg',888665555,STR_TO_DATE('10-NOV-37', "%d-%b-%Y"),'450 Stone, Houston, TX','M',55000,NULL,NULL);
UPDATE databasehw4.employee set bdate = STR_TO_DATE('10-NOV-1937', "%d-%b-%Y") where ssn = 888665555
	and Super_ssn is null and dno is null;


-- tester row for str_to_date() to work for before 1960s
INSERT INTO databasehw4.EMPLOYEE(FNAME, MINIT,LNAME,SSN,BDATE,ADDRESS,SEX,SALARY,SUPER_SSN,DNO) VALUES
('teste','t','tester',999999999,STR_TO_DATE('08-DEC-1955', "%d-%b-%Y"),'450 Stone, Houston, TX','M',55000,NULL,NULL);
DELETE FROM databasehw4.EMPLOYEE WHERE SSN = 999999999 and Super_ssn is null and dno is null; 
SELECT * FROM DATABASEHW4.EMPLOYEE;


/*DEPARTMENT DATA --------------------------------------------------
tested out before, had error 1452: FK constraint error for DEPT_MGR_FK
need to ease up FK CONSTRAINT first 
	1. ALTER TABLE - DROP fk constraint 
    2. ALTER TABLE - CHANGE COLUMN est. in CREATE TABLE to accept NULL 
		cannot be step 1 because error 3780: Referencing column 'Mgr_ssn' and referenced 
        column "Ssn' in foreign constraint'DEPT_MGR_FK' are incompatible
    3. ALTER TABLE - ADD fk constraint to allow NULL */
ALTER TABLE databasehw4.DEPARTMENT DROP CONSTRAINT DEPT_MGR_FK;  
ALTER TABLE `databasehw4`.`department` CHANGE COLUMN `Mgr_ssn` `Mgr_ssn` INT NULL ;
ALTER TABLE databasehw4.DEPARTMENT ADD
	CONSTRAINT DEPT_MGR_FK FOREIGN KEY (Mgr_ssn) REFERENCES EMPLOYEE(Ssn)
    ON DELETE SET NULL ON UPDATE CASCADE; 

INSERT INTO databasehw4.DEPARTMENT (DNAME,DNUMBER,MGR_SSN,MGR_START_DATE) VALUES
('Research',5,333445555,STR_TO_DATE('22-MAY-1988', "%d-%b-%Y"));
INSERT INTO databasehw4.DEPARTMENT(DNAME,DNUMBER,MGR_SSN,MGR_START_DATE) VALUES
('Headquarters',1,888665555,STR_TO_DATE('19-JUN-1981', "%d-%b-%Y"));
INSERT INTO databasehw4.DEPARTMENT(DNAME,DNUMBER,MGR_SSN,MGR_START_DATE) VALUES
('Administration',4,987654321,STR_TO_DATE('01-JAN-1995',"%d-%b-%Y"));

/* DEPT_LOCATIONS 
Temporarily adjust FK CONSTRAINT before adding data 
	1. ALTER TABLE - DROP fk constraint 
    2. ALTER TABLE - CHANGE COLUMN est. in CREATE TABLE to accept NULL 
    3. Since fk is also pk, don't reinstate constraint ... for now*/
SHOW CREATE TABLE databasehw4.DEPT_LOCATIONS;
ALTER TABLE databasehw4.dept_locations DROP CONSTRAINT dept_locations_dept_fk;  
ALTER TABLE `databasehw4`.`dept_locations` CHANGE COLUMN `Dnumber` `Dnumber` INT NOT NULL DEFAULT 1; 
ALTER TABLE `databasehw4`.`dept_locations` CHANGE COLUMN `Dnumber` `Dnumber` INT DEFAULT 1; 

INSERT INTO databasehw4.DEPT_LOCATIONS(DNUMBER,DLOCATION) VALUES (1,'Houston');
INSERT INTO databasehw4.DEPT_LOCATIONS(DNUMBER,DLOCATION) VALUES (4,'Stafford');
INSERT INTO databasehw4.DEPT_LOCATIONS(DNUMBER,DLOCATION) VALUES (5,'Bellaire');
INSERT INTO databasehw4.DEPT_LOCATIONS(DNUMBER,DLOCATION) VALUES (5,'Houston');
INSERT INTO databasehw4.DEPT_LOCATIONS(DNUMBER,DLOCATION) VALUES (1,'Sugarland'); # SHOULD BE EMPTY, NOT 1 

/* PROJECT 
*/
INSERT INTO databasehw4.PROJECT(PNAME,PNUMBER,PLOCATION,DNUM) VALUES
('ProductX',1,'Bellaire',5);
INSERT INTO databasehw4.PROJECT(PNAME,PNUMBER,PLOCATION,DNUM) VALUES
('ProductY',2,'Sugarland',5);
INSERT INTO databasehw4.PROJECT(PNAME,PNUMBER,PLOCATION,DNUM) VALUES
('ProductZ',3,'Houston',5);
INSERT INTO databasehw4.PROJECT(PNAME,PNUMBER,PLOCATION,DNUM) VALUES
('Computerization',10,'Stafford',4);
INSERT INTO databasehw4.PROJECT(PNAME,PNUMBER,PLOCATION,DNUM) VALUES
('Reorganization',20,'Houston',1);
INSERT INTO databasehw4.PROJECT(PNAME,PNUMBER,PLOCATION,DNUM) VALUES
('Newbenefits',30,'Stafford',4);


/*WORKS_ON*/
INSERT INTO databasehw4.WORKS_ON(ESSN,PNO,HOURS) VALUES(123456789,1,32.5);
INSERT INTO databasehw4.WORKS_ON(ESSN,PNO,HOURS) VALUES(123456789,2,7.5);
INSERT INTO databasehw4.WORKS_ON(ESSN,PNO,HOURS) VALUES(666884444,3,40);
INSERT INTO databasehw4.WORKS_ON(ESSN,PNO,HOURS) VALUES(453453453,1,20);
INSERT INTO databasehw4.WORKS_ON(ESSN,PNO,HOURS) VALUES(453453453,2,20);
INSERT INTO databasehw4.WORKS_ON(ESSN,PNO,HOURS) VALUES(333445555,2,10);
INSERT INTO databasehw4.WORKS_ON(ESSN,PNO,HOURS) VALUES(333445555,3,10);
INSERT INTO databasehw4.WORKS_ON(ESSN,PNO,HOURS) VALUES(333445555,10,10);
INSERT INTO databasehw4.WORKS_ON(ESSN,PNO,HOURS) VALUES(333445555,20,10);
INSERT INTO databasehw4.WORKS_ON(ESSN,PNO,HOURS) VALUES(999887777,30,30);
INSERT INTO databasehw4.WORKS_ON(ESSN,PNO,HOURS) VALUES(999887777,10,10);
INSERT INTO databasehw4.WORKS_ON(ESSN,PNO,HOURS) VALUES(987987987,10,35);
INSERT INTO databasehw4.WORKS_ON(ESSN,PNO,HOURS) VALUES(987987987,30,5);
INSERT INTO databasehw4.WORKS_ON(ESSN,PNO,HOURS) VALUES(987654321,30,20);
INSERT INTO databasehw4.WORKS_ON(ESSN,PNO,HOURS) VALUES(987654321,20,15);
INSERT INTO databasehw4.WORKS_ON(ESSN,PNO,HOURS) VALUES(888665555,20,NULL);


/*DEPENDENT*/
INSERT INTO databasehw4.DEPENDENT(ESSN,DEPENDENT_NAME,SEX,BDATE,RELATIONSHIP) VALUES
(123456789,'Alice','F',STR_TO_DATE('30-DEC-1988', "%d-%b-%Y"),'Daughter');
INSERT INTO databasehw4.DEPENDENT(ESSN,DEPENDENT_NAME,SEX,BDATE,RELATIONSHIP) VALUES
(123456789,'Elizabeth','F',STR_TO_DATE('05-MAY-1967', "%d-%b-%Y"),'Spouse');
INSERT INTO databasehw4.DEPENDENT(ESSN,DEPENDENT_NAME,SEX,BDATE,RELATIONSHIP) VALUES
(123456789,'Micheal','M',STR_TO_DATE('04-JAN-1988', "%d-%b-%Y"),'Son');
INSERT INTO databasehw4.DEPENDENT(ESSN,DEPENDENT_NAME,SEX,BDATE,RELATIONSHIP) VALUES
(333445555,'Alice','F',STR_TO_DATE('05-APR-1986', "%d-%b-%Y"),'Daughter');
INSERT INTO databasehw4.DEPENDENT(ESSN,DEPENDENT_NAME,SEX,BDATE,RELATIONSHIP) VALUES
(333445555,'Joy','F',STR_TO_DATE('03-MAY-1958', "%d-%b-%Y"),'Spouse');
INSERT INTO databasehw4.DEPENDENT(ESSN,DEPENDENT_NAME,SEX,BDATE,RELATIONSHIP) VALUES
(333445555,'Theodore','M',STR_TO_DATE('25-OCT-1983', "%d-%b-%Y"),'Son');
INSERT INTO databasehw4.DEPENDENT(ESSN,DEPENDENT_NAME,SEX,BDATE,RELATIONSHIP) VALUES
(987654321,'Abner','M',STR_TO_DATE('28-FEB-1942', "%d-%b-%Y"),'Spouse');

/*RESTORE DDL*/
SHOW CREATE TABLE databasehw4.EMPLOYEE; 
SHOW CREATE TABLE databasehw4.DEPARTMENT;
SHOW CREATE TABLE databasehw4.DEPT_LOCATIONS;
SHOW CREATE TABLE databasehw4.PROJECT;
SHOW CREATE TABLE databasehw4.WORKS_ON;
SHOW CREATE TABLE databasehw4.DEPENDENT;

/*NEXT: VERIFY TABLE VALUES 
1. Add Super_ssn & Dno values into EMPLOYEE
2. Reinstate constraints in DDL 
*/

/*EMPLOYEE UPDATE*/

-- Error Code: 1175. You are using safe update mode and you tried to update a table 
-- without a WHERE that uses a KEY column. Cannot use range access on index 'PRIMARY' 
-- due to type or collation conversion on field 'Ssn'
UPDATE databasehw4.EMPLOYEE SET Super_ssn = 333445555 and DNO = 5 where Ssn = 123456789; 
-- FIX: by adding quotes because values are CHAR(9), not INT.
UPDATE databasehw4.EMPLOYEE SET Super_ssn = '333445555' and DNO = 5 where Ssn = '123456789';

-- Somehow some of the EMPLOYEE columns were set to DEFAULT NULL. 
-- This should undo the NULL DEFAULT 
ALTER TABLE databasehw4.EMPLOYEE ALTER COLUMN Minit  DROP DEFAULT;
ALTER TABLE databasehw4.EMPLOYEE ALTER COLUMN Bdate  DROP DEFAULT;
ALTER TABLE databasehw4.EMPLOYEE ALTER COLUMN Address  DROP DEFAULT;
ALTER TABLE databasehw4.EMPLOYEE ALTER COLUMN Sex  DROP DEFAULT;
ALTER TABLE databasehw4.EMPLOYEE ALTER COLUMN Salary  DROP DEFAULT;
ALTER TABLE databasehw4.EMPLOYEE ALTER COLUMN Super_ssn  DROP DEFAULT;
ALTER TABLE databasehw4.EMPLOYEE ALTER COLUMN Dno  DROP DEFAULT;
ALTER TABLE databasehw4.EMPLOYEE ALTER COLUMN Bdate  DROP DEFAULT;

SHOW CREATE TABLE databasehw4.EMPLOYEE;

UPDATE databasehw4.EMPLOYEE SET Super_ssn = '333445555' , DNO = 5 where Ssn = '123456789';
UPDATE databasehw4.EMPLOYEE SET Super_ssn = '888665555' , DNO = 5 where Ssn = '333445555'; 
UPDATE databasehw4.EMPLOYEE SET Super_ssn = '987654321' , DNO = 4 where Ssn = '999887777'; 
UPDATE databasehw4.EMPLOYEE SET Super_ssn = '888665555' , DNO = 4 where Ssn = '987654321'; 
UPDATE databasehw4.EMPLOYEE SET Super_ssn = '333445555' , DNO = 5 where Ssn = '666884444'; 
UPDATE databasehw4.EMPLOYEE SET Super_ssn = '333445555' , DNO = 5 where Ssn = '453453453'; 
UPDATE databasehw4.EMPLOYEE SET Super_ssn = '987654321' , DNO = 4 where Ssn = '987987987'; 
UPDATE databasehw4.EMPLOYEE SET DNO = 1 WHERE Ssn = '888665555'; 

/*INSTALL FK CONSTRAINTS BACK IN*/


/* VERIFY DDL AGAIN */
SHOW CREATE TABLE databasehw4.EMPLOYEE;
SHOW CREATE TABLE databasehw4.DEPARTMENT;
SHOW CREATE TABLE databasehw4.DEPT_LOCATIONS;
SHOW CREATE TABLE databasehw4.PROJECT;
SHOW CREATE TABLE databasehw4.WORKS_ON;
SHOW CREATE TABLE databasehw4.DEPENDENT;

/*Change Employee.Dno from DEFAULT NULL to NOT NULL
and adjust FK CONSTRAINT back to original version */
ALTER TABLE `databasehw4`.`employee` 
DROP FOREIGN KEY `EMP_DEPT_FK`;
ALTER TABLE `databasehw4`.`employee` 
CHANGE COLUMN `Dno` `Dno` INT NOT NULL ;
ALTER TABLE `databasehw4`.`employee` 
ADD CONSTRAINT `EMP_DEPT_FK`
  FOREIGN KEY (`Dno`)
  REFERENCES `databasehw4`.`department` (`Dnumber`)
  ON DELETE SET DEFAULT
  ON UPDATE CASCADE;


/*DEPARTMENT - drop default null, set mgr_ssn default & reinstate fk */
ALTER TABLE `databasehw4`.`department` 
CHANGE COLUMN `Dname` `Dname` VARCHAR(15) NOT NULL ,
CHANGE COLUMN `Mgr_ssn` `Mgr_ssn` INT NOT NULL DEFAULT '88866555' ,
CHANGE COLUMN `Mgr_start_date` `Mgr_start_date` DATE NULL ;
ALTER TABLE databasehw4.DEPARTMENT ALTER COLUMN Mgr_start_date DROP DEFAULT;
SHOW CREATE TABLE databasehw4.DEPARTMENT;
-- change Mgr_ssn from INT to CHAR(9)
ALTER TABLE `databasehw4`.`department` 
CHANGE COLUMN `Mgr_ssn` `Mgr_ssn` CHAR(9) DEFAULT '88866555'; 
-- reinstate FK 
ALTER TABLE `databasehw4`.`department` 
ADD CONSTRAINT `Mgr_ssn`
  FOREIGN KEY (`Mgr_ssn`)
  REFERENCES `databasehw4`.`employee` (`Ssn`)
  ON DELETE SET DEFAULT
  ON UPDATE CASCADE;
ALTER TABLE `databasehw4`.`department` DROP CONSTRAINT Mgr_ssn;
ALTER TABLE `databasehw4`.`department` 
ADD CONSTRAINT `Dept_mgr_fk`
  FOREIGN KEY (`Mgr_ssn`)
  REFERENCES `databasehw4`.`employee` (`Ssn`)
  ON DELETE NO ACTION 
  ON UPDATE CASCADE;
-- change DEPT FK to ON DELETE SET DEFAULT
ALTER TABLE `databasehw4`.`department` DROP CONSTRAINT Dept_mgr_fk;
ALTER TABLE `databasehw4`.`department` 
ADD CONSTRAINT `Dept_mgr_fk`
  FOREIGN KEY (`Mgr_ssn`)
  REFERENCES `databasehw4`.`employee` (`Ssn`)
  ON DELETE SET DEFAULT
  ON UPDATE CASCADE;
  
/*DEPT_LOCATIONS - add FK constraint 
Often, we want to stray from ON DELETE CASCADE, but this relation only has 2 attributes, 
and if a department no longer exists, then there wouldn't be a physical location for it.*/
ALTER TABLE `databasehw4`.`dept_locations` 
CHANGE COLUMN `Dnumber` `Dnumber` INT DEFAULT '1' ;
ALTER TABLE `databasehw4`.`dept_locations` 
ADD CONSTRAINT `Dept_locations_dept_fk`
  FOREIGN KEY (`Dnumber`)
  REFERENCES `databasehw4`.`department` (`Dnumber`)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

/*PROJECT DDL - adjust*/
ALTER TABLE databasehw4.PROJECT ALTER COLUMN Plocation DROP DEFAULT;









/*PART 2: 
Retrieve the SSNs of employees who work on all projects that John Smith works on*/



use databasehw4
SELECT SSN FROM employee AS e
WHERE ssn NOT IN
(
	SELECT essn FROM
	(
		(-- SELECT essn, pno FROM (
			SELECT essn, pno FROM
			(SELECT pno FROM works_on where essn = "123456789") AS p
			CROSS JOIN (SELECT DISTINCT essn FROM works_on) AS w)
		  AS s
         )
	EXCEPT (SELECT essn, pno FROM works_on)
) AS r
);



SELECT * FROM databasehw4.EMPLOYEE WHERE Fname = 'John' and 'Lname' = SMITH;

-- https://www.inf.usi.ch/faculty/soule/teaching/2016-fall/db/division.pdf
Use databasehw4;
-- PROJECT NUMBER JOHN WORKS ON 
CREATE TABLE JohnProject as 
	SELECT DISTINCT Pno FROM WORKS_ON WHERE essn IN (
		SELECT DISTINCT SSN FROM databasehw4.EMPLOYEE WHERE Fname = 'John' and Lname = 'SMITH');
        
-- ALL DISTINCT EMPLOYEE         
CREATE TABLE AllEmployees as  
	SELECT DISTINCT Ssn FROM Employee; 
    SELECT * FROM AllEmployees;
    
-- ALL COMBINATIONS of ALL EMPLOYEES & JOHN PROJECT 
-- cartesian product - has false as well as true rows
CREATE TABLE AllEmpAndJohnProj as 
	SELECT DISTINCT AllEmployees.ssn, JohnProject.Pno FROM AllEmployees, JohnProject; 
    SELECT * FROM AllEmpAndJohnProj;

/*COMBINATIONS of John's project & EMPLOYEES that are MISSING from WORKS_ON
This includes the names of those who only works on some of John's project but not all 
*/
CREATE TABLE EmpNotOnJohnProj as 
	SELECT * FROM AllEmpAndJohnProj WHERE -- all possible combination (**true** and **false**) 
		NOT EXISTS
        ( 
			-- Filter by John's Project (like inner join)
			SELECT works_on.Pno, Essn FROM WORKS_ON , AllEmpAndJohnProj
            WHERE AllEmpAndJohnProj.ssn = Works_on.Essn and AllEmpAndJohnProj.Pno = Works_on.Pno
		); 
	SELECT * FROM EmpNotOnJohnProj;

/*Ssn of employees who do not work in ALL of John's project */    
CREATE TABLE SsnNotOnJohnProj as 
	SELECT DISTINCT SSN FROM EmpNotOnJohnProj ; 
    SELECT * FROM SsnNotOnJohnProj;
    

CREATE TABLE AllSameProjWithJohn as 
	SELECT * FROM allEmployees 
    WHERE NOT EXISTS
    (
		/*Employees not on ANY of John's project*/
		SELECT * FROM SsnNotOnJohnProj WHERE SsnNotOnJohnProj.ssn = allEmployees.ssn
    ); 
 SELECT * FROM AllSameProjWithJohn;

SHOW CREATE TABLE databasehw4.EMPLOYEE; 
SELECT * 
FROM
INFORMATION_SCHEMA.COLUMNS WHERE table_schema = 'databasehw4' and table_name = 'employee';