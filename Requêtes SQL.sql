-- Création de la vue par gamme
CREATE VIEW ca_nbProducts_cout_marge_parGamme AS(
SELECT 
    p.productLine, 
    SUM(od.quantityOrdered) AS quantity_ordered,
    SUM(od.quantityOrdered * od.priceEach) AS CA_gamme, 
    SUM(od.quantityOrdered * p.buyPrice) AS cout_achat,
    SUM(od.quantityOrdered * od.priceEach) - SUM(od.quantityOrdered * p.buyPrice) AS marge_brute,
    CASE 
		WHEN o.orderDate IS NOT NULL THEN MONTHNAME(o.orderDate)
        ELSE NULL
    END AS mois,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN MONTH(o.orderDate)
        ELSE NULL
    END AS num_mois,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN YEAR(o.orderDate)
        ELSE NULL
    END AS annee
FROM products p
JOIN orderdetails od ON od.productCode = p.productCode
JOIN orders o ON o.ordernumber = od.orderNumber
WHERE o.status != "Cancelled"
GROUP BY p.productLine, annee , mois, num_mois
ORDER BY annee DESC, num_mois DESC, CA_gamme DESC);


-- Création de la vue par produit
CREATE VIEW ca_nbProducts_cout_marge_parProduit AS(
SELECT 
    p.productCode, 
    SUM(od.quantityOrdered) AS quantity_ordered,
    SUM(od.quantityOrdered * od.priceEach) AS CA_produit, 
    SUM(od.quantityOrdered * p.buyPrice) AS cout_achat,
    SUM(od.quantityOrdered * od.priceEach) - SUM(od.quantityOrdered * p.buyPrice) AS marge_brute,
	CASE 
		WHEN o.orderDate IS NOT NULL THEN MONTHNAME(o.orderDate)
        ELSE NULL
    END AS mois,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN MONTH(o.orderDate)
        ELSE NULL
    END AS num_mois,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN YEAR(o.orderDate)
        ELSE NULL
    END AS annee
FROM products p
JOIN orderdetails od ON od.productCode = p.productCode
JOIN orders o ON o.ordernumber = od.orderNumber
WHERE o.status != "Cancelled"
GROUP BY p.productCode, annee, num_mois, mois
ORDER BY annee DESC, num_mois DESC, CA_produit DESC);


-- Création de la vue par office
CREATE VIEW CA_cout_marge_par_office AS (
SELECT 
	ofi.officeCode,
    ofi.territory,
    ofi.country,
    ofi.city,
    SUM(od.quantityOrdered * od.priceEach) AS CA_par_office, 
	SUM(od.quantityOrdered * p.buyPrice) AS cout_achat,
    SUM(od.quantityOrdered * od.priceEach) - SUM(od.quantityOrdered * p.buyPrice) AS marge_brute,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN MONTHNAME(o.orderDate)
        ELSE NULL
    END AS mois,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN MONTH(o.orderDate)
        ELSE NULL
    END AS num_mois,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN YEAR(o.orderDate)
        ELSE NULL
    END AS annee
FROM orderdetails od
JOIN orders o USING (orderNumber)
JOIN products p USING(productCode)
JOIN customers c USING(customerNumber)
JOIN employees e on c.salesRepEmployeeNumber = e.employeeNumber
JOIN offices ofi USING(officeCode)
WHERE o.`status` != 'Cancelled'
GROUP BY ofi.officeCode, ofi.territory, ofi.country, ofi.city, annee, num_mois, mois
ORDER BY annee DESC, num_mois DESC, CA_par_office DESC);


-- Création de la vue par employé
CREATE VIEW CA_par_employee AS (
    SELECT 
		e.employeeNumber,
        e.lastName, 
        e.firstName, 
        COALESCE(ROUND(SUM(od.quantityOrdered * od.priceEach), 0), 0) AS total_CA_by_employee,
        COALESCE(ROUND(SUM(od.quantityOrdered * od.priceEach) - SUM(od.quantityOrdered * p.buyPrice), 0), 0) AS marge_brute_by_employee,
            CASE 
        WHEN o.orderDate IS NOT NULL THEN MONTHNAME(o.orderDate)
        ELSE NULL
    END AS mois,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN MONTH(o.orderDate)
        ELSE NULL
    END AS num_mois,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN YEAR(o.orderDate)
        ELSE NULL
    END AS annee
    FROM employees e
    LEFT JOIN customers c ON c.salesRepEmployeeNumber = e.employeeNumber
    LEFT JOIN orders o ON o.customerNumber = c.customerNumber
    LEFT JOIN orderdetails od ON od.orderNumber = o.orderNumber
    LEFT JOIN products p ON p.productCode = od.productCode
    WHERE o.status != "Cancelled" OR (o.status IS NULL AND e.jobTitle = "Sales Rep")
    GROUP BY annee, num_mois, mois, e.employeeNumber
    ORDER BY annee DESC, num_mois DESC,total_CA_by_employee DESC
    );


