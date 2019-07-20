with
base as ( select distinct o.cad_num, o.id as o_id, r.id as r_id, r.request_id, nvl(pn.storey_number, rn.floor_num) as et
    from zkoks.obj o left join zkoks.reg r on(r.obj_id = o.id) left join zkoks.position_new pn on(pn.reg_id = r.id)
        left join zkoks.reg rn on(rn.obj_id = pn.obj_id and rn.date_egroks is not null)
    where o.cad_num like :S1 and r.date_egroks is not null )
, qwe as(select q.cad_num, q.r_id, q.et et, w.et et2, q.request_id from base q inner join base w on(w.o_id = q.o_id)
    where w.r_id=(select max(rg.id) from zkoks.reg rg where rg.obj_id=q.o_id and rg.id<q.r_id and rg.date_egroks is not null)
    and( q.et != w.et or(q.et is null and w.et is not null) or(q.et is not null and w.et is null) ) )

select distinct
    z.cad_num,
    to_char(WMSYS.WM_CONCAT(distinct z.et2)over(partition by z.cad_num)) as "до",
    to_char(WMSYS.WM_CONCAT(distinct z.et)over(partition by z.cad_num)) as "после",
    req.request_number,
    (select rt.name from cad_qual_dev.v$_request_type2 rt where rt.code = req.request_type_id) as "Тип заявки",
    (select st.name from cad_qual_dev.v$_request_state2 st where st.code = req.state_code) as "Статус заявки",
    to_char(req.date_registration, 'YYYY-MM-DD') as "дата рег заявки",
    to_char(req.date_close, 'YYYY-MM-DD') as "дата закрытия заявки",
    req.text as "особые отметки", req.execution_note as "отметка об исп"
from
    qwe z
    left join request.request req on(req.id = z.request_id)
order by z.cad_num, to_char(req.date_close, 'YYYY-MM-DD')
