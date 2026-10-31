DO $$ BEGIN IF to_regprocedure('public.school_claim_admin(text)') IS NOT NULL THEN EXECUTE 'revoke all on function public.school_claim_admin(text) from authenticated,anon,public'; END IF; END $$;