-- Creation de la vue par client
CREATE VIEW CA_marge_par_pays_client AS(
SELECT
c.country,
SUM(quantityOrdered * priceEach) AS CA,
SUM(od.quantityOrdered * p.buyPrice) AS cout_achat,
SUM(od.quantityOrdered * od.priceEach) - SUM(od.quantityOrdered * p.buyPrice) AS marge_brute,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN MONTHNAME(o.orderDate)
        ELSE NULL
    END AS mois,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN MONTH(o.orderDate)
        ELSE NULL
    END AS num_mois,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN YEAR(o.orderDate)
        ELSE NULL
    END AS annee

FROM orders o

JOIN orderdetails od USING (orderNumber)
JOIN customers c USING (customerNumber)
JOIN products p using(productCode)

GROUP BY c.country, annee , mois, num_mois
ORDER by annee DESC, num_mois DESC);

 
 -- Création de la vue par id client
CREATE VIEW id_client_pays AS (
Select c.CustomerNumber, ca_p.country
FROM customers c
JOIN ca_marge_par_pays_client ca_p on c.country = ca_p.country );


-- Création de la vue des commandes annulées
CREATE VIEW commandes_annulees AS (
SELECT  o.customerNumber, c.customerName, o.orderNumber, SUM(od.quantityOrdered * od.priceEach) as montant_annulation, count(`status`) as nb_annulation,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN MONTHNAME(o.orderDate)
        ELSE NULL
    END AS mois,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN MONTH(o.orderDate)
        ELSE NULL
    END AS num_mois,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN YEAR(o.orderDate)
        ELSE NULL
    END AS annee
FROM orders o
JOIN orderdetails od ON od.orderNumber = o.orderNumber
JOIN customers c ON c.customerNumber = o.customerNumber
WHERE o.status = "Cancelled"
GROUP BY annee, mois, num_mois, o.orderNumber
ORDER BY annee DESC, num_mois DESC, nb_annulation DESC);


-- Création de la vue du total des commandes par customer
CREATE VIEW total_orders_by_customer AS(
SELECT o.customerNumber, c.customerName, SUM(od.quantityOrdered * od.priceEach) as totalcommande
FROM orderdetails od
JOIN orders o ON od.orderNumber = o.orderNumber
JOIN customers c USING(customerNumber)
GROUP BY o.customerNumber);


-- Création de la vue des paiements par client
CREATE VIEW total_payment_by_customer AS (
SELECT pay.customerNumber, c.customerName, SUM(pay.Amount) AS total_regle
FROM payments pay
JOIN customers c USING (customerNumber)
GROUP BY pay.customerNumber);


-- Création de la vue des dettes by customers et credit restant
CREATE VIEW dettes_clients AS(
WITH Dettes AS (
    SELECT
		c.customerNumber,
        tobc.totalcommande - tpbc.total_regle AS total_dette
    FROM total_orders_by_customer tobc
        JOIN total_payment_by_customer tpbc USING(customerNumber)
        JOIN customers c USING(customerNumber)
)
SELECT  c.customerNumber,
        c.customerName,
        d.total_dette,
        c.creditLimit,
        c.creditLimit - total_dette as creditRestant
FROM customers c
JOIN Dettes d USING (customerNumber)
WHERE total_dette > 0
ORDER BY creditRestant );

