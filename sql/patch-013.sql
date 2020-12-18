-- Added missing index for finding plan optimizations

BEGIN;
    CREATE INDEX plans_optimization_for on plans (optimization_for) where not is_deleted;
COMMIT;
