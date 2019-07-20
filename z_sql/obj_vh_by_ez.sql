select distinct
    o.cad_num as kn_ez,
    
    decode(oo.status, '01', 'новая', '02', 'актуальная', '03', 'анулируемая', '04', 'анулированная') as "статус связи ЗУ-ЕЗ",
    to_char(oo.date_ins, 'YYYY-MM-DD') as "дата УСТАНОВЛЕНИЯ связи",
    to_char(oo.relation_create_date, 'YYYY-MM-DD') as "дата создания связи",
    req.REQUEST_NUMBER as "заявка создания связи",
    (select rt.name from cad_qual_dev.v$_request_type2 rt where rt.code like req.request_type_id) as "Тип заявки",
    to_char(oo.relation_remove_date, 'YYYY-MM-DD') as "дата удаления связи",
    rx.REQUEST_NUMBER as "заявка удаления связи",
    (select rt.name from cad_qual_dev.v$_request_type2 rt where rt.code like rx.request_type_id) as "Тип заявки",
    ei.file_name as "источник связи",
    
    oe.cad_num as kn_vh,
    (select s.name from cad_qual_dev.v$_cad_object_status s where s.code = oe.status) as "статус ВХ",
    (select zu_type.name from cad_qual_dev.v$_parcels zu_type where zu_type.kod = r.type) as "тип ВХ",
    (select cm.name from CAD_QUAL_DEV.V$_PARCEL_CREATE_METHOD cm where cm.code = r.method) as method,
    to_char(r.date_registered, 'YYYY-MM-DD') as date_reg_vh,
    to_char(r.date_canceled, 'YYYY-MM-DD') as date_canceled_vh,
    p.value as "категория", u.doc as "РИ по док", reso.value as "РИ по класс", reso540.name as "РИ по 540 пр.", u.fact as "фактич. исп.",
    replace(to_char(nvl(a009.value, a008.value), 'fm9999999999999999990D00'), ',', '.') as "площадь",
    decode(nvl(a009.code, a008.code), '009', 'уточн', '008', 'деклар') as "тип площади ЗУ",
    replace(to_char(pa1.value, 'fm9999999999999999990D000'), ',', '.') as "КС",
    replace(to_char(pa2.value, 'fm9999999999999999990D000'), ',', '.') as "УПКС"
    
from
    zkoks.obj o
    inner join zkoks.obj_obj oo on(oo.obj_parent_id = o.id)
    inner join zkoks.obj oe on(oo.obj_child_id = oe.id)
    left join zkoks.reg r on(r.obj_id = oe.id)
    left join zkoks.EDOC_INFO ei on(oo.EDOC_INFO_ID=ei.id)
    left join request.request req on(req.id = oo.request_id_create)
    left join request.request rx on(rx.id = oo.request_id_remove)
left join zkoks.category c on(c.reg_id = r.id)
left join cad_qual_dev.v$_purpose_land p on(p.code = c.code)
left join zkoks.utilization u on(u.reg_id = r.id)
left join cad_qual_dev.v$_resolved_use reso on(reso.code = u.code)
left join cad_qual_dev.v$_resolved_use_type_540 reso540 on(reso540.code = u.code540)
left join zkoks.area_new a009 on(a009.reg_id = r.id and a009.code = '009')
left join zkoks.area_new a008 on(a008.reg_id = r.id and a008.code = '008'
    and not exists(select a8.value from zkoks.area_new a8 where a8.reg_id = r.id and a8.code = '009'))
left join zkoks.payment pa1 on(pa1.reg_id = r.id and pa1.code = '016010000000')
left join zkoks.payment pa2 on(pa2.reg_id = r.id and pa2.code = '016011000000')
where
    r.id=nvl((select max(id) from zkoks.reg where obj_id = oe.id and date_egroks is not null), (select max(id) from zkoks.reg where obj_id = oe.id))
    and oo.is_del = 0
  --  and oo.relation_remove_date is null
    and oo.status in('02','01','03')
    and oo.relation_type = '02'
    and o.obj_kind_id = 5
    and oe.obj_kind_id = 5
    and oe.status in('01', '05', '06')
    and o.cad_num like :S1

