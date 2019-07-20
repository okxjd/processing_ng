select distinct
    req.REQUEST_NUMBER as "номер заявки",
    decode(req.tax_free, 1, 'Бесплатно', 0, 'Платно') as "признак платности",
    (select st.name from cad_qual_dev.v$_request_state2 st where st.code like req.state_code) as "Статус заявки",
    (select z.name from cad_qual_dev.v$_delivery_docs z where z.code = req.delivery_type) as "способ получения исходящих",
    to_char(req.date_registration, 'YYYY-MM-DD') as "дата регистрации",
    to_char(req.date_close, 'YYYY-MM-DD') as "дата завершения",
    rd.global_state,
    rd.doc_num as "номер документа",
    rd.doc_name as "название документа",
    to_char(rd.doc_date, 'YYYY-MM-DD') as "дата подготовки",
    ruc.last_name||' '||ruc.first_name||' '||ruc.middle_name as "кто создал",
    sd.name as "отдел создавшего",
    rucc.last_name||' '||rucc.first_name||' '||rucc.middle_name as "кто удостоверил",
    sdc.name as "отдел удостоверившего"
from
    request.request req
    left join request.request_document rd on(rd.request_id = req.id  and rd.global_state = 1
        and(
            substr(rd.doc_subtype_code, 7) in(
               -- '020', -- (копии документов) -- !!!!!
                '039', -- (запрос в ОТИ)
                '043', -- Кадастровая выписка (граница)
                '023', -- Кадастровая выписка (ЗУ)
                '028', -- Кадастровая справка
                '034', -- Кадастровая выписка (ОКС)
                '022', -- Кадастровый паспорт (ЗУ)
                '024', -- Кадастровый паспорт (ОКС)
                '017', -- КПТ
                '026', -- Уведомление об отсутствии сведений
              --  '025', -- Решения
                '041'  -- Решения о необходимости устранения кад. ошибки
              --  '031', -- Акт определения кадастровой стоимости (ЗУ и ОКС)
                )
            or
            rd.doc_type_code in(
                '558101170000', -- (запрос в ОТИ)
                '558214040000', -- Кадастровая выписка (граница)
                '558214010000', -- Кадастровая выписка (ЗУ)
                '558218000000', -- Кадастровая справка
                '558213020000', -- Кадастровая выписка (ОКС)
                '558213010000', -- Кадастровый паспорт (ЗУ)
                '558213030000', -- Кадастровый паспорт (ОКС)
                '558217000000', -- КПТ
                '558501021400', -- Уведомление о неполучении и нерассмотрении
                '558501020100'  -- Уведомление об отсутствии сведений
                )
            )
        )
    left join ekon_admin.users ruc on (ruc.id = rd.user_id)
    left join ekon_admin.struct_division sd on(sd.id = ruc.div_id)
    left join request.document_certification dc on(dc.document_id = rd.id)
    left join ekon_admin.users rucc on(rucc.id = dc.user_id)
    left join ekon_admin.struct_division sdc on(sdc.id = rucc.div_id)
where
    req.REQUEST_NUMBER like :S1
    