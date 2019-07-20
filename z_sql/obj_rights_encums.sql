with abc as (select	to_date('30-01-4019 23:59:59', 'DD-MM-YYYY HH24:MI:SS') as date_report from dual)
select distinct
    o.cad_num as "Кадастровый номер",
    (select s.name from cad_qual_dev.v$_cad_object_status s where s.code = nvl(osn.status_type, o.status)) as "статус ОН",
    nvl((select oks_type.name from cad_qual_dev.v$_gkn_object_type oks_type where oks_type.code = r.type),
        (select zu_type.name from cad_qual_dev.v$_parcels zu_type where zu_type.kod = r.type)) as "тип ОН",
    '|' as "|", 'право' as "T",
    tr.value as "Вид права",
    ri.name as "наименование",
    ri.reg_num as "Основание права",
    nvl2(ri.numerator, ri.numerator||'/'||ri.denominator, '-') as "доля",
    ri.share_descr as "текстовое описание доли",
    to_char(ri.reg_date, 'YYYY-MM-DD') as "Дата регистрации права", to_char(ri.reg_date_end, 'YYYY-MM-DD') as "Дата прекращения права",
    rr.name as "Правообладатель", rr.snils, rr.inn, rr.email, xxx.address as "адрес из вкладки Права",
    '' as "длительность", '' as "содержание"
from
    zkoks.obj o
    left join zkoks.reg r on(r.obj_id = o.id)
    left join zkoks.right ri on(ri.reg_id = r.id and ri.reg_date_end is null)
    left join (select id,right_id, 'ФЛ: '||last_name||' '||first_name||' '||middle_name name, snils, inn, '' as email, 2 as atype from zkoks.right_owner_fl
        union select id,right_id, 'СПП: '||name name, '' as snils, '' as inn, '' as email, 999999 as atype from zkoks.right_owner_sub
        union select id,right_id, 'ЮЛ: '||name name, '' as snils, inn, email, 3 as atype from zkoks.right_owner_ul) rr on(rr.right_id = ri.id)
    left join cad_qual_dev.v$_reg_item tr on(tr.code = ri.type)
    left join zkoks.v$_address_string xxx on(xxx.parent_id = rr.id and xxx.r$table_map_id = rr.atype ) -- ФЛ и ЮЛ
    left join zkoks.obj_status_new osn on(osn.obj_id = o.id)
where
    r.id = (select max(rr.id) from abc aa, zkoks.reg rr where rr.obj_id = o.id and rr.date_egroks <= aa.date_report)
    and( (osn.id=(select max(ss.id) from abc ab, zkoks.obj_status_new ss where ss.obj_id=o.id and ss.status_date<ab.date_report
        and(ss.status_change_date is null or ss.status_change_date >= ab.date_report)) )
        or osn.id is null )
    and ri.id is not null
    and o.cad_num like :S1
union
select distinct
    o.cad_num as "Кадастровый номер",
    (select s.name from cad_qual_dev.v$_cad_object_status s where s.code = nvl(osn.status_type, o.status)) as "статус ОН",
    nvl((select oks_type.name from cad_qual_dev.v$_gkn_object_type oks_type where oks_type.code = r.type),
        (select zu_type.name from cad_qual_dev.v$_parcels zu_type where zu_type.kod = r.type)) as "тип ОН",
    '|' as "|", 'обременение' as "T",
    te.value as "Вид обременения",
    e.name as "наименование",
    e.reg_num as "Основание обременения",
    '','',
    to_char(e.reg_date, 'YYYY-MM-DD') as "Дата регистрации обрем", to_char(e.reg_date_end, 'YYYY-MM-DD') as "Дата прекращения права",
    ee.name as "Правообладатель (обрем)", ee.snils, ee.inn, ee.email, yyy.address as "адрес из вкладки Обрем",
    e.duration as "длительность", e.encumbrance_content as "содержание"
from
    zkoks.obj o
    left join zkoks.reg r on(r.obj_id = o.id)
    left join zkoks.encumbrance e on(e.reg_id = r.id and e.reg_date_end is null)
    left join (select id,encumbrance_id, 'ФЛ: '||last_name||' '||first_name||' '||middle_name name, snils, inn, '' as email, 5 as atype from zkoks.encum_owner_fl
        union select id,encumbrance_id, 'СПП: '||name name, '' as snils, '' as inn, '' as email, 999999 as atype from zkoks.encum_owner_sub
        union select id,encumbrance_id, 'ЮЛ: '||name name, '' as snils, inn, email, 6 as atype from zkoks.encum_owner_ul) ee on(ee.encumbrance_id = e.id)
    left join cad_qual_dev.v$_servitut_type te on(te.code = e.code)
    left join zkoks.v$_address_string yyy on(yyy.parent_id = ee.id and yyy.r$table_map_id = ee.atype ) -- ФЛ и ЮЛ
    left join zkoks.obj_status_new osn on(osn.obj_id = o.id)
where
    r.id = (select max(rr.id) from abc aa, zkoks.reg rr where rr.obj_id = o.id and rr.date_egroks <= aa.date_report)
    and( (osn.id=(select max(ss.id) from abc ab, zkoks.obj_status_new ss where ss.obj_id=o.id and ss.status_date<ab.date_report
        and(ss.status_change_date is null or ss.status_change_date >= ab.date_report)) )
        or osn.id is null )
    and e.id is not null
    and o.cad_num like :S1
order by 1
