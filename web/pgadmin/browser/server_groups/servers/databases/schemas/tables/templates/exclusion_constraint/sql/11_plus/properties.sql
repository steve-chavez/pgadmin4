SELECT cls.oid,
    cls.relname as name,
    indnkeyatts as col_count,
    amname,
    CASE WHEN length(spcname::text) > 0 THEN spcname ELSE
        (SELECT sp.spcname FROM pg_database dtb
        JOIN pg_catalog.pg_tablespace sp ON dtb.dattablespace=sp.oid
        WHERE dtb.oid = {{ did }}::oid)
    END as spcname,
    CASE contype
        WHEN 'p' THEN desp.description
        WHEN 'u' THEN desp.description
        WHEN 'x' THEN desp.description
        ELSE des.description
    END AS comment,
    condeferrable,
    condeferred,
    substring(pg_catalog.array_to_string(cls.reloptions, ',') from 'fillfactor=([0-9]*)') AS fillfactor,
    pg_catalog.pg_get_expr(idx.indpred, idx.indrelid, true) AS indconstraint
FROM pg_catalog.pg_index idx
JOIN pg_catalog.pg_class cls ON cls.oid=indexrelid
LEFT OUTER JOIN pg_catalog.pg_tablespace ta on ta.oid=cls.reltablespace
JOIN pg_catalog.pg_am am ON am.oid=cls.relam
LEFT JOIN pg_catalog.pg_depend dep ON (dep.classid = cls.tableoid AND dep.objid = cls.oid AND dep.refobjsubid = '0' AND dep.refclassid=(SELECT oid FROM pg_catalog.pg_class WHERE relname='pg_constraint') AND dep.deptype='i')
LEFT OUTER JOIN pg_catalog.pg_constraint con ON (con.tableoid = dep.refclassid AND con.oid = dep.refobjid)
LEFT OUTER JOIN pg_catalog.pg_description des ON (des.objoid=cls.oid AND des.classoid='pg_class'::regclass)
LEFT OUTER JOIN pg_catalog.pg_description desp ON (desp.objoid=con.oid AND desp.objsubid = 0 AND desp.classoid='pg_constraint'::regclass)
WHERE indrelid = {{tid}}::oid
{% if cid %}
AND cls.oid = {{cid}}::oid
{% endif %}
AND contype='x'
ORDER BY cls.relname
