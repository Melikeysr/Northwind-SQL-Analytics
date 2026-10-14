select top 1* from orders ;
select top 1* from customers ;
select top 1* from orderdetails ;
select top 1* from products ;

-----------BÖLÜM 1--------
--1
SELECT 
count(orderid) as toplam_sipariş 
FROM orders;
--1
select 
count(shippeddate) as toplam_teslim 
from orders
where shippeddate IS NOt NULL ;
--1
SELECT 
count(*) as Geciken_siparis_adeti
from orders
where shippeddate>requireddate;

--1
SELECT 
    ROUND(COUNT(CASE WHEN shippeddate > requireddate THEN 1 END) * 1.0 / COUNT(*), 4) AS gecikme_orani
FROM orders;


--2
select YEAR(Orderdate) as yil,
COUNT(OrderID) as yillara_göre_siparişA
from orders
group by YEAR(OrderDate);
--2
select YEAR(OrderDate)AS YIL,
COUNT(OrderID) as yillara_göre_siparişA,
CAST(ROUND(COUNT(CASE WHEN shippeddate > requireddate THEN 1 END) * 1.0 / COUNT(shippeddate), 4) AS DECIMAL(4,3)) AS gecikme_orani
from orders
group by YEAR(OrderDate);

--3
select c.Country,
CAST(ROUND(COUNT(CASE WHEN shippeddate > requireddate THEN 1 END) * 1.0 / COUNT(shippeddate), 4) AS DECIMAL(4,3)) AS ülkelere_göre_gecikme
from orders o 
left join customers c
ON o.customerid = c.customerid
group by c.Country
order by ülkelere_göre_gecikme DESC;
--4
SELECT
YEAR(Orderdate) AS YIL ,
ROUND(Sum(p.unitprice*od.quantity*(1-discount)),2) AS KAZANÇ,
CAST(ROUND(COUNT(CASE WHEN shippeddate > requireddate THEN 1 END) * 1.0 / COUNT(shippeddate), 4) AS DECIMAL(4,3)) AS yıllara_göre_gecikme
FROM orders o 
left join orderdetails od
on o.orderid=od.orderid 
left join products p 
On p.productid=od.productid
GROUP BY YEAR(Orderdate);
--5
SELECT o.employeeid ,
count(*)as siparis_adet,
rOUND(Sum(p.unitprice*od.quantity*(1-discount)),2) AS KAZANÇ,
CAST(ROUND(COUNT(CASE WHEN shippeddate > requireddate THEN 1 END) * 1.0 / COUNT(shippeddate), 4) AS DECIMAL(4,3)) AS gecikme_oranı
FROM orders o 
left join employees e
ON o.employeeid = e.employeeid
left join orderdetails od
On o.orderid =od.orderid
LEFT JOIN products P 
ON P.productid=od.productid
group by o.employeeid;
-----------BÖLÜM 2---------
--6
SELECT
c.customerid,
DATEDIFF(DAY ,Min(o.orderdate) ,Max(o.orderdate)) AS gun_farki,
DATEDIFF(DAY ,Min(o.orderdate) ,Max(o.orderdate))/count(o.orderid) as kac_kez,
round(Sum(p.unitprice*od.quantity*(1-discount)) /COUNT(c.customerid),2) as Ort_tutar,
COunt(CASE WHEN o.shippeddate>o.requireddate then 1 end) as GECİKME
FROM customers c 
left join orders o 
ON c.customerid =o.customerid 
left join orderdetails od 
on od.orderid=o.orderid
left join products p 
on p.productid =od.productid
group by c.customerid
Having DATEDIFF(DAY ,MAX(o.orderdate) ,Min(o.orderdate)) is NOT null
--7
SELECT
o.orderid,
c.country as müsteri_ülkesi,
o.shipcountry as gönderim_ülkesi
FROM customers c 
left join orders o 
on c.customerid =o.customerid
group by o.orderid,
c.country ,
o.shipcountry
having o.orderid is not null
--8
select
c.customerid,
Min(o.orderdate) as ilk_sipariş,
CAST(ROUND(COUNT(CASE WHEN shippeddate > requireddate THEN 1 END) * 1.0 / COUNT(shippeddate), 4) AS DECIMAL(4,3)) AS gecikme_orani
from orders o 
left join customers c 
on o.customerid =c.customerid 
group by c.customerid
	order by gecikme_orani desc
