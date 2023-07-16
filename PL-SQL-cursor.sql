Write and run a PL/SQL block which produces a report listing world regions (region_name), countries (country_id, country_name) in those regions.  

Restrict your regions to those in the North/South Americas
You will need two cursors: an outer loop cursor which fetches and displays rows (region_name) from the REGIONS table, and an inner loop cursor which fetches and displays rows (country_id, country_name) from the COUNTRIES table for countries in that region, passing the region_id as a parameter. 
Order your region output by region_name in descending order
Submit your code below as well as a screenshots of your execution result

Your output should look something like follow (only first a few rows shown):

South America

-----------------------------

AR	Argentina

BR Brazil

....



North America

-----------------------------

CA	Canada

MX	Mexico



...
*/


declare
cursor cur_reg is 
  select distinct r.region_id, r.region_name
  from regions r inner join countries c
  on r.region_id = c.region_id 
  where r.region_name like '%America%' order by region_name desc;
cursor cur_cou(p_region_id regions.region_id%type) is 
  select country_id, country_name from countries 
  where region_id = p_region_id;
begin
for v_re in cur_reg
loop
dbms_output.put_line(v_re.region_name);
dbms_output.put_line('--------------');
  begin
  for v_cou in cur_cou(v_re.region_id)
  loop
  dbms_output.put_line (v_cou.country_id || ' '|| v_cou.country_name);
  end loop;
  dbms_output.new_line;
  end;
end loop;
end;
