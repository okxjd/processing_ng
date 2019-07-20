with abc as (select
	:S1 as k_num, to_date('16-01-3019 00:00:00', 'DD-MM-YYYY HH24:MI:SS') as date_report from dual)
select distinct /*+ LEADING(ooo, o) */
    ooo.cad_num as "ОН",
    to_char(roo.date_registered, 'YYYY-MM-DD') as "Дата постановки",
    to_char(roo.date_canceled, 'YYYY-MM-DD') as "Дата снятия",
    (select s.name from cad_qual_dev.v$_cad_object_status s where s.code = nvl(osnoo.status_type, ooo.status)) as "статус ОН",
    nvl(nvl((select oks_type.name from cad_qual_dev.v$_gkn_object_type oks_type where oks_type.code = roo.type),
            (select zu_type.name from cad_qual_dev.v$_parcels zu_type where zu_type.kod = roo.type)),
            (select ok.kind from zkoks.obj_kind ok where ok.id = ooo.obj_kind_id)) as "вид ОН",
    case when exists(select ri.id from zkoks.right ri where ri.reg_id = roo.id and ri.reg_date_end is null) then 'да' else 'нет' end as "права",
    case when exists(select e.id from zkoks.encumbrance e where e.reg_id = roo.id and e.reg_date_end is null) then 'да' else 'нет' end as "обременения",
    
    o.cad_num as "последующий",
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
    replace(to_char(decode(o.obj_kind_id, 22,ch.area, 23,ch.area, coalesce(a009.value, a008.value, a002.value)), 'fm9999999999999999990D00'), ',', '.') as "площадь",
    decode(coalesce(a009.code, a008.code, a002.code), '009', 'уточн', '008', 'деклар', '002', 'общая') as "тип площади",
    to_char(WMSYS.WM_CONCAT(nvl2(kpp.param_type, kpp.param_type||'='||kpp.param_val||'; ', '-'))over(partition by o.id)) as "осн парам соор",
    trim( nvl2(si.REGION, si.REGION, '')|| nvl2(si.DISTRICT, ', '||si.DISTRICT_TYPE||' '||si.DISTRICT, '')||
        nvl2(si.CITY, ', '||si.CITY_TYPE||' '||si.CITY, '')|| nvl2(si.URBAN_DISTRICT, ', '||si.URBAN_DISTRICT, '')||
        nvl2(si.SOVIET_VILLAGE, ', '||si.SOVIET_VILLAGE, '')|| nvl2(si.LOCALITY, ', '||si.LOCALITY_TYPE||' '||si.LOCALITY, '')||
        nvl2(si.STREET, ', '||si.STREET_TYPE||' '||si.STREET, '')|| nvl2(si.HOUSE, ', дом '||si.HOUSE, '')||
        nvl2(si.BUILDING, ', корп '||si.BUILDING, '')|| nvl2(si.STRUCTURE, ', стр '||si.STRUCTURE, '')||
        nvl2(si.APARTMENT, ', '||si.APARTMENT_TYPE||' '||si.APARTMENT, '')||
        nvl2(si.LOCALITY1, ', '||si.LOCALITY1_TYPE||' '||si.LOCALITY1, '') ) as "адрес КЛАДР",
    case when exists(select ri.id from zkoks.right ri where ri.reg_id = r.id and ri.reg_date_end is null) then 'да' else 'нет' end as "права",
    case when exists(select e.id from zkoks.encumbrance e where e.reg_id = r.id and e.reg_date_end is null) then 'да' else 'нет' end as "обременения",
    vhd.osnovanie_ucheta as "документ учета",
    vhd.osnovanie_ucheta_req as "наименование документа учета",
    vhd.ki_name as "исполнитель 1-го среза",
    vhd.ki_att as "аттестат исполнителя",
    vhd.ki_org as "организация исполнителя",
    to_char(vhd.date_contractor, 'YYYY-MM-DD') as "дата работ"
