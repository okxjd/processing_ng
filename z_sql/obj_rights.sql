with abc as (select	to_date('31-12-7017 23:59:59', 'DD-MM-YYYY HH24:MI:SS') as date_report from dual)
select distinct
    o.cad_num as "Кадастровый номер",
    substr(o.cad_num, 1, 5) as "район",
    (select s.name from cad_qual_dev.v$_cad_object_status s where s.code = nvl(osn.status_type, o.status)) as "статус ОН",
    nvl((select oks_type.name from cad_qual_dev.v$_gkn_object_type oks_type where oks_type.code = r.type),
        (select zu_type.name from cad_qual_dev.v$_parcels zu_type where zu_type.kod = r.type)) as "тип ОН",
    to_char(r.date_registered, 'YYYY-MM-DD') as "Дата постановки",
    to_char(r.date_canceled, 'YYYY-MM-DD') as "Дата снятия",
    nvl((select site.note from zkoks.site where site.parent_id = r.id and site.r$table_map_id = 7 and site.note is not null),
        (select v$_address_string.address from zkoks.v$_address_string where v$_address_string.parent_id = r.id and v$_address_string.r$table_map_id = 7)) as "адрес",
    '|' as "|",
    tr.value as "вид права",
    ri.name as "наименование",
    ri.reg_num as "основание права",
    to_char(ri.reg_date, 'yyyy-mm-dd') as "дата регистрации права",
 --   ri.reg_date_end,
    rr.atype as "вид правообладателя",
    rr.name as "правообладатель",
    xxx.address as "адрес из вкладки Права",
    nvl2(ri.numerator, ri.numerator||'/'||ri.denominator, '-') as "доля",
    ri.share_descr as "текстовое описание доли",
    rr.doc_name,rr.doc_number,rr.doc_date,rr.doc_issuer
from
    zkoks.obj o
    left join zkoks.obj_status_new osn on(osn.obj_id = o.id)
    left join zkoks.reg r on(r.obj_id = o.id)
    left join zkoks.right ri on(ri.reg_id = r.id and ri.reg_date_end is null)
    left join cad_qual_dev.v$_reg_item tr on(tr.code = ri.type)
    left join (select ff.id,ff.right_id, ff.last_name||' '||ff.first_name||' '||ff.middle_name as name, 'ФЛ' as atype,2 as atype2,
            dc.doc_name,dc.doc_number,to_char(dc.doc_date, 'YYYY-MM-DD') as doc_date,dc.doc_issuer
            from zkoks.right_owner_fl ff left join zkoks.doc dc on(dc.parent_id = ff.right_id and dc.r$table_map_id = 1)
        union select ss.id,ss.right_id, ss.name as name, 'СПП' as atype,999999 as atype2, dc.doc_name,dc.doc_number, to_char(dc.doc_date, 'YYYY-MM-DD') as doc_date,
            dc.doc_issuer from zkoks.right_owner_sub ss left join zkoks.doc dc on(dc.parent_id = ss.right_id and dc.r$table_map_id = 1)
        union select uu.id,uu.right_id, uu.name as name, 'ЮЛ' as atype,3 as atype2, dc.doc_name,dc.doc_number,to_char(dc.doc_date, 'YYYY-MM-DD') as doc_date,
            dc.doc_issuer from zkoks.right_owner_ul uu left join zkoks.doc dc on(dc.parent_id = uu.right_id and dc.r$table_map_id = 1)
        ) rr on(rr.right_id = ri.id)
    left join zkoks.v$_address_string xxx on(xxx.parent_id = rr.id and xxx.r$table_map_id = rr.atype2) -- ФЛ и ЮЛ
where
    r.id = (select max(rrz.id) from abc aa, zkoks.reg rrz where rrz.obj_id = o.id and rrz.date_egroks <= aa.date_report)
    and( (osn.id=(select max(ss.id) from abc ab, zkoks.obj_status_new ss where ss.obj_id=o.id and ss.status_date<ab.date_report
        and(ss.status_change_date is null or ss.status_change_date >= ab.date_report)) )
        or osn.id is null )
    and o.obj_kind_id in(22, 23, 5)
    and r.type in(
        '002002001000', -- 'Здание'
        '002002004000', -- 'Сооружение'
        '002002005000', -- 'Объект незавершенного строительства'
        '002002002000', -- 'Помещение'
        '002002004002', -- 'Условная часть линейного сооружения'
        '01', -- 'Землепользование'
        '02', -- 'Единое землепользование'
        '05') -- 'Многоконтурный участок'
    and o.cad_num like :S1
order by o.cad_num