------BÖLÜM 3--------
--9
SELECT
categoryname,
ROUND(sum(p.unitprice*od.quantity*(1-od.discount)),2) AS TOPLAM_TUTAR,
count(o.orderid) AS TOPLAM_SATIŞ
FROM categories c 
left join products p 
on c.categoryid=p.categoryid
left join orderdetails od 
on p.productid =od.productid
left join orders o 
on o.orderid=od.orderid
group by(categoryname)
ORDER BY TOPLAM_TUTAR desc
--10
SELECT
c.categoryname,
CAST(ROUND(COUNT(CASE WHEN shippeddate > requireddate THEN 1 END) * 1.0 / COUNT(shippeddate), 4) AS DECIMAL(4,3)) AS gecikme_orani
FROM Orders o 
left join orderdetails od
on o.orderid =od.orderid
left join products p
on od.productid = p.productid
left join categories c 
on c.categoryid=p.categoryid
group by categoryname
order by gecikme_orani desc
--11
select
productname,
SUM(quantity) as toplam_adet,
round(SUM(od.quantity*p.unitprice*(1-discount)),2) as toplam_tutar
from orders o 
left join orderdetails od
on o.orderid = od.orderid 
left join products p
on od.productid=p.productid
group by productname
order by toplam_adet desc
--12
select top 50  discount from order_details ;

SELECT 
    p.productname,
    CASE 
        WHEN od.discount = 0 OR od.discount IS NULL THEN 'indirim yok'
        WHEN od.discount > 0 AND od.discount <= 0.15 THEN 'düşük indirim'
        WHEN od.discount > 0.15 THEN 'yüksek indirim'
    END AS indirim_grubu,
    ROUND(SUM(p.unitprice * od.quantity * (1 - od.discount)), 2) AS toplam_tutar,
    CAST(
        ROUND(
            COUNT(CASE WHEN o.shippeddate > o.requireddate THEN 1 END) * 1.0 
            / NULLIF(COUNT(o.shippeddate), 0), 
            4
        ) AS DECIMAL(5,4)
    ) AS gecikme_orani
FROM orders o 
JOIN [orderdetails] od 
    ON o.orderid = od.orderid
JOIN products p 
    ON p.productid = od.productid
GROUP BY 
    p.productname,
    CASE 
        WHEN od.discount = 0 OR od.discount IS NULL THEN 'indirim yok'
        WHEN od.discount > 0 AND od.discount <= 0.15 THEN 'düşük indirim'
        WHEN od.discount > 0.15 THEN 'yüksek indirim'
    END
ORDER BY 
    p.productname, 
    toplam_tutar DESC;
----- BÖLÜM 4------
--13
SELECT
orderid,
avg(freight) as ort_yük,
avg(DATEDIFF(DAY,requireddate ,orderdate)) as ort_teslimat,
case
when shippeddate>requireddate THEN 1 
end  as gecikme
FROM orders
group by orderid,RequiredDate,OrderDate,ShippedDate

--14
select
shipperid,
count(orderid) as sipariş_adeti,
round(avg(freight),2) as ort_yük,
CAST(ROUND(COUNT(CASE WHEN shippeddate > requireddate THEN 1 END) * 1.0 / COUNT(shippeddate), 4) AS DECIMAL(4,3)) AS gecikme_orani
from orders o 
left join shippers s
on o.shipvia = s.shipperid
group by shipperid


--15
select
productname,
DATEDIFF (DAY,requireddate ,orderdate) as teslim_süresi,
case 
when DATEDIFF (DAY,requireddate ,orderdate) <= 15 then 'hızlı teslimat'
when DATEDIFF (DAY,requireddate ,orderdate) > 15 and DATEDIFF (DAY,requireddate ,orderdate) <=25 then 'orta teslimat'
when DATEDIFF (DAY,requireddate ,orderdate) > 25 then 'geç teslimat'
end as teslimat_hızı,
CAST(ROUND(COUNT(CASE WHEN shippeddate > requireddate THEN 1 END) * 1.0 / COUNT(shippeddate), 4) AS DECIMAL(4,3)) AS gecikme_orani
from orders o 
left join orderdetails od
on o.orderid =od.orderid 
left join products p
on p.productid =od.productid
group by productname
,DATEDIFF (DAY,requireddate ,orderdate)
--16
SELECT 
    s.CompanyName AS kargo_firmasi,
    o.ShipCountry,
    o.ShipName,
    COUNT(o.OrderID) AS toplam_siparis,
    COUNT(CASE WHEN o.shippeddate > o.requireddate THEN 1 END) AS geciken_siparis,
    CAST(
        ROUND(
            COUNT(CASE WHEN o.shippeddate > o.requireddate THEN 1 END) * 1.0 
            / NULLIF(COUNT(o.shippeddate), 0), 
            4
        ) AS DECIMAL(5,4)
    ) AS gecikme_orani
