SELECT  pg_proc.oid,
        proname AS name,
        pronargs,
        proallargtypes,
        proargnames AS argnames,
        pronargdefaults,
        oidvectortypes(proargtypes) AS proargtypenames,
        proargmodes,
        proargnames,
        pg_catalog.pg_get_expr(proargdefaults, 'pg_catalog.pg_class'::regclass) AS proargdefaultvals,
        pg_catalog.pg_get_userbyid(proowner) AS funcowner,
        pg_catalog.pg_get_function_result(pg_proc.oid) AS prorettypename,
        prosrc,
        lanname,
        CASE
        WHEN proaccess = '+' THEN 'Public'
        WHEN proaccess = '-' THEN 'Private'
        ELSE 'Unknown' END AS visibility
FROM pg_catalog.pg_proc, pg_catalog.pg_namespace, pg_catalog.pg_language lng
WHERE protype = '1'::char
AND pronamespace = {{pkgid}}::oid
AND pg_proc.pronamespace = pg_namespace.oid
AND lng.oid=prolang
{% if edbfnid %}
AND pg_proc.oid = {{edbfnid}}::oid
{% endif %}
  ORDER BY name
