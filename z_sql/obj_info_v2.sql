with abc as (select
	:S1 as k_num, to_date('07-05-5018 23:59:59', 'DD-MM-YYYY HH24:MI:SS') as date_report from dual)
select distinct
    o.cad_num as "Кадастровый номер",
    nvl(parent_obj.cad_num, kk.cad_num) as "РОД",
    to_char(parent_obj.date_ins, 'YYYY-MM-DD') as "дата установления связи",
    (select s.name from cad_qual_dev.v$_cad_object_status s where s.code=nvl(posn.status_type, parent_obj.status)) as "статус РОД",
    nvl2(parent_obj.cad_num, ok.kind, 'КК') as "вид РОД",
    to_char(r.date_registered, 'YYYY-MM-DD') as "Дата постановки",
    to_char(r.date_canceled, 'YYYY-MM-DD') as "Дата снятия",
    (select s.name from cad_qual_dev.v$_cad_object_status s where s.code = nvl(osn.status_type, o.status)) as "статус ОН",
    nvl(nvl((select oks_type.name from cad_qual_dev.v$_gkn_object_type oks_type where oks_type.code = r.type),
            (select zu_type.name from cad_qual_dev.v$_parcels zu_type where zu_type.kod = r.type)),
            (select ok.kind from zkoks.obj_kind ok where ok.id = o.obj_kind_id)) as "вид ОН",
    (select cm.name from CAD_QUAL_DEV.V$_PARCEL_CREATE_METHOD cm where cm.code = r.method) as method,
    case when o.obj_kind_id = 22 and r.assignation_code is null then r.assignation_name
		when o.obj_kind_id = 22 and r.assignation_code is not null then (select name from cad_qual_dev.v$_building_purpose where code = r.assignation_code)
		when o.obj_kind_id = 23 then (select name from cad_qual_dev.v$_flat_purpose where code = r.assignation_code) end as "назначение ОКС",
    replace(replace(dbms_lob.substr(r.name, 4000, 1), chr(10) , ' '), chr(13), '') as "наименование",
    replace(replace(dbms_lob.substr(r.note_long, 4000, 1), chr(10) , ' '), chr(13), '') as "Примечание",
    p.value as "категория", u.doc as "РИ по док", reso.value as "РИ по класс", reso540.name as "РИ по 540 пр.", u.fact as "фактич. исп.", '|' as "||",
    replace(to_char(decode(o.obj_kind_id, 22, ch.area, 23, ch.area, 5, nvl(a009.value, a008.value)), 'fm9999999999999999990D00'), ',', '.') as "площадь",
    decode(nvl(a009.code, a008.code), '009', 'уточн', '008', 'деклар') as "тип площади ЗУ",
    replace(to_char(pa1.value, 'fm9999999999999999990D000'), ',', '.') as "КС",
    replace(to_char(pa2.value, 'fm9999999999999999990D000'), ',', '.') as "УПКС",
    (select count(distinct op1.id) from zkoks.obj_obj oo1 left join zkoks.obj op1 on(op1.id= oo1.obj_child_id)
        left join zkoks.obj_status_new osn1 on(osn1.obj_id = op1.id) where oo1.obj_parent_id=o.id
        and oo1.is_del=0 and op1.obj_kind_id=22 and oo1.status='02'
        and( (osn1.id=(select max(ss.id) from abc ab, zkoks.obj_status_new ss where ss.obj_id=op1.id and ss.status_date<ab.date_report
        and(ss.status_change_date is null or ss.status_change_date >= ab.date_report)) and osn1.status_type in('01','05','06'))
        or(osn1.id is null and op1.status in('01','05','06')) ) ) as "связанных ЗД/СООР/ОНС",
    (select count(distinct op2.id) from zkoks.obj_obj oo2 left join zkoks.obj op2 on(op2.id = oo2.obj_parent_id)
        left join zkoks.obj_status_new osn2 on(osn2.obj_id = op2.id) where oo2.obj_child_id=o.id
        and oo2.is_del=0 and op2.obj_kind_id=5 and oo2.status='02'
        and( (osn2.id=(select max(ss.id) from abc ab, zkoks.obj_status_new ss where ss.obj_id=op2.id and ss.status_date<ab.date_report
        and(ss.status_change_date is null or ss.status_change_date >= ab.date_report)) and osn2.status_type in('01','05','06'))
        or(osn2.id is null and op2.status in('01','05','06')) ) ) as "связанных ЗУ",
    case when exists(select ri.id from zkoks.right ri where ri.reg_id = r.id and ri.reg_date_end is null) then 'да' else 'нет' end as "права",
    case when exists(select e.id from zkoks.encumbrance e where e.reg_id = r.id and e.reg_date_end is null) then 'да' else 'нет' end as "обременения",