FROM orders o 
LEFT JOIN Shippers s 
    ON o.ShipVia = s.ShipperID
GROUP BY 
    s.CompanyName,
    o.ShipCountry,
    o.ShipName
ORDER BY 
    gecikme_orani DESC;

    ------BÖLÜM 5-------
    SELECT * FROM Orders
--17
     SELECT 
     O.OrderID,
     Sum(unitprice*quantity*(1-Discount)) as siparis_tutari,
     CAST(
        ROUND(
            COUNT(CASE WHEN o.shippeddate > o.requireddate then 1 end)*1.0
            / NULLIF(count(o.shippeddate),0),4) as decimal (4,3))
             as gecikme_orani
     FROM orders o
     LEFT JOIN orderdetails od 
     on od.OrderID=O.OrderID
     GROUP BY O.OrderID
     order by siparis_tutari DESC
--18
select top 1 * from orders

select 
orderid,
DATEDIFF(day,orderdate,shippeddate) as teslimat_suresi,
freight
from orders
where DATEDIFF(day,orderdate,shippeddate) >15 and freight >50
order by teslimat_suresi desc

--19 
select top 1 * from employees
select top 1 * from shippers
select top 1 * from orders


select top 10
e.employeeid,
shipperid,
 cast (round(count(case when o.shippeddate>requireddate then 1 end) *1.0 / 
 NULLIF(count(shippeddate),0),4) as decimal(4,3)) as gecikme_orani
from orders o
LEFT join employees e
on o.employeeid = e.employeeid 
left join shippers s
on o.shipvia= s.shipperid
group by e. employeeid,shipperid
order by gecikme_orani DESC

------ BÖLÜM 6 -------
--20 Sipariş tutarı grupları için LiftScore hesaplayın: Grup Late Shipment Rate / Genel Late Shipment Rate.
-- 1. ADIM: Her siparişin tutarını ve gecikme durumunu hazırlayan geçici tablo
;WITH siparis_listesi AS (
    SELECT 
        o.orderid,
        -- Sipariş tutarı:
        SUM(od.unitprice * od.quantity * (1 - od.discount)) AS tutar,
        
        -- Tutar grubu:
        CASE 
            WHEN SUM(od.unitprice * od.quantity * (1 - od.discount)) <= 750 THEN '1. Düşük Tutar'
            WHEN SUM(od.unitprice * od.quantity * (1 - od.discount)) <= 1500 THEN '2. Orta Tutar'
            ELSE '3. Yüksek Tutar'
        END AS segment,
        
        -- Gecikti mi? (Evet = 1, Hayır = 0)
        CASE WHEN o.shippeddate > o.requireddate THEN 1.0 ELSE 0.0 END AS gecikti_mi,
        
        -- Kargolandı mı? (Evet = 1, Hayır = 0)
        CASE WHEN o.shippeddate IS NOT NULL THEN 1.0 ELSE 0.0 END AS kargolandi_mi
    FROM orders o
    LEFT JOIN [OrderDetails] od ON o.orderid = od.orderid
    GROUP BY o.orderid, o.shippeddate, o.requireddate
),

-- 2. ADIM: Tüm şirketin genel gecikme oranını tek bir kutuda bulma
genel_oran_kutusu AS (
    SELECT 
        SUM(gecikti_mi) / SUM(kargolandi_mi) AS sirket_genel_orani
    FROM siparis_listesi
)

-- 3. ADIM: Gruplama yapıp iki oranı birbirine bölme
SELECT 
    s.segment,
    COUNT(s.orderid) AS toplam_siparis,
    
    -- Grubun gecikme oranı:
    ROUND(SUM(s.gecikti_mi) / SUM(s.kargolandi_mi), 4) AS grup_gecikme_orani,
    
    -- Şirketin genel oranı:
    ROUND(g.sirket_genel_orani, 4) AS genel_gecikme_orani,
    
    -- LiftScore = Grup Oranı / Genel Oran
    ROUND((SUM(s.gecikti_mi) / SUM(s.kargolandi_mi)) / g.sirket_genel_orani, 2) AS lift_score

FROM siparis_listesi s
CROSS JOIN genel_oran_kutusu g   -- Tek satırlık genel oranı her grubun yanına yapıştırır
GROUP BY s.segment, g.sirket_genel_orani
ORDER BY s.segment;


--21 
select top 1 * from Shippers
select top 1 * from orders