-- Création de la vue du CA par employé
CREATE VIEW CA_par_employee AS (
SELECT 
	e.lastName, 
    e.firstName, 
    ROUND((SUM(od.quantityOrdered * od.priceEach)),0) AS total_CA_by_employee,
    ROUND((SUM(od.quantityOrdered * od.priceEach) - SUM(od.quantityOrdered * p.buyPrice)),0) AS marge_brute_by_employee
FROM employees e
LEFT JOIN customers c on e.employeeNumber = c.salesRepEmployeeNumber
LEFT JOIN orders o USING(customerNumber)
LEFT JOIN orderdetails od USING(orderNumber)
LEFT JOIN products p ON p.productCode = od.productCode
WHERE o.`status` != "Cancelled" OR (o.status IS NULL AND e.jobTitle = "Sales Rep")
group BY employeeNumber
order by total_CA_by_employee DESC);

-- Création de la table regroupant tous les ID
CREATE VIEW list_id AS (
SELECT cu.customerNumber, em.employeeNumber, od.orderNumber, od.productCode, p.productLine
FROM customers cu
join employees em on cu.salesRepEmployeeNumber = em.employeeNumber
join orders o USING(customerNumber)
join orderdetails od on o.orderNumber = od.orderNumber
join products p on p.productCode = od.productCode);

-- Création de la vue par gamme avec quantités, CA, coût d'achat et marge brute
CREATE VIEW ca_nbProducts_cout_marge_parGamme AS(
SELECT 
    p.productLine, 
    SUM(od.quantityOrdered) AS quantity_ordered,
    SUM(od.quantityOrdered * od.priceEach) AS CA_gamme, 
    SUM(od.quantityOrdered * p.buyPrice) AS cout_achat,
    SUM(od.quantityOrdered * od.priceEach) - SUM(od.quantityOrdered * p.buyPrice) AS marge_brute,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN MONTHNAME(o.orderDate)
        ELSE NULL
    END AS mois,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN MONTH(o.orderDate)
        ELSE NULL
    END AS num_mois,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN YEAR(o.orderDate)
        ELSE NULL
    END AS annee
FROM products p
JOIN orderdetails od ON od.productCode = p.productCode
JOIN orders o ON o.ordernumber = od.orderNumber
WHERE o.status != "Cancelled"
GROUP BY p.productLine, annee , mois, num_mois
ORDER BY annee DESC, num_mois DESC);


-- Création de la vue par produits avec quantités, CA, coût d'achat et marge brute
CREATE VIEW ca_nbProducts_cout_marge_parProduit AS(
SELECT 
    p.productCode, 
    SUM(od.quantityOrdered) AS quantity_ordered,
    SUM(od.quantityOrdered * od.priceEach) AS CA_produit, 
    SUM(od.quantityOrdered * p.buyPrice) AS cout_achat,
    SUM(od.quantityOrdered * od.priceEach) - SUM(od.quantityOrdered * p.buyPrice) AS marge_brute,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN MONTHNAME(o.orderDate)
        ELSE NULL
    END AS mois,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN MONTH(o.orderDate)
        ELSE NULL
    END AS num_mois,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN YEAR(o.orderDate)
        ELSE NULL
    END AS annee
FROM products p
JOIN orderdetails od ON od.productCode = p.productCode
JOIN orders o ON o.ordernumber = od.orderNumber
WHERE o.status != "Cancelled"
GROUP BY p.productCode, annee, num_mois, mois
ORDER BY annee DESC, num_mois DESC);


-- Création de la vue des annulations
CREATE VIEW commandes_annulees AS (
SELECT  o.customerNumber, c.customerName, o.orderNumber, SUM(od.quantityOrdered * od.priceEach) as total_annulation
FROM orders o
JOIN orderdetails od ON od.orderNumber = o.orderNumber
JOIN customers c ON c.customerNumber = o.customerNumber
WHERE o.`status` = "Cancelled"
GROUP BY o.orderNumber
ORDER BY total_annulation DESC);

-- Création de la vue du total des commandes par customer
CREATE VIEW total_orders_by_customer AS(
SELECT o.customerNumber, SUM(od.quantityOrdered * od.priceEach) as totalcommande
FROM orderdetails od
JOIN orders o ON od.orderNumber = o.orderNumber
GROUP BY o.customerNumber
ORDER BY o.customerNumber ASC);

-- Création de la vue du total des règlements par customer
CREATE VIEW total_payment_by_customer AS (
SELECT pay.customerNumber, SUM(pay.Amount) AS total_regle
FROM payments pay
GROUP BY pay.customerNumber);

