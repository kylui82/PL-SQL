--Q1

/*
A PL/SQL is needed to calculate annual raises and update employee salary amounts recorded in the EMP table. Create a block that addresses the requirements below. Note that all salaries in EMP table are recorded as monthly amounts. Display the calculated salaries for verification before the update action.

Calculate 5% annual raises for all employees except AD_VP.
If the 5% totals to more than 2000, cap the raise to 2000.
Update the salary for each employee in the table.
For each employee display the current annual salary, raise, and proposed new annual salary.
At the end, show the total amount of salary increase.
NOTE: Create the table EMP as a copy of Employee table as follow:

 Create table emp (empno, ename, sal,job) 

 as (select employee_id,first_name||' '||last_name,salary,job_id from employees)

Your output looks similar to the following:

PL/SQL procedure successfully completed.

100 Steven Ring 288000 2000 290000

101 Neena Kochhar 204000 2000 206000

102 Lex De Haan 204000 2000 206000

....

204 Herman Baer 120000 2000 122000

205 Shelley Higgins 144000 2000 146000

206 William Gietz 99600 2000 101600

Overall Cost: 201880
*/



--Create table emp (empno, ename, sal,job) as (select employee_id,first_name||' '||last_name,salary,job_id from employees);
--drop table emp;

declare
v_old emp.sal%type;
v_new emp.sal%type;
v_raise emp.sal%type;
v_total emp.sal%type := 0;
--declare cursor to find all employees except AD_VP
cursor cur_emp is 
select * from emp where not job = 'AD_VP' order by empno for update nowait;
begin
for v_emp in cur_emp 
loop
v_old := v_emp.sal * 12; -- from monthly salary to annual salary
v_raise := v_old * 0.05;
    if v_raise >= 2000 then --check if the 5% totals is more than 2000
        v_raise := 2000; --if yes, set raise to 2000
    end if;
v_new := v_raise + v_old; --calculate the new salary
v_total := v_total + v_raise; --calculate total amount of salary increase for all employees
update emp set sal = v_new / 12 where current of cur_emp; --update the monthly salary
dbms_output.put_line(v_emp.empno || ' ' || v_emp.ename || ' ' || v_old || ' ' || v_raise || ' ' || v_new);
end loop;
dbms_output.put_line('Overall Cost: ' || v_total);
end;

select * from emp;


--Q2
/*
Write and run a PL/SQL block that produces a report of employee info (employee_id, employee first and last name, employee's department name) by their locations. Use EMPLOYEES, DEPARTMENTS, and LOCATIONS tables. Examine table relations as needed.

1.List the employees by the location they are in. 
2.List the locations with employees at the top, followed by all the locations with no employees or departments.
3.For a location where there are no departments or employees, print a custom message 'no employees or offices'

Your output will look like following:

8204 Arthur St , London, UK

203 Susan Mavris - Human Resources

Magdalen Centre, The Oxford Science Park OX9 9ZB, Oxford, UK

145 John Russell - Sales

146 Karen Partners - Sales

147 Alberto Errazuriz - Sales

.....

1298 Vileparle (E) 490231, Bombay, IN

no employees or offices

12-98 Victoria Street 2901, Sydney, AU

no employees or offices

198 Clementi North 540198, Singapore, SG

no employees or offices
*/

declare
v_count number;
v_temp departments.department_id%type;
--join locations and departments table for the cursor to list the locations
cursor cur_loc is 
    select l.location_id,street_address,postal_code, city,country_id, d.department_id  from locations l left outer join departments d 
    on l.location_id = d.location_id order by d.location_id;
----join employees and departments table for the cursor to list the all employees in paarticular department
cursor cur_emp(p_dept departments.department_id%type) is 
    select * from departments d inner join employees e on e.department_id = d.department_id where p_dept =  e.department_id;
begin
for v_loc in cur_loc 
loop
--check if this row's location is the same as previous row's location. if yes, keep looping the employees
if v_temp = v_loc.location_id then
    for e in cur_emp(v_loc.department_id)
    loop
    dbms_output.put_line(e.employee_id || ' ' || e.first_name || ' ' || e.last_name || ' - ' || e.department_name);
    end loop;          