with siparis_listesi as (
select 
OrderID,
CompanyName as kargo_firmasi,
case when ShippedDate> RequiredDate then 1.0 else 0.0 end as gecikti_mi,
case when ShippedDate is not null then 1.0 else 0.0 end as kargolandi_mi
from orders o  
LEFT JOIN shippers s  
on o.ShipVia=s.ShipperID ),

genel_oran as (
select
sum(gecikti_mi)/sum(kargolandi_mi) as genel_gecikme_orani
from siparis_listesi)

select 
sl.kargo_firmasi,
count(orderID) AS TOPLAM,
ROUND(sum(gecikti_mi)/sum(kargolandi_mi),4)as firma_gecikme_orani,
ROUND(genel_gecikme_orani,4) as genel_gecikme_orani,
ROUND(sum(gecikti_mi)/sum(kargolandi_mi),4) - genel_gecikme_orani as fark
from siparis_listesi sl
CROSS JOIN genel_oran g
GROUP BY sl.kargo_firmasi,genel_gecikme_orani
ORDER BY fark DESC


--22
WITH siparis_detay as(
select
o.OrderID,
ShipCountry ,
CompanyName as kargo_firmasi,
SUM(UnitPrice*Quantity*(1-Discount)) toplam_tutar,
case    
when SUM(UnitPrice*Quantity*(1-Discount)) <=750 then 'dusuk tutar'
when SUM(UnitPrice*Quantity*(1-Discount)) >750 and SUM(UnitPrice*Quantity*(1-Discount))<=1250 then 'dusuk tutar'
else 'yüksek tutar'
end as tutar_segmenti ,
case when ShippedDate > RequiredDate then 1.0 else 0.0 END as gecikti_mi,
case when ShippedDate is not null then 1.0 else 0.0 END as kargolandi_mi
from orders o
join OrderDetails od
on o.OrderID=od.OrderID
JOIN Shippers s
on o.ShipVia=s.ShipperID
GROUP BY o.orderID,ShipCountry,CompanyName,ShippedDate,RequiredDate)

SELECt
kargo_firmasi,
ShipCountry,
tutar_segmenti,
sum(OrderID) AS toplam_siparis,
ROUND(sum(toplam_tutar),4) as toplam_ciro,
sum(gecikti_mi) as toplam_gecikme,
CAST(
        ROUND(
            (SUM(gecikti_mi) / NULLIF(SUM(kargolandi_mi), 0)) * 100, 
            2
        ) AS DECIMAL(5,2)
    ) AS gecikme_yuzdesi
from siparis_detay
GROUP BY kargo_firmasi,
ShipCountry,
tutar_segmenti
ORDER BY 
gecikme_yuzdesi DESC

--23
;WITH siparis_ozellikleri AS (
    SELECT 
        o.OrderID,
        o.OrderDate,
        o.RequiredDate,
        o.Freight,
        s.CompanyName AS kargo_firmasi,
        o.ShipCountry,
        
        -- Termin süresi (Sipariş anı ile istenen tarih arasındaki gün farkı):
        DATEDIFF(day, o.OrderDate, o.RequiredDate) AS termin_gun_sayisi,
        
        -- Sepet özellikleri:
        COUNT(od.ProductID) AS kalem_sayisi,
        SUM(od.Quantity) AS toplam_adet,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS toplam_tutar
    FROM Orders o
    JOIN [OrderDetails] od ON o.OrderID = od.OrderID
    JOIN Shippers s ON o.ShipVia = s.ShipperID
    GROUP BY 
        o.OrderID, 
        o.OrderDate, 
        o.RequiredDate, 
        o.Freight, 
        s.CompanyName, 
        o.ShipCountry
)

