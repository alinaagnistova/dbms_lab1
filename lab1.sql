create or replace procedure all_tables(curr_user text, target_uer text)
        language plpgsql
as
    $$
    DECLARE
    table_name TEXT;
    count INT := 1;
    has_tables BOOLEAN := FALSE;
    target_user_exists BOOLEAN;
    BEGIN
    RAISE NOTICE 'Текущий пользователь: %', curr_user;
    RAISE NOTICE 'Кому выдаём права доступа: %', target_user;
    SELECT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = target_user) INTO target_user_exists;
    IF NOT target_user_exists THEN
    RAISE NOTICE 'Пользователя для выдачи прав не существует';
        RETURN;
    END IF;
    RAISE NOTICE 'No. Имя таблицы';
    RAISE NOTICE '--- -------------------------';
    FOR table_name IN
        FROM pg_tables
        WHERE schemaname = curr_user
            AND(
        -- Проверка является ли текущий пользователь владельцем таблицы
                EXISTS(
                    SELECT 1
                    FROM pg_class c
                    JOIN pg_roles r ON c.relowner = r.oid
                    WHERE c.relname = pg_tables.tablename
                    AND r.rolname = curr_user
            )
                OR EXISTS (
                    SELECT 1
                    FROM information_schema.role_table_grants g
                    WHERE g.grantee = curr_user
                        AND g.privilege_type = 'GRANT OPTION'
                        AND g.table_name = pg_tables.tablename
                        AND g.table_schema = pg_tables.schemaname
            )
        )
    LOOP
        RAISE NOTICE '% %', count, table_name;
        count := count + 1;
        has_tables := TRUE;
    END LOOP;
    IF NOT has_tables THEN
        RAISE NOTICE 'таблиц не найдено';
    END IF;
END
$$




