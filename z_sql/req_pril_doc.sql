select distinct
    req.request_number as request_number,
    rdd.doc_num as "номер документа",
    (select name from CAD_QUAL_DEV.V$_ALL_REQ_DOC_TYPE where code = rdd.doc_type_id) as "тип документа",
    rdd.doc_name as "название документа",
    rdd.doc_date as "дата выдачи",
    rdd.doc_issuer as "кто выдал",
    rdd.summa as "сумма",
    rdi1.file_name as "название файла"
from
    request.request req
    left join request.request_declarant_document rdd on(req.id = rdd.request_id
      --  and rdd.doc_type_id in(
      --      '558221080000', -- Акт об утверждении результатов определения кадастровой стоимости
      --      '558501030500', -- Акт определения кадастровой стоимости объектов недвижимости
      --      '558501030300'  -- Акт определения кадастровой стоимости земельных участков
      --  )
    )
    left join request.request_document_img rdi1 on(rdi1.request_doc_id = rdd.id)
where
    req.request_number like :S1
order by req.request_number
