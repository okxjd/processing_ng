select distinct
    o.cad_num,
    s.name as status,
    pa.name as tip,
    (select p.value from cad_qual_dev.v$_purpose_land p where p.code = c.code) as categ,
    d.doc_name as doc_name,
    d.doc_number as doc_number,
    d.doc_issuer as doc_issuer,
    to_char(d.doc_date, 'YYYY-MM-DD') as doc_date,
    u.doc as ri_doc,
    d2.doc_name as ri_doc_name,
    d2.doc_number as ri_doc_number,
    d2.doc_issuer as ri_doc_issuer,
    to_char(d2.doc_date, 'YYYY-MM-DD') as ri_doc_date
  --  , d2.r$table_map_id
from
    zkoks.obj o
    left join zkoks.reg r on(r.obj_id = o.id)
    left join cad_qual_dev.v$_cad_object_status s on(s.code = o.status)
    left join cad_qual_dev.v$_parcels pa on(pa.kod = r.type)
    left join zkoks.category c on(c.reg_id = r.id)
    left join zkoks.doc d on(d.parent_id = c.id and d.r$table_map_id = 8) -- документ о категории ЗУ
    left join zkoks.utilization u on(u.reg_id = r.id)
    left join zkoks.doc d2 on(d2.parent_id = u.id and d2.r$table_map_id = 9) -- документ о РИ-док
where
r.id=nvl((select max(id) from zkoks.reg where obj_id = o.id and date_egroks is not null), (select max(id) from zkoks.reg where obj_id = o.id))
and o.cad_num like :S1
