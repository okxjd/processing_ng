select distinct
    o.cad_num as "КН ЗД",
    to_char(r.date_registered, 'YYYY-MM-DD') as "дата постановки ЗД",
    to_char(r.date_canceled, 'YYYY-MM-DD') as "дата снятия ЗД",
    s.name as "статус ЗД",
    pa.name as "тип ЗД",
    case
        when o.obj_kind_id = 22 and r.assignation_code is null then r.assignation_name
        when o.obj_kind_id = 22 and r.assignation_code is not null then (select name from cad_qual_dev.v$_building_purpose where code = r.assignation_code) 
        when o.obj_kind_id = 23 then (select name from cad_qual_dev.v$_flat_purpose where code = r.assignation_code)
    end as "назначение ЗД",
    r.name as "наименование ЗД",
    replace(to_char(ch.area, 'fm9999999999999999990D00'), ',', '.') as "площадь ЗД",
-- /* АДРЕС v2
    trim( nvl2(si.REGION, si.REGION, '')|| nvl2(si.DISTRICT, ', '||si.DISTRICT_TYPE||' '||si.DISTRICT, '')||
        nvl2(si.CITY, ', '||si.CITY_TYPE||' '||si.CITY, '')|| nvl2(si.URBAN_DISTRICT, ', '||si.URBAN_DISTRICT, '')||
        nvl2(si.SOVIET_VILLAGE, ', '||si.SOVIET_VILLAGE, '')|| nvl2(si.LOCALITY, ', '||si.LOCALITY_TYPE||' '||si.LOCALITY, '')||
        nvl2(si.STREET, ', '||si.STREET_TYPE||' '||si.STREET, '')|| nvl2(si.HOUSE, ', дом '||si.HOUSE, '')||
        nvl2(si.BUILDING, ', корп '||si.BUILDING, '')|| nvl2(si.STRUCTURE, ', стр '||si.STRUCTURE, '')||
        nvl2(si.APARTMENT, ', '||si.APARTMENT_TYPE||' '||si.APARTMENT, '')||
        nvl2(si.LOCALITY1, ', '||si.LOCALITY1_TYPE||' '||si.LOCALITY1, '') ) as "адрес КЛАДР ЗД",
    si.OTHER as "Иное ЗД",
    si.note as "адрес ДОК ЗД",
    r.letter as "литера ЗД"
-- */
-- /* КС зд
,   replace(to_char(pa12z.value, 'fm9999999999999999990D00'), ',', '.') as "КС ЗД"
,   to_char(pa12z.payment_date, 'YYYY-MM-DD') as "Дата КС ЗД"
,   to_char(pa12z.ENTRY_DATE, 'YYYY-MM-DD') as "дата внесения КС ЗД"
,   to_char(pa12z.DEFINITION_DATE, 'YYYY-MM-DD') as "дата определения КС ЗД"
,   replace(to_char(pa22z.value, 'fm9999999999999999990D00'), ',', '.') as "УПКС ЗД",
-- */
    ooo.cad_num as "помещение",
    to_char(r2.date_registered, 'YYYY-MM-DD') as "дата постановки ПОМ",
    to_char(r2.date_canceled, 'YYYY-MM-DD') as "дата снятия ПОМ",
    s2.name as "статус ПОМ",
    pa2.name as "тип ПОМ",
    case
        when ooo.obj_kind_id = 22 and r2.assignation_code is null then r2.assignation_name
        when ooo.obj_kind_id = 22 and r2.assignation_code is not null then (select name from cad_qual_dev.v$_building_purpose where code = r2.assignation_code) 
		when ooo.obj_kind_id = 23 then (select name from cad_qual_dev.v$_flat_purpose where code = r2.assignation_code)
    end as "назначение ПОМ",
    r2.name as "наименование ПОМ",
    replace(to_char(ch2.area, 'fm9999999999999999990D00'), ',', '.') as "площадь ПОМ",
    to_char(WMSYS.WM_CONCAT(distinct nvl(pn1.storey_number, nvl(r2.floor_num, zpn.floor_num)))over(partition by ooo.cad_num)) as "номера этажей",
    to_char(WMSYS.WM_CONCAT(distinct
        nvl((select et_type.value from cad_qual_dev.v$_type_storey et_type where et_type.code = pn1.storey_type),
            nvl((select et_type.value from cad_qual_dev.v$_type_storey et_type where et_type.code = r2.type),
                (select et_type.value from cad_qual_dev.v$_type_storey et_type where et_type.code = zpn.type))))
                over(partition by ooo.cad_num) ) as tip,
    to_char(WMSYS.WM_CONCAT(distinct pn1.num)over(partition by ooo.cad_num)) as "номера на поэтажных",