SELECT 
    OrderID,
    ShipCountry,
    kargo_firmasi,
    termin_gun_sayisi,
    kalem_sayisi,
    toplam_adet,
    ROUND(toplam_tutar, 2) AS toplam_tutar,
    
    -- Kural Tabanlı Risk Skoru (0 - 100 Puan):
    (
        -- Kural 1: Termin süresi 14 günden az ise acil/riskli (+35)
        CASE WHEN termin_gun_sayisi < 14 THEN 35 ELSE 0 END
        +
        -- Kural 2: Toplam adet 100'den fazlaysa (+25)
        CASE WHEN toplam_adet > 100 THEN 25 ELSE 0 END
        +
        -- Kural 3: Tutar 2000'den fazlaysa (+20)
        CASE WHEN toplam_tutar > 2000 THEN 20 ELSE 0 END
        +
        -- Kural 4: Kargo taşıma ücreti 100'ün üzerindeyse (+10)
        CASE WHEN Freight > 100 THEN 10 ELSE 0 END
        +
        -- Kural 5: 4 veya daha fazla farklı ürün kalemi varsa (+10)
        CASE WHEN kalem_sayisi >= 4 THEN 10 ELSE 0 END
    ) AS OperationalRiskScore,

    -- Risk Segmenti:
    CASE 
        WHEN (
            CASE WHEN termin_gun_sayisi < 14 THEN 35 ELSE 0 END +
            CASE WHEN toplam_adet > 100 THEN 25 ELSE 0 END +
            CASE WHEN toplam_tutar > 2000 THEN 20 ELSE 0 END +
            CASE WHEN Freight > 100 THEN 10 ELSE 0 END +
            CASE WHEN kalem_sayisi >= 4 THEN 10 ELSE 0 END
        ) >= 60 THEN 'Yüksek Risk'
        WHEN (
            CASE WHEN termin_gun_sayisi < 14 THEN 35 ELSE 0 END +
            CASE WHEN toplam_adet > 100 THEN 25 ELSE 0 END +
            CASE WHEN toplam_tutar > 2000 THEN 20 ELSE 0 END +
            CASE WHEN Freight > 100 THEN 10 ELSE 0 END +
            CASE WHEN kalem_sayisi >= 4 THEN 10 ELSE 0 END
        ) >= 30 THEN 'Orta Risk'
        ELSE 'Düşük Risk'
    END AS risk_segmenti

FROM siparis_ozellikleri
ORDER BY OperationalRiskScore DESC, OrderID;

--24
;WITH siparis_metrikleri AS (
    SELECT 
        o.OrderID,
        o.ShippedDate,
        o.RequiredDate,
        
        -- Model Özellikleri:
        DATEDIFF(day, o.OrderDate, o.RequiredDate) AS termin_gun,
        COUNT(od.ProductID) AS kalem_sayisi,
        SUM(od.Quantity) AS toplam_adet,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS toplam_tutar,
        o.Freight
    FROM Orders o
    JOIN [OrderDetails] od ON o.OrderID = od.OrderID
    GROUP BY 
        o.OrderID, 
        o.OrderDate, 
        o.RequiredDate, 
        o.ShippedDate, 
        o.Freight
),

risk_skorlu_siparisler AS (
    SELECT 
        OrderID,
        ShippedDate,
        RequiredDate,
        
        -- Gerçekleşen durum bayrakları:
        CASE WHEN ShippedDate > RequiredDate THEN 1.0 ELSE 0.0 END AS gecikti_mi,
        CASE WHEN ShippedDate IS NOT NULL THEN 1.0 ELSE 0.0 END AS kargolandi_mi,
        
        -- Risk Segmenti Belirleme:
        CASE 
            WHEN (
                CASE WHEN termin_gun < 14 THEN 35 ELSE 0 END +
                CASE WHEN toplam_adet > 100 THEN 25 ELSE 0 END +
                CASE WHEN toplam_tutar > 2000 THEN 20 ELSE 0 END +
                CASE WHEN Freight > 100 THEN 10 ELSE 0 END +
                CASE WHEN kalem_sayisi >= 4 THEN 10 ELSE 0 END
            ) >= 60 THEN '1. Yüksek Risk'
            WHEN (
                CASE WHEN termin_gun < 14 THEN 35 ELSE 0 END +
                CASE WHEN toplam_adet > 100 THEN 25 ELSE 0 END +
                CASE WHEN toplam_tutar > 2000 THEN 20 ELSE 0 END +
                CASE WHEN Freight > 100 THEN 10 ELSE 0 END +
                CASE WHEN kalem_sayisi >= 4 THEN 10 ELSE 0 END
            ) >= 30 THEN '2. Orta Risk'
            ELSE '3. Düşük Risk'
        END AS risk_seviyesi
    FROM siparis_metrikleri
)

SELECT 
    risk_seviyesi,
    COUNT(OrderID) AS toplam_siparis,
    SUM(gecikti_mi) AS geciken_siparis_sayisi,
    SUM(kargolandi_mi) AS kargolanan_siparis_sayisi,
    
    -- Gerçekleşen Late Shipment Rate (%):
    CAST(
        ROUND(
            (SUM(gecikti_mi) / NULLIF(SUM(kargolandi_mi), 0)) * 100, 
            2
        ) AS DECIMAL(5,2)
    ) AS gercek_gecikme_orani_yuzde

FROM risk_skorlu_siparisler
GROUP BY risk_seviyesi
ORDER BY risk_seviyesi;
