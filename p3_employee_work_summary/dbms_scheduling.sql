BEGIN
    -- drop existing job if it exists
    BEGIN
        DBMS_SCHEDULER.DROP_JOB(job_name => 'weekly_hours_worked_report');
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;

    -- create scheduled job
    DBMS_SCHEDULER.create_job (
        job_name => 'weekly_hours_worked_report',
        job_type => 'STORED_PROCEDURE',
        job_action => 'weekly_employee_work_summary',
        start_date => SYSTIMESTAMP,
        repeat_interval => 'FREQ=WEEKLY; BYDAY=MON; BYHOUR=0; BYMINUTE=0; BYSECOND=0',
        enabled => TRUE,
        comments => 'Weekly report of employee work hours'
    );

    -- set job parameters
    DBMS_SCHEDULER.set_job_argument_value (
        job_name => 'weekly_hours_worked_report',
        argument_position => 'p_manual_run',
        argument_value => FALSE
    );

    -- enable logging
    DBMS_SCHEDULER.set_attribute (
        name => 'weekly_hours_worked_report',
        attribute => 'logging_level',
        value => DBMS_SCHEDULER.LOGGING_FULL
    );

END;
/