-- Création de la vue du CA par office/pays/région
CREATE VIEW CA_cout_marge_par_office AS (
SELECT 
    ofi.officeCode,
    ofi.territory,
    ofi.country,
    ofi.city,
    SUM(od.quantityOrdered * od.priceEach) AS CA_par_office, 
    SUM(od.quantityOrdered * p.buyPrice) AS cout_achat,
    SUM(od.quantityOrdered * od.priceEach) - SUM(od.quantityOrdered * p.buyPrice) AS marge_brute,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN MONTHNAME(o.orderDate)
        ELSE NULL
    END AS mois,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN MONTH(o.orderDate)
        ELSE NULL
    END AS num_mois,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN YEAR(o.orderDate)
        ELSE NULL
    END AS annee
FROM orderdetails od
JOIN orders o USING (orderNumber)
JOIN products p USING(productCode)
JOIN customers c USING(customerNumber)
JOIN employees e on c.salesRepEmployeeNumber = e.employeeNumber
JOIN offices ofi USING(officeCode)
WHERE o.status != 'Cancelled'
GROUP BY ofi.officeCode, ofi.territory, ofi.country, ofi.city, annee, num_mois, mois
ORDER BY annee DESC, num_mois DESC, CA_par_office DESC);

-- Total dettes by customers et credit restant
CREATE VIEW dettes_clients AS(
WITH Dettes AS (
    SELECT
        c.customerNumber,
        tobc.totalcommande - tpbc.total_regle AS total_dette
    FROM total_orders_by_customer tobc
        JOIN total_payment_by_customer tpbc USING(customerNumber)
        JOIN customers c USING(customerNumber)
)
SELECT  c.customerNumber,
        c.customerName,
        d.total_dette,
        c.creditLimit,
        c.creditLimit - total_dette as creditRestant
FROM customers c
JOIN Dettes d USING (customerNumber)
WHERE total_dette > 0
ORDER BY creditRestant );

-- Creation vue montant commande et marge en fonction de la date
CREATE VIEW montant_commande_et_marge_par_date AS(
SELECT 
    ofi.territory,
    ofi.country,
    ofi.city,
    o.orderDate,
    SUM(od.quantityOrdered * od.priceEach) AS CA_par_office, 
    SUM(od.quantityOrdered * p.buyPrice) AS cout_achat,
    SUM(od.quantityOrdered * od.priceEach) - SUM(od.quantityOrdered * p.buyPrice) AS marge_brute,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN MONTHNAME(o.orderDate)
        ELSE NULL
    END AS mois,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN MONTH(o.orderDate)
        ELSE NULL
    END AS num_mois,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN YEAR(o.orderDate)
        ELSE NULL
    END AS annee
FROM orderdetails od
JOIN orders o USING (orderNumber)
JOIN products p USING(productCode)
JOIN customers c USING(customerNumber)
JOIN employees e on c.salesRepEmployeeNumber = e.employeeNumber
JOIN offices ofi USING(officeCode)
WHERE o.status != 'Cancelled'
GROUP BY ofi.territory, ofi.country, ofi.city, o.orderDate
ORDER BY o.orderDate);


-- Creation vu CA/marge/mois par pays de client
CREATE VIEW CA_marge_par_pays_client AS(
SELECT
c.country,
SUM(quantityOrdered * priceEach) AS CA,
SUM(od.quantityOrdered * p.buyPrice) AS cout_achat,
SUM(od.quantityOrdered * od.priceEach) - SUM(od.quantityOrdered * p.buyPrice) AS marge_brute,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN MONTHNAME(o.orderDate)
        ELSE NULL
    END AS mois,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN MONTH(o.orderDate)
        ELSE NULL
    END AS num_mois,
    CASE 
        WHEN o.orderDate IS NOT NULL THEN YEAR(o.orderDate)
        ELSE NULL
    END AS annee

FROM orders o

JOIN orderdetails od USING (orderNumber)
JOIN customers c USING (customerNumber)
JOIN products p using(productCode)

GROUP BY c.country, annee , mois, num_mois
ORDER by annee DESC, num_mois DESC)

-- Nombre d'employés et de clients par office
SELECT ofi.officecode, ofi.country, ofi.city,  COUNT(DISTINCT(e.employeeNumber)) as number_employees, COUNT(c.customerNumber) as number_customers
FROM offices ofi
JOIN employees e USING (officeCode)
LEFT JOIN customers c ON e.employeeNumber=c.salesRepEmployeeNumber
GROUP BY ofi.officecode