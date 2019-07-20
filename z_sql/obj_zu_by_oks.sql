select distinct
	o.cad_num as kn_oks,
    (select s.name from cad_qual_dev.v$_cad_object_status s where s.code = o.status) as "статус ОКС",
    (select oks_type.name from cad_qual_dev.v$_gkn_object_type oks_type where oks_type.code = r.type) as "тип ОКС",
 --   replace(to_char(ch.area, 'fm9999999999999999990D00'), ',', '.') as "Площадь ОКС",
 --   to_char(ch.floors) as "этажность",
    '|' as "|",
    ooo.zu_num as kn_zu,
    (select s.name from cad_qual_dev.v$_cad_object_status s where s.code = ooo.zu_status) as "статус ЗУ",
    (select zt.name from cad_qual_dev.v$_parcels zt where zt.kod = ooo.zu_type) as "тип ЗУ",
    (select p.value from cad_qual_dev.v$_purpose_land p where p.code = ooo.categ_code) as "категория ЗУ",
    (select u.doc from zkoks.utilization u where u.reg_id = ooo.zu_reg_id) as "РИ док",
    replace(to_char(coalesce(a009.value, a008.value), 'fm9999999999999999990D00'), ',', '.') as "площадь",
    decode(coalesce(a009.code, a008.code), '009', 'уточн', '008', 'деклар') as "тип площади",
    trim( nvl2(si.REGION, si.REGION, '')|| nvl2(si.DISTRICT, ', '||si.DISTRICT_TYPE||' '||si.DISTRICT, '')||
        nvl2(si.CITY, ', '||si.CITY_TYPE||' '||si.CITY, '')|| nvl2(si.URBAN_DISTRICT, ', '||si.URBAN_DISTRICT, '')||
        nvl2(si.SOVIET_VILLAGE, ', '||si.SOVIET_VILLAGE, '')|| nvl2(si.LOCALITY, ', '||si.LOCALITY_TYPE||' '||si.LOCALITY, '')||
        nvl2(si.STREET, ', '||si.STREET_TYPE||' '||si.STREET, '')|| nvl2(si.HOUSE, ', дом '||si.HOUSE, '')||
        nvl2(si.BUILDING, ', корп '||si.BUILDING, '')|| nvl2(si.STRUCTURE, ', стр '||si.STRUCTURE, '')||
        nvl2(si.APARTMENT, ', '||si.APARTMENT_TYPE||' '||si.APARTMENT, '')||
        nvl2(si.LOCALITY1, ', '||si.LOCALITY1_TYPE||' '||si.LOCALITY1, '') ) as "адрес КЛАДР",
    si.note as "адрес ДОК",
    '|' as "|",
    to_char(ooo.date_ins, 'YYYY-MM-DD') as "дата установления связи",
    req.REQUEST_NUMBER as "заявка установления связи",
    (select rt.name from cad_qual_dev.v$_request_type2 rt where rt.code like req.request_type_id) as "Тип заявки",
    ei.file_name as "источник связи"
from
	zkoks.obj o left join zkoks.reg r on(r.obj_id = o.id)
 --   left join zkoks.characteristic ch on(ch.reg_id = r.id)
-- /* СВЯЗАННЫЙ ЗУ
    left join (select distinct oo.obj_child_id, op.cad_num as zu_num, op.status as zu_status, rp.id as zu_reg_id, c.code as categ_code,
        oo.date_ins, rp.type as zu_type, oo.EDOC_INFO_ID, oo.request_id_create
        from zkoks.obj_obj oo left join zkoks.obj op on(op.id = oo.obj_parent_id) left join zkoks.reg rp on(rp.obj_id = op.id)
        left join zkoks.category c on(c.reg_id = rp.id)
        where oo.is_del = 0 and oo.status='02' and op.obj_kind_id = 5 and op.cad_num is not Null
        and rp.id = nvl((select max(rr.id) from zkoks.reg rr where rr.obj_id = op.id and rr.date_egroks is not null),
        (select max(rr.id) from zkoks.reg rr where rr.obj_id = op.id)) ) ooo on(ooo.obj_child_id = o.id and o.obj_kind_id in(22,23))
    left join zkoks.EDOC_INFO ei on(ooo.EDOC_INFO_ID=ei.id) left join request.request req on(req.id = ooo.request_id_create)
    left join zkoks.site si on(si.parent_id = ooo.zu_reg_id AND si.r$table_map_id = 7)
    left join zkoks.area_new a009 on(a009.reg_id = ooo.zu_reg_id and a009.code = '009')
    left join zkoks.area_new a008 on(a008.reg_id = ooo.zu_reg_id and a008.code = '008'
        and not exists(select a8.value from zkoks.area_new a8 where a8.reg_id = ooo.zu_reg_id and a8.code = '009'))
-- */
where r.id = (select max(rr.id) from zkoks.reg rr where rr.obj_id = o.id and rr.date_egroks is not null)
and o.cad_num like :S1 order by 1,2
