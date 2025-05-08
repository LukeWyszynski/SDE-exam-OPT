## Assumptions

Oracle DB Existing Tables:

Data:
- `employees` table: 
        employee_id
        department_id
        first_name
        last_name
- `departments` table:
        department_id
        department_name
- `work_hours` table: 
        employee_id
        hours_worked
        work_date

Logging:
- `job_execution_log` 
        log_id,
        job_name,
        exe_date,
        start_date,
        end_date,
        status
- `job_error_log`
        log_id,
        job_name,
        exe_date,
        start_date,
        end_date,
        status,
        error_code,
        error_message

## Dependencies 

1. PL/SQL
2. Oracle DB

