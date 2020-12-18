-- Added support for queries for plans

BEGIN;
    ALTER TABLE public.plans add column query TEXT;

CREATE OR REPLACE FUNCTION public.register_plan(in_title text, in_plan text, in_is_public boolean, in_is_anonymized boolean, in_username text, in_optimization_for text, in_query TEXT)
 RETURNS register_plan_return
 LANGUAGE plpgsql
AS $function$
DECLARE
    use_hash_length int4 := 2;
    reply register_plan_return;
    insert_sql TEXT;
BEGIN
    insert_sql := 'INSERT INTO public.plans (id, title, plan, is_public, entered_on, is_anonymized, delete_key, added_by, optimization_for, query) VALUES ($1, $2, $3, $4, now(), $5, $6, $7, $8, $9 )';
    reply.delete_key := get_random_string( 50 );
    LOOP
        reply.id := get_random_string(use_hash_length);
        BEGIN
            execute insert_sql using reply.id, in_title, in_plan, in_is_public, in_is_anonymized, reply.delete_key, in_username, in_optimization_for, in_query;
            RETURN reply;
        EXCEPTION WHEN unique_violation THEN
            -- do nothing
        END;
        use_hash_length := use_hash_length + 1;
        IF use_hash_length >= 30 THEN
            raise exception 'Random string of length == 30 requested. something''s wrong.';
        END IF;
    END LOOP;
END;
$function$;

commit;
