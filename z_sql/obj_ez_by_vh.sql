with asasasa as(select distinct o.cad_num as kn, r.date_registered as date_reg, s.name as status, pa.name as tip,
    nvl( (select site.note from zkoks.site where site.parent_id = r.id and site.r$table_map_id = 7 and site.note is not null),
         (select v$_address_string.address from zkoks.v$_address_string where v$_address_string.parent_id = r.id and v$_address_string.r$table_map_id = 7)) as adres,
    nvl((select area_new.value from zkoks.area_new where area_new.reg_id = r.id and area_new.code = '009' and area_new.value is not null),
        (select area_new.value from zkoks.area_new where area_new.reg_id = r.id and area_new.code = '008')) as area,
    case when (select area_new.value from zkoks.area_new where area_new.reg_id=r.id and area_new.code='009' and area_new.value is not null) is not null then 'уточн.'
         when ((select area_new.value from zkoks.area_new where area_new.reg_id=r.id and area_new.code='009' and area_new.value is not null) is null and
         (select area_new.value from zkoks.area_new where area_new.reg_id=r.id and area_new.code='008') is not null) then 'декларир.'
         else null end as area_type,
    ooo.zu_kn, ooo.zu_status, ooo.link_status, ooo.zu_tip, ooo.zu_categ, ooo.zu_ri_doc,
    ooo.zu_ri_spr, ooo.zu_adres, ooo.zu_area, ooo.zu_area_type
from zkoks.obj o left join zkoks.reg r on(r.obj_id = o.id) left join cad_qual_dev.v$_cad_object_status s on(s.code = o.status)
    left join cad_qual_dev.v$_parcels pa on(pa.kod = r.type)
    inner join ( select oo.obj_child_id, op.cad_num as zu_kn, so.name as zu_status, oo.status as link_status,
        pao.name as zu_tip, po.value as zu_categ, uo.doc as zu_ri_doc, resoo.value as zu_ri_spr,
        nvl((select site.note from zkoks.site where site.parent_id = ro.id and site.r$table_map_id = 7),
        (select v$_address_string.address from zkoks.v$_address_string where v$_address_string.parent_id = ro.id and v$_address_string.r$table_map_id = 7)) as zu_adres,
        nvl((select area_new.value from zkoks.area_new where area_new.reg_id = ro.id and area_new.code = '009' and area_new.value is not null),
        (select area_new.value from zkoks.area_new where area_new.reg_id = ro.id and area_new.code = '008')) as zu_area,
        case when (select area_new.value from zkoks.area_new where area_new.reg_id=ro.id and area_new.code='009' and area_new.value is not null) is not null then 'уточн.'
        when ((select area_new.value from zkoks.area_new where area_new.reg_id=ro.id and area_new.code='009' and area_new.value is not null) is null and
        (select area_new.value from zkoks.area_new where area_new.reg_id=ro.id and area_new.code='008') is not null) then 'декларир.'
        else null end as zu_area_type
        from zkoks.obj_obj oo left join zkoks.obj op on (op.id = oo.obj_parent_id) left join zkoks.reg ro on (ro.obj_id = op.id)
        left join cad_qual_dev.v$_cad_object_status so on (so.code = op.status)
        left join (select kod, name from cad_qual_dev.v$_parcels) pao on (pao.kod = ro.type)
        left join zkoks.category co on (co.reg_id = ro.id) left join cad_qual_dev.v$_purpose_land po on (po.code = co.code)
        left join zkoks.utilization uo on (uo.reg_id = ro.id) left join cad_qual_dev.v$_resolved_use resoo on (resoo.code = uo.code)
        where oo.is_del = 0 and oo.relation_remove_date is null and oo.status = '02' and op.obj_kind_id = 5 and op.cad_num is not Null
        and ro.id = nvl((select max(id) from zkoks.reg where obj_id = op.id and date_egroks is not null), (select max(id) from zkoks.reg where obj_id = op.id))
        ) ooo on(ooo.obj_child_id = o.id and o.obj_kind_id = 5)
where
    r.id=nvl((select max(id) from zkoks.reg where obj_id = o.id and date_egroks is not null), (select max(id) from zkoks.reg where obj_id = o.id))
    and o.obj_kind_id = 5 and o.status in ('01', '05', '06') and r.type in('03', '04') and o.cad_num like :S1 )
select
    q.kn as "Кадастровый номер",
    to_char(q.date_reg, 'YYYY-MM-DD') as "Дата постановки на учет",
    q.status as "Статус",
    q.tip as "Тип",
    replace(to_char(q.area, 'fm9999999999999999990D00'), ',', '.') as "Площадь",
    q.area_type as "тип площади",
    q.adres as "Адрес",
    '|' as "|",
    q.zu_kn as "КН ЕЗ",
    q.zu_status as "статус ЕЗ",
    decode(q.link_status, '01', 'новая', '02', 'актуальная', '03', 'анулируемая', '04', 'анулированная') as "статус связи ЗУ-ЕЗ",
    q.zu_tip as "тип ЕЗ",
    q.zu_categ as "категория ЕЗ",
    q.zu_ri_doc as "РИ по док ЕЗ",
    q.zu_ri_spr as "РИ по справочн ЕЗ",
    q.zu_adres as "адрес ЕЗ",
    replace(to_char(q.zu_area, 'fm9999999999999999990D00'), ',', '.') as "площадь ЕЗ",
    q.zu_area_type as "тип площади ЕЗ"
from
    asasasa q
order by q.kn