else
--print new location data if the location is different then the previous one
dbms_output.new_line;
dbms_output.put_line(v_loc.street_address || ' ' || v_loc.postal_code || ' ' || v_loc.city || ' ' || v_loc.country_id);
        --if no department, print no 
        if v_loc.location_id is not null and v_loc.department_id is null then
            dbms_output.put_line('no employees or offices');
        else 
            --if have department, print employees data 
            for e in cur_emp(v_loc.department_id)
            loop
            dbms_output.put_line(e.employee_id || ' ' || e.first_name || ' ' || e.last_name || ' - ' || e.department_name);
            end loop;
        end if;
        v_temp := v_loc.location_id;
end if;

end loop;
end;


--q3
/*
Write and run a PL/SQL block which produces a report of employee info (employee_id, employe first and last name, employee's department_id, manager (manager name)). Use EMPLOYEES tables. List the employees by their employee id

Your output will look like follow:

...

Employee 202 Pat Fay - Manager: Michael Hartstein

Employee 203 Susan Mavris - Manager: Susan Mavris

...
*/

declare 
-- self join employees table for the cursor to list the employees and managers
cursor cur_emp is
select e.employee_id, e.first_name || ' ' || e.last_name as employee_name, 
e.department_id, m.first_name || ' ' || m.last_name as manager_name
from employees e join employees m on m.employee_id = e.manager_id order by e.employee_id;
begin
--print the output
for v in cur_emp
loop
dbms_output.put_line('Employee ' || v.employee_id  || ' ' || v.employee_name  || ' - ' ||
'Manager:'  || ' ' || v.manager_name);
end loop;
end;


--q4
/*
In this Practice you will INSERT and later UPDATE rows in a new table: PROPOSED_RAISES, which will store details of salary increases proposed for suitable employees. Use cursor FOR UPDATE

Create this table by executing the following SQL statement: 

CREATE TABLE proposed_raises 

(date_proposed DATE, 

date_approved DATE, 

employee_id NUMBER(6), 

department_id NUMBER(4), 

original_salary NUMBER(8,2), 

proposed_new_salary NUMBER(8,2)); 


Write a PL/SQL block that inserts a row into PROPOSED_RAISES for each eligible employee. The eligible employees are those whose salary is below a chosen value. The chosen salary value is passed as a parameter to the cursor. For each eligible employee, insert a row into PROPOSED_RAISES with date_proposed = today’s date, date_appoved is null (use NULL keyword), and proposed_new_salary 5% greater than the current salary. The cursor should LOCK the employees rows so that no one can modify the employee data while the cursor is open. Test your code using a chosen salary value of 5000. 
SELECT from the PROPOSED_RAISES table to see the results of your INSERT statements. If you run your block in question 1 more than once, make sure the PROPOSED_RAISES table is empty before each run using DELETE FROM proposed_raises; -- to clear all rows from the table 
Imagine these proposed salary increases have been approved by company management. Write and execute a PL/SQL block to read each row from the PROPOSED_RAISES table. For each row, UPDATE the date_approved column with today’s date. Use the WHERE CURRENT OF... syntax to UPDATE each row. After running your code, SELECT from the PROPOSED_RAISES table to view the updated data. 

*/


declare
--define cursor that find the employees' salary lower than the cohose amount in parameter
cursor cur_emp(p_sal employees.salary%type) is
select employee_id,department_id,salary from employees where salary < p_sal for update nowait;
begin
for v in cur_emp(5000)
loop
--insert the data with today date and propsed salary
insert into proposed_raises values 
(current_date,null,v.employee_id,v.department_id,v.salary, v.salary*1.05);
end loop;
end;


declare
cursor cur_emp is
--define cursor that find the employees in proposed_raises table
select * from proposed_raises for update nowait;
begin
for v in cur_emp
loop
--update the date approved as today for each employee
update proposed_raises 
set date_approved = current_date 
where current of cur_emp;
end loop;
end;

select * from proposed_raises;