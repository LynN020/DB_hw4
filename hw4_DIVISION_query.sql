/* HW 4 - DIVISION QUERY
"Retrieve the SSNs of employees who work on all projects that John Smith works on"
Resource: https://www.inf.usi.ch/faculty/soule/teaching/2016-fall/db/division.pdf*/

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