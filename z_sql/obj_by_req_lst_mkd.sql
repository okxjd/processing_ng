with ze as(select distinct rq.id as req_id from request.request rq where rq.request_number like :S1)
, base0 as(
select distinct z1.req_id, rpo1.obj_id as obj1, 1 as ot from ze z1
    left join request.request_prev_obj rpo1 on(rpo1.request_id = z1.req_id and(rpo1.obj_exist!='neighbour' or rpo1.obj_exist is null))
    where rpo1.obj_id is not null
union select distinct z3.req_id, r3.obj_id as obj1, 1 as ot from ze z3
    left join zkoks.reg r3 on(r3.request_id = z3.req_id)
    inner join request.request_prev_obj rpo3 on(rpo3.bbd_reg_id = r3.id and(rpo3.obj_exist!='neighbour' or rpo3.obj_exist is null))
    where r3.obj_id is not null
union select distinct z4.req_id, r4.obj_id as obj1, 1 as ot from ze z4
    left join request.request_new_obj rno4 on(rno4.request_id = z4.req_id and(rno4.sub_type not like 'Sub%' or rno4.sub_type is null))
    left join zkoks.reg r4 on(r4.id = rno4.obj_id) where r4.obj_id is not null
    )
, base1 as(
select distinct z5.req_id, rpo5.id as obj1, 2 as ot from ze z5
    left join request.request_prev_obj rpo5 on(rpo5.request_id = z5.req_id and(rpo5.obj_exist!='neighbour' or rpo5.obj_exist is null))
    left join zkoks.reg r5 on(r5.id=rpo5.bbd_reg_id) where rpo5.id is not null and r5.obj_id is null
    and not exists(select z.obj1 from base0 z where z.req_id = z5.req_id)
union select distinct z6.req_id, rno6.id as obj1, 3 as ot from ze z6
    left join request.request_new_obj rno6 on(rno6.request_id = z6.req_id and(rno6.sub_type not like 'Sub%' or rno6.sub_type is null))
    left join zkoks.reg r6 on(r6.id = rno6.obj_id) where rno6.id is not null and r6.obj_id is null
    and not exists(select z.obj1 from base0 z where z.req_id = z6.req_id)
    )

select distinct
    req.request_number as "заявка",
    (select rt.name from cad_qual_dev.v$_request_type2 rt where rt.code = req.request_type_id) as "Тип заявки",
    (select aa.name from cad_qual_dev.v$_action_ow aa where aa.code = req.action) as "Учетное действие",
    (select st.name from cad_qual_dev.v$_request_state2 st where st.code = req.state_code) as "Статус заявки",
    to_char(req.date_registration, 'YYYY-MM-DD') as "дата рег заявки", to_char(req.date_close, 'YYYY-MM-DD') as "дата закрытия заявки",
    coalesce(o.cad_num, to_char(o.id)) as obj_num,
    to_char(r.date_registered, 'YYYY-MM-DD') as "Дата постановки", to_char(r.date_canceled, 'YYYY-MM-DD') as "Дата снятия",
    (select s.name from cad_qual_dev.v$_cad_object_status s where s.code = o.status) as "статус ОН",
    nvl(nvl((select oks_type.name from cad_qual_dev.v$_gkn_object_type oks_type where oks_type.code = r.type),
        (select zu_type.name from cad_qual_dev.v$_parcels zu_type where zu_type.kod = r.type)),
        (select ok.kind from zkoks.obj_kind ok where ok.id = o.obj_kind_id)) as "тип ОН",
    case when o.obj_kind_id = 22 and r.assignation_code is null then r.assignation_name
        when o.obj_kind_id = 22 and r.assignation_code is not null then (select name from cad_qual_dev.v$_building_purpose where code = r.assignation_code)
        when o.obj_kind_id = 23 then (select name from cad_qual_dev.v$_flat_purpose where code = r.assignation_code) end as "назначение",
    (select p.value from cad_qual_dev.v$_purpose_land p where p.code = c.code) as "категория ЗУ",
    u.doc as "РИ по док",
    replace(to_char(decode(o.obj_kind_id, 22, ch.area, 23, ch.area, 5, nvl(a009.value, a008.value)),'fm9999999999999999990D00'),',','.') as area,
    decode(nvl(a009.code, a008.code), '009', 'уточн', '008', 'деклар') as zu_area_type,
    (select v$_address_string.address from zkoks.v$_address_string where v$_address_string.parent_id=r.id and v$_address_string.r$table_map_id=7) as "адрес"
