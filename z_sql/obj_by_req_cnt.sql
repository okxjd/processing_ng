with ze as(select distinct rq.id as req_id, rq.request_number from request.request rq where rq.request_number like :S1)
, base0 as(
select distinct z1.req_id, rpo1.obj_id as obj1, 1 as ot from ze z1
    left join request.request_prev_obj rpo1 on(rpo1.request_id = z1.req_id and(rpo1.obj_exist!='neighbour' or rpo1.obj_exist is null))
  --  left join zkoks.reg r1 on(r1.id = rpo1.bbd_reg_id)
    where rpo1.obj_id is not null -- and r1.obj_id is null
--union select distinct z2.req_id, r2.obj_id as obj1, 1 as ot from ze z2
--    left join request.request_prev_obj rpo2 on(rpo2.request_id = z2.req_id and(rpo2.obj_exist!='neighbour' or rpo2.obj_exist is null))
--    left join zkoks.reg r2 on(r2.id = rpo2.bbd_reg_id) where r2.obj_id is not null and rpo2.obj_id is null
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
    q.request_number,
    (select count(distinct c.obj1) from base0 c) + (select count(distinct v.obj1) from base1 v) as cnt
from ze q