-- /* АДРЕС v2
    trim( nvl2(si.REGION, si.REGION, '')|| nvl2(si.DISTRICT, ', '||si.DISTRICT_TYPE||' '||si.DISTRICT, '')||
        nvl2(si.CITY, ', '||si.CITY_TYPE||' '||si.CITY, '')|| nvl2(si.URBAN_DISTRICT, ', '||si.URBAN_DISTRICT, '')||
        nvl2(si.SOVIET_VILLAGE, ', '||si.SOVIET_VILLAGE, '')|| nvl2(si.LOCALITY, ', '||si.LOCALITY_TYPE||' '||si.LOCALITY, '')||
        nvl2(si.STREET, ', '||si.STREET_TYPE||' '||si.STREET, '')|| nvl2(si.HOUSE, ', дом '||si.HOUSE, '')||
        nvl2(si.BUILDING, ', корп '||si.BUILDING, '')|| nvl2(si.STRUCTURE, ', стр '||si.STRUCTURE, '')||
        nvl2(si.APARTMENT, ', '||si.APARTMENT_TYPE||' '||si.APARTMENT, '')||
        nvl2(si.LOCALITY1, ', '||si.LOCALITY1_TYPE||' '||si.LOCALITY1, '') ) as "адрес КЛАДР",
    si.OTHER as "Иное",
    si.note as "адрес ДОК",
    r.letter as "литера"
-- */
from abc a, zkoks.obj o
    left join zkoks.reg r on(r.obj_id = o.id)
    left join zkoks.obj_status_new osn on(osn.obj_id = o.id)
    left join zkoks.category c on(c.reg_id = r.id)
    left join cad_qual_dev.v$_purpose_land p on(p.code = c.code)
    left join zkoks.utilization u on(u.reg_id = r.id)
    left join cad_qual_dev.v$_resolved_use reso on(reso.code = u.code)
    left join cad_qual_dev.v$_resolved_use_type_540 reso540 on(reso540.code = u.code540)
    left join zkoks.area_new a009 on(a009.reg_id = r.id and a009.code = '009')
    left join zkoks.area_new a008 on(a008.reg_id = r.id and a008.code = '008'
        and not exists(select a8.value from zkoks.area_new a8 where a8.reg_id = r.id and a8.code = '009'))
    left join zkoks.characteristic ch on(ch.reg_id = r.id)
    left join zkoks.site si on(si.parent_id = r.ID AND si.r$table_map_id = 7)
    left join zkoks.payment pa1 on(pa1.reg_id = r.id and pa1.code = '016010000000')
    left join zkoks.payment pa2 on(pa2.reg_id = r.id and pa2.code = '016011000000')
-- /* КАДАСТРОВЫЙ КВАРТАЛ
    left join (select oo.obj_child_id, o2.cad_num from zkoks.obj_obj oo left join zkoks.obj o2 on(oo.obj_parent_id=o2.id)
        where oo.is_del=0 and oo.status='02' and o2.obj_kind_id = 4 ) kk on(kk.obj_child_id=o.id)
-- */
-- /* РОДИТЕЛЬСКИЙ ОН v4
    left join (select distinct oo.obj_child_id, o2.id as p_id, o2.cad_num, o2.status, o2.obj_kind_id, oo.date_ins
        from abc aq, zkoks.obj_obj oo left join zkoks.obj o2 on(oo.obj_parent_id=o2.id)
        where oo.is_del=0 and oo.status='02' and o2.obj_kind_id in(5,22) and oo.date_ins<=aq.date_report
        ) parent_obj on(parent_obj.obj_child_id = o.id)
    left join zkoks.obj_kind ok on(ok.id = parent_obj.obj_kind_id)
    left join zkoks.obj_status_new posn on(posn.obj_id = parent_obj.p_id)
-- */
where
    r.id = (select max(rr.id) from abc aa, zkoks.reg rr where rr.obj_id = o.id and rr.date_egroks <= aa.date_report)
    and( (osn.id=(select max(ss.id) from abc ab, zkoks.obj_status_new ss where ss.obj_id=o.id and ss.status_date<ab.date_report
        and(ss.status_change_date is null or ss.status_change_date >= ab.date_report)) -- and osn.status_type in('01','05','06')
        ) or(osn.id is null -- and o.status in('01','05','06')
        ) )
    and( (posn.id=(select max(ss.id) from abc ab, zkoks.obj_status_new ss where ss.obj_id=parent_obj.p_id and ss.status_date<ab.date_report
        and(ss.status_change_date is null or ss.status_change_date >= ab.date_report)) )
        or posn.id is null )
    -- and osn.status_type in('01', '05', '06', '07', '08')
    -- and o.obj_kind_id in(5,22,23)
    -- and r.type in(
       -- '002002001000', -- 'Здание'
       -- '002002004000', -- 'Сооружение'
       -- '002002005000', -- 'Объект незавершенного строительства'
       -- '002002002000', -- 'Помещение'
       -- '002002004002', -- 'Условная часть линейного сооружения'
       -- '01', -- 'Землепользование'
       -- '02', -- 'Единое землепользование'
       -- '03', -- 'Обособленный участок'
       -- '04', -- 'Условный участок'
       -- '05'  -- 'Многоконтурный участок'
       -- )
    and o.cad_num like a.k_num
order by o.cad_num