from request.request req
    left join base0 b on(b.req_id = req.id)
    left join zkoks.obj o on(o.id = b.obj1)
    left join zkoks.reg r on(r.obj_id = o.id)
    left join zkoks.area_new a009 on(a009.reg_id=r.id and a009.code='009')
    left join zkoks.area_new a008 on(a008.reg_id=r.id and a008.code='008'
        and not exists(select a8.value from zkoks.area_new a8 where a8.reg_id=r.id and a8.code='009'))
    left join zkoks.characteristic ch on(ch.reg_id = r.id)
    left join zkoks.category c on(c.reg_id = r.id)
    left join zkoks.utilization u on(u.reg_id = r.id)
where
    b.ot = 1
    and r.id = nvl((select max(id) from zkoks.reg where obj_id=o.id and date_egroks is not null), (select max(id) from zkoks.reg where obj_id=o.id))
    and o.obj_kind_id =22 and r.assignation_code = '005001003000'
    and coalesce(o.cad_num, to_char(o.id)) is not null
union
select distinct
    req.request_number as "заявка",
    (select rt.name from cad_qual_dev.v$_request_type2 rt where rt.code = req.request_type_id) as "Тип заявки",
    (select aa.name from cad_qual_dev.v$_action_ow aa where aa.code = req.action) as "Учетное действие",
    (select st.name from cad_qual_dev.v$_request_state2 st where st.code = req.state_code) as "Статус заявки",
    to_char(req.date_registration, 'YYYY-MM-DD') as "дата рег заявки", to_char(req.date_close, 'YYYY-MM-DD') as "дата закрытия заявки",
    'N__'||to_char(b.obj1) as obj_num,
    '' as "Дата постановки", '' as "Дата снятия",
    '' as "статус ОН",
    nvl((select oks_type.name from cad_qual_dev.v$_gkn_object_type oks_type where oks_type.code = rno.sub_type),
        (select zu_type.name from cad_qual_dev.v$_parcels zu_type where zu_type.kod = rno.sub_type)) as "тип ОН",
    to_char(rno.name) as "назначение ОКС",
    '' as "категория ЗУ",
    '' as "РИ по док",
    '' as area,
    '' as zu_area_type,
    rno.note as "адрес"
from request.request req
    left join base1 b on(b.req_id = req.id)
    inner join request.request_new_obj rno on(rno.id = b.obj1)
where
    b.ot = 3 and b.obj1 is not null and( lower(to_char(rno.name)) like '%многокварт%' or rno.sub_type = '005001003000' )
union
select distinct
    req.request_number as "заявка",
    (select rt.name from cad_qual_dev.v$_request_type2 rt where rt.code = req.request_type_id) as "Тип заявки",
    (select aa.name from cad_qual_dev.v$_action_ow aa where aa.code = req.action) as "Учетное действие",
    (select st.name from cad_qual_dev.v$_request_state2 st where st.code = req.state_code) as "Статус заявки",
    to_char(req.date_registration, 'YYYY-MM-DD') as "дата рег заявки", to_char(req.date_close, 'YYYY-MM-DD') as "дата закрытия заявки",
    coalesce(rpon.cad_number, 'E__'||to_char(b.obj1)) as obj_num,
    '' as "Дата постановки", '' as "Дата снятия",
    '' as "статус ОН",
    nvl((select oks_type.name from cad_qual_dev.v$_gkn_object_type oks_type where oks_type.code = coalesce(rpon.type, rpon.sub_type)),
        (select zu_type.name from cad_qual_dev.v$_parcels zu_type where zu_type.kod = coalesce(rpon.type, rpon.sub_type))) as "тип ОН",
    '' as "назначение ОКС",
    '' as "категория ЗУ",
    '' as "РИ по док",
    '' as area,
    '' as zu_area_type,
    rpon.note as "адрес"
from request.request req
    left join base1 b on(b.req_id = req.id)
    inner join request.request_prev_obj rpon on(rpon.id = b.obj1)
where
    b.ot = 2 and coalesce(rpon.cad_number, to_char(b.obj1)) is not null
    and coalesce(rpon.type, rpon.sub_type) = '005001003000'
order by 1, 7 nulls last
