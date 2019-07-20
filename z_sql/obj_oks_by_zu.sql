select distinct
	o.cad_num as kn_zu,
    (select s.name from cad_qual_dev.v$_cad_object_status s where s.code = o.status) as "статус ЗУ",
    (select zu_type.name from cad_qual_dev.v$_parcels zu_type where zu_type.kod = r.type) as "тип ЗУ",
    decode(ooo.lnk_st, '01', 'новая', '02', 'актуальная', '03', 'анулируемая', '04', 'анулированная', ooo.lnk_st) as link_status,
    ooo.oks_num as kn_oks,
    (select s.name from cad_qual_dev.v$_cad_object_status s where s.code = ooo.oks_st) as "статус ОКС",
    (select oks_type.name from cad_qual_dev.v$_gkn_object_type oks_type where oks_type.code = ooo.oks_type) as "тип ОКС",
    to_char(ooo.date_ins, 'YYYY-MM-DD') as "дата установления связи",
    req.REQUEST_NUMBER as "заявка установления связи",
    (select rt.name from cad_qual_dev.v$_request_type2 rt where rt.code like req.request_type_id) as "Тип заявки",
    ei.file_name as "источник связи"
from
	zkoks.obj o
    left join zkoks.reg r on(r.obj_id = o.id)
-- /* СВЯЗАННЫЙ ОКС
    left join (select distinct oo.obj_parent_id, op.cad_num as oks_num, op.status as oks_st, rp.id as oks_reg_id, oo.date_ins, oo.status as lnk_st,
        rp.type as oks_type, oo.EDOC_INFO_ID, oo.request_id_create from zkoks.obj_obj oo left join zkoks.obj op on(op.id = oo.obj_child_id)
        left join zkoks.reg rp on(rp.obj_id = op.id) where oo.is_del = 0
        and oo.status = '02' and op.obj_kind_id = 22 and op.cad_num is not Null and op.status in('01', '05', '06')
        and rp.id = nvl((select max(rr.id) from zkoks.reg rr where rr.obj_id = op.id and rr.date_egroks is not null),
                        (select max(rr.id) from zkoks.reg rr where rr.obj_id = op.id))
        ) ooo on(ooo.obj_parent_id = o.id and o.obj_kind_id = 5)
    left join zkoks.EDOC_INFO ei on(ooo.EDOC_INFO_ID=ei.id)
    left join request.request req on(req.id = ooo.request_id_create)
-- */
where r.id = (select max(rr.id) from zkoks.reg rr where rr.obj_id = o.id and rr.date_egroks is not null)
and o.cad_num like :S1 order by 1,2
