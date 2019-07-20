select distinct
    o.cad_num as "КН",
    nvl((select oks_type.name from cad_qual_dev.v$_gkn_object_type oks_type where oks_type.code = r.type),
        (select zu_type.name from cad_qual_dev.v$_parcels zu_type where zu_type.kod = r.type)) as "вид ОН",
    (select s.name from cad_qual_dev.v$_cad_object_status s where s.code = osn1.status_type) as "статус ОН",
    to_char(r.date_registered, 'YYYY-MM-DD') as "дата постановки",
    to_char(r.date_canceled, 'YYYY-MM-DD') as "дата снятия",
    to_char(osn1.STATUS_DATE, 'YYYY-MM-DD') as "дата установления статуса",
    nvl(req.REQUEST_NUMBER, ed.file_name) as request,
    (select rt.name from cad_qual_dev.v$_request_type2 rt where rt.code = req.request_type_id) as req_type
    -- ,
    -- ed.type_dec as "тип заявителя",
    -- rr.name as "заявитель"
from
    zkoks.obj o
    left join zkoks.reg r on(r.obj_id = o.id)

    left join zkoks.OBJ_STATUS_NEW osn1 on(osn1.obj_id = o.id)
    left join request.request req on(req.id = osn1.request_id)
    left join zkoks.EDOC_INFO ed on(ed.id = osn1.EDOC_INFO_ID)
    
    left join zkoks.OBJ_STATUS_NEW osn2 on(osn2.obj_id = o.id)

    -- left join (
        -- select id, request_id, declarant_fl_def_id||declarant_ul_def_id||declarant_gov_def_id as declarant_id,
        -- case when declarant_fl_def_id is not null then 'ФИЗ' when declarant_ul_def_id is not null then 'ЮР'
        -- when declarant_gov_def_id is not null then 'ОГВ' else null end type_dec
        -- from request.request_declarant where declarant_fl_def_id||declarant_ul_def_id||declarant_gov_def_id is not null
        -- ) ed on(ed.request_id = req.id)
    -- left join (
        -- select id, last_name||' '||first_name||' '||middle_name name, right_id, '' as  ogrn, '' as email, 'ФИЗ' type_dec1 from zkoks.right_owner_fl
        -- union select id, name name, right_id, ogrn as  ogrn, email as email, 'ЮР' type_dec1 from zkoks.right_owner_ul
        -- union select id, name name, right_id, '' as  ogrn, '' as email, 'ОГВ' type_dec1 from zkoks.right_owner_sub)
        -- rr on(ed.declarant_id = rr.id and rr.type_dec1 = ed.type_dec)
where
    r.id = nvl((select max(id) from zkoks.reg where obj_id = o.id and date_egroks is not null), (select max(id) from zkoks.reg where obj_id = o.id))
    and o.obj_kind_id in(22, 23, 5) and o.cad_num like :S1
    and( (osn1.id=(select max(ss.id) from zkoks.obj_status_new ss where ss.obj_id=o.id and ss.status_date is not null)
        and osn1.status_type in('07', '08')) or(osn1.id is null and o.status in('07', '08') ) )

    and osn2.id = (select max(id) from zkoks.OBJ_STATUS_NEW where obj_id = o.id and id < osn1.id)
    and osn2.status_type in('01', '05', '06')
    order by 1



