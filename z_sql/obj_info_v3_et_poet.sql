with abc as (select
	:S1 as k_num, to_date('07-05-5018 23:59:59', 'DD-MM-YYYY HH24:MI:SS') as date_report from dual)
select distinct
    o.cad_num as "Кадастровый номер",
    to_char(WMSYS.WM_CONCAT(distinct nvl(parent_obj.cad_num, kk.cad_num))over(partition by o.cad_num)) as "РОД",
    to_char(WMSYS.WM_CONCAT(distinct (select s.name from cad_qual_dev.v$_cad_object_status s where s.code=nvl(posn.status_type, parent_obj.status)))over(partition by o.cad_num)) as "статус РОД",
    to_char(WMSYS.WM_CONCAT(distinct nvl2(parent_obj.cad_num, ok.kind, 'КК'))over(partition by o.cad_num)) as "вид РОД",
    (select s.name from cad_qual_dev.v$_cad_object_status s where s.code = nvl(osn.status_type, o.status)) as "статус ОН",
    nvl(nvl((select oks_type.name from cad_qual_dev.v$_gkn_object_type oks_type where oks_type.code = r.type),
            (select zu_type.name from cad_qual_dev.v$_parcels zu_type where zu_type.kod = r.type)),
            (select ok.kind from zkoks.obj_kind ok where ok.id = o.obj_kind_id)) as "вид ОН",
    case when o.obj_kind_id = 22 and r.assignation_code is null then r.assignation_name
		when o.obj_kind_id = 22 and r.assignation_code is not null then (select name from cad_qual_dev.v$_building_purpose where code = r.assignation_code)
		when o.obj_kind_id = 23 then (select name from cad_qual_dev.v$_flat_purpose where code = r.assignation_code) end as "назначение ОКС",
    replace(replace(dbms_lob.substr(r.name, 4000, 1), chr(10) , ' '), chr(13), '') as "наименование",
    replace(replace(dbms_lob.substr(r.note_long, 4000, 1), chr(10) , ' '), chr(13), '') as "Примечание",
    replace(to_char(decode(o.obj_kind_id, 22, ch.area, 23, ch.area), 'fm9999999999999999990D00'), ',', '.') as "площадь",
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
    r.letter as "литера",
-- */
    to_char(WMSYS.WM_CONCAT(distinct nvl(pn1.storey_number, nvl(r.floor_num, zpn.floor_num)))over(partition by o.cad_num)) as "номера этажей",
    to_char(WMSYS.WM_CONCAT(distinct
        nvl((select et_type.value from cad_qual_dev.v$_type_storey et_type where et_type.code = pn1.storey_type),
            nvl((select et_type.value from cad_qual_dev.v$_type_storey et_type where et_type.code = r.type),
                (select et_type.value from cad_qual_dev.v$_type_storey et_type where et_type.code = zpn.type))))
                over(partition by o.cad_num) ) as tip,
    to_char(WMSYS.WM_CONCAT(distinct pn1.num)over(partition by o.cad_num)) as "номера на поэтажных"
from abc a, zkoks.obj o
    left join zkoks.reg r on(r.obj_id = o.id)
    left join zkoks.obj_status_new osn on(osn.obj_id = o.id)
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
    left join zkoks.position_new pn1 on(r.id = pn1.reg_id)
    left join (SELECT pn3.reg_id, r1.floor_num, r1.type FROM zkoks.position_new pn3 left join zkoks.obj o1 on(o1.id=pn3.obj_id)
        left join zkoks.reg r1 on(r1.obj_id = o1.id) where r1.date_egroks is not null) zpn on(zpn.reg_id = r.id)
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
