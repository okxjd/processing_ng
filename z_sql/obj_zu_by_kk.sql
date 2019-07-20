with abc as (select	:S1 as k_num,
    to_date('27-11-5017 23:59:59', 'DD-MM-YYYY HH24:MI:SS') as date_report from dual)
select distinct
    kk.cad_num as "КК",
    substr(kk.cad_num, 7) as "часть КК",
    o.cad_num as "КН",
    to_char(r.date_registered, 'YYYY-MM-DD') as "Дата постановки",
    (select s.name from cad_qual_dev.v$_cad_object_status s where s.code = nvl(osn.status_type, o.status)) as "статус",
    (select zu_type.name from cad_qual_dev.v$_parcels zu_type where zu_type.kod = r.type) as "тип",
    (select p.value from cad_qual_dev.v$_purpose_land p where p.code = c.code) as "категория",
    u.doc as "РИ по док",
    replace(to_char(decode(o.obj_kind_id, 5, nvl(a009.value, a008.value)),'fm9999999999999999990D00'),',','.') as area,
    decode(nvl(a009.code, a008.code), '009', 'уточн', '008', 'деклар') as zu_area_type,
    NVL(si.note, aa.address) as "адрес",

    kkp.cad_num as "КК ЕЗ",
    substr(kkp.cad_num, 7) as "часть КК ЕЗ",
    parent_kn.cad_num as "КН ЕЗ",
    (select s.name from cad_qual_dev.v$_cad_object_status s where s.code = parent_kn.status) as "статус ЕЗ",
    (select zu_type.name from cad_qual_dev.v$_parcels zu_type where zu_type.kod = parent_kn.type) as "тип ЕЗ",
    (select p.value from cad_qual_dev.v$_purpose_land p where p.code = parent_kn.categ) as "категория ЕЗ"
from
	abc a,
    zkoks.obj o
    left join zkoks.reg r on(r.obj_id = o.id)
    left join zkoks.obj_status_new osn on(osn.obj_id = o.id)
    left join zkoks.category c on(c.reg_id = r.id)
    left join zkoks.utilization u on(u.reg_id = r.id)
    left join zkoks.site si on(si.parent_id = r.ID AND si.r$table_map_id = 7)
    left join zkoks.v$_address_string aa on(aa.parent_id = r.ID AND aa.r$table_map_id = 7)
    left join zkoks.area_new a009 on(a009.reg_id = r.id and a009.code = '009')
    left join zkoks.area_new a008 on(a008.reg_id = r.id and a008.code = '008'
        and not exists(select a8.value from zkoks.area_new a8 where a8.reg_id = r.id and a8.code = '009'))
        
    left join (select oo.obj_child_id, o2.cad_num from zkoks.obj_obj oo left join zkoks.obj o2 on(oo.obj_parent_id=o2.id)
        where oo.is_del=0 and oo.status='02' and o2.obj_kind_id=4
        ) kk on(kk.obj_child_id=o.id)

    left join (select oo.obj_child_id, o2.id, o2.cad_num, o2.status, r2.type, cp.code as categ
        from zkoks.obj_obj oo left join zkoks.obj o2 on(oo.obj_parent_id = o2.id)
        left join zkoks.reg r2 on(r2.obj_id = o2.id) left join zkoks.category cp on(cp.reg_id = r2.id)
        where oo.is_del = 0 and oo.status = '02' and o2.status in('01', '05', '06', '07')
        and o2.obj_kind_id = 5 and r2.type='02' -- ЕЗ
        and r2.id = (select max(rr.id) from abc aa, zkoks.reg rr where rr.obj_id = o2.id and rr.date_egroks <= aa.date_report)
        ) parent_kn on(parent_kn.obj_child_id = o.id)
    left join (select oo.obj_child_id, o2.cad_num from zkoks.obj_obj oo left join zkoks.obj o2 on(oo.obj_parent_id=o2.id)
        where oo.is_del=0 and oo.status='02' and o2.obj_kind_id=4
        ) kkp on(kkp.obj_child_id=parent_kn.id)
where
    r.id = (select max(rr.id) from abc aa, zkoks.reg rr where rr.obj_id = o.id and rr.date_egroks <= aa.date_report)
    and osn.id = (select max(osn1.id) from abc aa, zkoks.obj_status_new osn1 where osn1.obj_id = osn.obj_id and osn1.status_date <= aa.date_report)
    and( (osn.id=(select max(ss.id) from abc ab, zkoks.obj_status_new ss where ss.obj_id=o.id and ss.status_date<ab.date_report
        and(ss.status_change_date is null or ss.status_change_date >= ab.date_report)) )
        or osn.id is null )
    and o.obj_kind_id = 5
    and r.type in('01', '02', '03', '04', '05') -- ЗУ
    and kk.cad_num like a.k_num
order by o.cad_num