-- /* АДРЕС v2
    trim( nvl2(si2.REGION, si2.REGION, '')|| nvl2(si2.DISTRICT, ', '||si2.DISTRICT_TYPE||' '||si2.DISTRICT, '')||
        nvl2(si2.CITY, ', '||si2.CITY_TYPE||' '||si2.CITY, '')|| nvl2(si2.URBAN_DISTRICT, ', '||si2.URBAN_DISTRICT, '')||
        nvl2(si2.SOVIET_VILLAGE, ', '||si2.SOVIET_VILLAGE, '')|| nvl2(si2.LOCALITY, ', '||si2.LOCALITY_TYPE||' '||si2.LOCALITY, '')||
        nvl2(si2.STREET, ', '||si2.STREET_TYPE||' '||si2.STREET, '')|| nvl2(si2.HOUSE, ', дом '||si2.HOUSE, '')||
        nvl2(si2.BUILDING, ', корп '||si2.BUILDING, '')|| nvl2(si2.STRUCTURE, ', стр '||si2.STRUCTURE, '')||
        nvl2(si2.APARTMENT, ', '||si2.APARTMENT_TYPE||' '||si2.APARTMENT, '')||
        nvl2(si2.LOCALITY1, ', '||si2.LOCALITY1_TYPE||' '||si2.LOCALITY1, '') ) as "адрес КЛАДР ПОМ",
    si2.OTHER as "Иное ПОМ",
    si2.note as "адрес ДОК ПОМ",
    r2.letter as "литера ПОМ"
-- */
from
    zkoks.obj o
    left join zkoks.reg r on (r.obj_id = o.id)
    left join zkoks.characteristic ch on (ch.reg_id = r.id)
    left join zkoks.site si on (si.parent_id = r.ID AND si.r$table_map_id = 7)
    left join cad_qual_dev.v$_cad_object_status s on (s.code = o.status)
    left join (select code, name from cad_qual_dev.v$_gkn_object_type) pa on (pa.code = r.type)
    left join (select o2.id, o2.cad_num, oo.obj_parent_id, o2.status, o2.obj_kind_id from zkoks.obj_obj oo left join zkoks.obj o2 on(oo.obj_child_id = o2.id) where 
            oo.is_del=0 and oo.status='02' and oo.relation_type='01' and o2.obj_kind_id = 23) ooo on (ooo.obj_parent_id = o.id)
    left join zkoks.reg r2 on (r2.obj_id = ooo.id)
    left join zkoks.characteristic ch2 on (ch2.reg_id = r2.id)
    left join zkoks.site si2 on (si2.parent_id = r2.ID AND si2.r$table_map_id = 7)
    left join cad_qual_dev.v$_cad_object_status s2 on (s2.code = ooo.status)
    left join (select code, name from cad_qual_dev.v$_gkn_object_type) pa2 on (pa2.code = r2.type)
-- /* КС зд
    left join zkoks.payment pa12z on (pa12z.reg_id = r.id and pa12z.code = '016010000000')
    left join zkoks.payment pa22z on (pa22z.reg_id = r.id and pa22z.code = '016011000000')
-- */
-- /* КС пом
    left join zkoks.payment pa12p on (pa12p.reg_id = r2.id and pa12p.code = '016010000000')
    left join zkoks.payment pa22p on (pa22p.reg_id = r2.id and pa22p.code = '016011000000')
-- */
    left join zkoks.position_new pn1 on(r2.id = pn1.reg_id)
    left join (SELECT pn3.reg_id, r1.floor_num, r1.type FROM zkoks.position_new pn3 left join zkoks.obj o1 on(o1.id=pn3.obj_id)
        left join zkoks.reg r1 on(r1.obj_id = o1.id) where r1.date_egroks is not null) zpn on(zpn.reg_id = r2.id)
where
    r.id = nvl((select max(id) from zkoks.reg where obj_id = o.id and date_egroks is not null), (select max(id) from zkoks.reg where obj_id = o.id))
    and (r2.id = nvl((select max(id) from zkoks.reg where obj_id = ooo.id and date_egroks is not null), (select max(id) from zkoks.reg where obj_id = ooo.id)) or r2.id is null)
  --  and o.obj_kind_id = 22
    and o.cad_num like :S1
order by 1,18