FROM abc a,

    zkoks.obj ooo
    left join zkoks.reg roo on(roo.obj_id = ooo.id)
    left join zkoks.obj_status_new osnoo on(osnoo.obj_id = ooo.id)
    
    left join zkoks.cad_number_prev cp on(cp.cad_num = ooo.cad_num)
    left join zkoks.reg r on(r.id = cp.reg_id)
    left join zkoks.obj o on(o.id = r.obj_id)

    left join zkoks.obj_status_new osn on(osn.obj_id = o.id)
    left join zkoks.category c on(c.reg_id = r.id)
    left join cad_qual_dev.v$_purpose_land p on(p.code = c.code)
    left join zkoks.utilization u on(u.reg_id = r.id)
    left join cad_qual_dev.v$_resolved_use reso on(reso.code = u.code)
    left join cad_qual_dev.v$_resolved_use_type_540 reso540 on(reso540.code = u.code540)
    left join zkoks.area_new a009 on(a009.reg_id = r.id and a009.code = '009')
    left join zkoks.area_new a008 on(a008.reg_id = r.id and a008.code = '008'
        and not exists(select a8.value from zkoks.area_new a8 where a8.reg_id = r.id and a8.code = '009'))
    left join zkoks.area_new a002 on(a002.reg_id = r.id and a002.code = '002')
    left join zkoks.characteristic ch on(ch.reg_id = r.id)
    left join zkoks.site si on(si.parent_id = r.ID AND si.r$table_map_id = 7)
    left join (select kp.reg_id, decode(kp.type, '01', 'длина', '02', 'глубина', '03', 'объем', '04', 'высота',
        '05', 'площадь', '06', 'площадь застройки', null) as param_type, kp.value as param_val
        from zkoks.key_parametrs kp) kpp on(kpp.reg_id = r.id and r.type in('002002004000','002002004002'))
        
    left join (select distinct ovh.id as o_id, case when (req.id is null and ed.file_name is null) then Null when req.id is not Null then req.REQUEST_NUMBER
        else ed.file_name end as osnovanie_ucheta, req.date_registration as date_registration, req.date_close as date_close,
        r1.date_egroks as date_egroks, (select rt.name from cad_qual_dev.v$_request_type2 rt where rt.code like req.request_type_id) as osnovanie_ucheta_req
        , c.last_name||' '||c.first_name||' '||c.middle_name as ki_name, c.certificate as ki_att, c.name_org as ki_org, r1.date_contractor
        from zkoks.obj ovh left join zkoks.reg r1 on(r1.obj_id = ovh.id) left join request.request req on(req.id = r1.request_id) left join zkoks.EDOC_INFO ed on(r1.EDOC_INFO_ID = ed.id)
        left join zkoks.contractor c on(c.id = r1.contractor_id) where r1.id = (select min(id) from zkoks.reg where obj_id = ovh.id)
        ) vhd on(vhd.o_id = o.id)

where
    roo.id = (select max(rr.id) from abc aa, zkoks.reg rr where rr.obj_id = ooo.id and rr.date_egroks <= aa.date_report)
    and( (osnoo.id=(select max(ss.id) from abc ab, zkoks.obj_status_new ss where ss.obj_id=ooo.id and ss.status_date<ab.date_report
        and(ss.status_change_date is null or ss.status_change_date >= ab.date_report))  )
        or osnoo.id is null  )
        
    and(
        (r.id = (select max(rr.id) from abc aa, zkoks.reg rr where rr.obj_id = o.id and rr.date_egroks <= aa.date_report)
        and( (osn.id=(select max(ss.id) from abc ab, zkoks.obj_status_new ss where ss.obj_id=o.id and ss.status_date<ab.date_report
            and(ss.status_change_date is null or ss.status_change_date >= ab.date_report))  )
            or osn.id is null  )
        )
        or r.id is null
        )
    
    and ooo.cad_num like a.k_num

order by 1, 3
