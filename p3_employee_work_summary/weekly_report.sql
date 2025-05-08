CREATE OR REPLACE PROCEDURE weekly_employee_work_summary(
    p_week_start_date DATE,
    p_week_end_date DATE,
    p_department_id NUMBER DEFAULT NULL,
    p_manual_run BOOLEAN DEFAULT FALSE
)
AS 
    v_start_date Date;
    v_end_date Date;
BEGIN
    -- calculate previous week dates for scheduled report
    IF NOT p_manual_run THEN
        v_end_date := TRUNC(SYSDATE, 'IW') - 1;  -- sunday
        v_start_date := v_end_date - 6;          -- monday prior
    ELSE
        -- use provided dates for manual run case
        v_start_date := NVL(p_start_date, TRUNC(SYSDATE, 'IW') - 7);
        v_end_date := NVL(p_end_date, TRUNC(SYSDATE, 'IW') - 1);
    END IF;

    -- log scheduled job run
    INSERT INTO job_execution_log (
        job_name,
        exe_date,
        start_date,
        end_date,
        status,
    ) VALUES (
        'weekly_hours_report',
        SYSDATE
        v_start_date,
        v_end_date,
        'STARTED',
    )

    -- drop existing permanent summary table
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE employee_work_summary';
    EXCEPTION
        WHEN OTHERS THEN
            NULL; -- OK if table does not exist
    END;

    -- create new summary table
    EXECUTE IMMEDIATE 'CREATE TABLE employee_work_summary AS
        SELECT 
            :week_start_date AS week_start_date,
            :week_end_date AS week_end_date,
            e.employee_id,
            e.first_name,
            e.last_name,
            d.department_name,
            SUM(w.hours_worked) AS total_hours_worked,
            SUM(w.hours_worked) / 40 * 100 AS percent_relative_to_FTE
        FROM employees e
        LEFT JOIN work_hours w 
            ON e.employee_id = w.employee_id
            AND w.work_date BETWEEN :week_start_date AND :week_end_date
        LEFT JOIN departments d 
            ON e.department_id = d.department_id
        WHERE w.work_date BETWEEN v_start_date AND v_end_date
        AND (p_department_id IS NULL OR e.department_id = p_department_id)
        GROUP BY e.employee_id, e.first_name, e.last_name, e.department_id
        ORDER BY total_hours_worked DESC'

    -- bind variables to usage in SQLquery
    USING v_start_date, v_end_date, v_start_date, v_end_date;
        
    COMMIT;

-- log errors separately
EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO job_error_log (
            job_name,
            exe_date,
            start_date,
            end_date,
            status,
            error_code,
            error_message
        ) VALUES (
            'weekly_hours_report',
            SYSDATE,
            v_start_date,
            v_end_date,
            'FAILED',
            SQLCODE,
            SQLERRM
        );
        RAISE;
END weekly_employee_work_summary;
/