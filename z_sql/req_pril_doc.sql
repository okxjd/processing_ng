select distinct
    req.request_number as request_number,
    rdd.doc_num as "����� ���������",
    (select name from CAD_QUAL_DEV.V$_ALL_REQ_DOC_TYPE where code = rdd.doc_type_id) as "��� ���������",
    rdd.doc_name as "�������� ���������",
    rdd.doc_date as "���� ������",
    rdd.doc_issuer as "��� �����",
    rdd.summa as "�����",
    rdi1.file_name as "�������� �����"
from
    request.request req
    left join request.request_declarant_document rdd on(req.id = rdd.request_id
      --  and rdd.doc_type_id in(
      --      '558221080000', -- ��� �� ����������� ����������� ����������� ����������� ���������
      --      '558501030500', -- ��� ����������� ����������� ��������� �������� ������������
      --      '558501030300'  -- ��� ����������� ����������� ��������� ��������� ��������
      --  )
    )
    left join request.request_document_img rdi1 on(rdi1.request_doc_id = rdd.id)
where
    req.request_number like :S1
order by req.request_number
