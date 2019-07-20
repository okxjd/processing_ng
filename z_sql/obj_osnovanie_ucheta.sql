with asd as(
select distinct
    o.cad_num,
    r.date_registered,
    r.date_canceled,
    o.status,
    r.type as tip, o.obj_kind_id,
    case when exists(select id from zkoks.entity_spatial where reg_id = r.id) then 1 else 0 end as coord,

    vhd.osnovanie_ucheta,
    vhd.osnovanie_ucheta_req,
    vhd.date_registration,
    vhd.date_close,
    vhd.date_contractor,
    vhd.number_grp,

    -- ed.type_dec,
    -- rr.name,
    
    first_value(rd.doc_num)over(partition by rd.REQUEST_ID order by rd.doc_date desc) as doc_num,
    first_value(rd.doc_name)over(partition by rd.REQUEST_ID order by rd.doc_date desc) as doc_name,
    first_value(rd.doc_date)over(partition by rd.REQUEST_ID order by rd.doc_date desc) as doc_date,
    
    first_value(regexp_replace(replace(replace(replace(
        dbms_lob.substr(rd.xml, decode(sign(dbms_lob.instr(rd.xml, '</Decision>', 180, 1)-dbms_lob.instr(rd.xml, '<Decision>', 180, 1)-3998),
        0,3998, 1,3998, -1,dbms_lob.instr(rd.xml, '</Decision>', 180, 1)-dbms_lob.instr(rd.xml, '<Decision>', 180, 1)-10 ),
        dbms_lob.instr(rd.xml, '<Decision>', 180, 1)+10 ),chr(13),' '),chr(10),' '),chr(9),' '),'( *$)|(^ *)|( {2,})',''))over(partition by rd.REQUEST_ID order by rd.doc_date desc) as doc_txt,
    first_value(regexp_replace(replace(replace(replace(
        dbms_lob.substr(rd.xml, decode(sign(dbms_lob.instr(rd.xml, '</Errors>', 180, 1)-dbms_lob.instr(rd.xml, '<Errors>', 180, 1)-3998),
        0,3998, 1,3998, -1,dbms_lob.instr(rd.xml, '</Errors>', 180, 1)-dbms_lob.instr(rd.xml, '<Errors>', 180, 1)-8 ),
        dbms_lob.instr(rd.xml, '<Errors>', 180, 1)+8 ),chr(13),' '),chr(10),' '),chr(9),' '),'( *$)|(^ *)|( {2,})',''))over(partition by rd.REQUEST_ID order by rd.doc_date desc) as error_txt,
    
    first_value(rUC.LAST_NAME||' '||rUC.FIRST_NAME||' '||rUC.MIDDLE_NAME)over(partition by rd.REQUEST_ID order by rd.doc_date desc) as fio_cert,
    first_value(ruc.div_ID)over(partition by rd.REQUEST_ID order by rd.doc_date desc) as division,
    first_value(rUC1.LAST_NAME||' '||rUC1.FIRST_NAME||' '||rUC1.MIDDLE_NAME)over(partition by rd.REQUEST_ID order by rd.doc_date desc) as fio_cert1,
    first_value(ruc1.div_ID)over(partition by rd.REQUEST_ID order by rd.doc_date desc) as division1
from
    zkoks.obj o
    left join zkoks.reg r on(r.obj_id = o.id)

    left join (select distinct ovh.id as o_id, case when (req.id is null and ed.file_name is null) then Null when req.id is not Null then req.REQUEST_NUMBER
        else ed.file_name end as osnovanie_ucheta, req.date_registration, req.date_close, req.number_grp, r1.date_egroks, req.id as req_id,
        (select rt.name from cad_qual_dev.v$_request_type2 rt where rt.code like req.request_type_id) as osnovanie_ucheta_req, r1.date_contractor
        from zkoks.obj ovh left join zkoks.reg r1 on(r1.obj_id=ovh.id) left join request.request req on(req.id=r1.request_id) left join zkoks.EDOC_INFO ed on (r1.EDOC_INFO_ID = ed.id)
        where r1.id = (select min(id) from zkoks.reg where obj_id = ovh.id)
        ) vhd on(vhd.o_id = o.id)

    -- left join (
        -- select id, request_id, declarant_fl_def_id||declarant_ul_def_id||declarant_gov_def_id as declarant_id,
        -- case when declarant_fl_def_id is not null then 'ФИЗ' when declarant_ul_def_id is not null then 'ЮР'
        -- when declarant_gov_def_id is not null then 'ОГВ' else null end type_dec
        -- from request.request_declarant where declarant_fl_def_id||declarant_ul_def_id||declarant_gov_def_id is not null
        -- ) ed on(ed.request_id = vhd.req_id)
    -- left join (
        -- select id, last_name||' '||first_name||' '||middle_name name, right_id, '' as  ogrn, '' as email, 'ФИЗ' type_dec1 from zkoks.right_owner_fl
        -- union select id, name name, right_id, ogrn as  ogrn, email as email, 'ЮР' type_dec1 from zkoks.right_owner_ul
        -- union select id, name name, right_id, '' as  ogrn, '' as email, 'ОГВ' type_dec1 from zkoks.right_owner_sub)
        -- rr on(ed.declarant_id = rr.id and rr.type_dec1 = ed.type_dec)
    left join REQUEST.REQUEST_DOCUMENT rd on(rd.REQUEST_ID = vhd.req_id and substr(rd.doc_subtype_code, 7) like '025' and rd.global_state=1)
    left join ekon_admin.users ruc on (ruc.ID = rd.user_id)
    left join REQUEST.DOCUMENT_CERTIFICATION dc on(dc.document_id = rd.id)
    left join ekon_admin.users ruc1 on (ruc1.ID = dc.user_id)
where
    r.id = nvl((select max(id) from zkoks.reg where obj_id = o.id and date_egroks is not null), (select max(id) from zkoks.reg where obj_id = o.id))
  --  and o.obj_kind_id in(22, 23, 5)
  --  and o.status in ('01', '05', '06', '07', '08') -- РУ, В, У, Арх, Анн
    and o.cad_num like :S1
)
select distinct
    q.cad_num as "КН",
    to_char(q.date_registered, 'YYYY-MM-DD') as "дата постановки",
    to_char(q.date_canceled, 'YYYY-MM-DD') as "дата снятия",
    (select s.name from cad_qual_dev.v$_cad_object_status s where s.code = q.status) as "статус ОН",
    decode(q.obj_kind_id, 5,(select zu_type.name from cad_qual_dev.v$_parcels zu_type where zu_type.kod = q.tip),
        22,(select oks_type.name from cad_qual_dev.v$_gkn_object_type oks_type where oks_type.code = q.tip),
        23,(select oks_type.name from cad_qual_dev.v$_gkn_object_type oks_type where oks_type.code = q.tip),
        (select ok.kind from zkoks.obj_kind ok where ok.id = q.obj_kind_id)) as "тип ОН",
    case when q.coord = 1 then 'да' else 'нет' end as "есть координаты",

    q.osnovanie_ucheta as "основание учета",
    q.osnovanie_ucheta_req as "тип заявки",
    to_char(q.date_registration, 'YYYY-MM-DD') as "дата регистрации",
    to_char(q.date_close, 'YYYY-MM-DD') as "дата завершения",
    to_char(q.date_contractor, 'YYYY-MM-DD') as "дата проведения работ",
    q.number_grp as "одновременная ГРП",

   -- q.type_dec as "тип заявителя",
    -- to_char(WMSYS.WM_CONCAT(distinct q.type_dec)over(partition by q.cad_num)) as type_dec,
   -- -- q.name as "заявитель",
    -- to_char(WMSYS.WM_CONCAT(distinct q.name)over(partition by q.cad_num)) as name,
    
    q.doc_num as "последнее решение",
    q.doc_name as "наименование решения",
    to_char(q.doc_date, 'YYYY-MM-DD') as "дата принятия решения",
    q.fio_cert as "ФИО создавшего решение",
    (select sd.name from ekon_admin.struct_division sd where sd.id = q.division) as division,
    q.fio_cert1 as "ФИО удостоверившего решение",
    (select sd.name from ekon_admin.struct_division sd where sd.id = q.division1) as division1,
    q.doc_txt as "текст решения",
    q.error_txt as "текст заключения"
from asd q order by 1
