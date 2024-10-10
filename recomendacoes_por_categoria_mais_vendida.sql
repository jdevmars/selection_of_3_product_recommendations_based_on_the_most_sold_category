
/*

2
Unesp
livrariaunesp.com.br (Id: 11216)

TASK: Obter 3 recomendações de produtos que pertençam à categoria do produto mais vendido

*/

-- categorias mais presentes (não necessariamente as mais vendidas)

SELECT
	S.ProductCategoryIds, COUNT(S.ProductCategoryIds) as Frequencia 
FROM dt_Sku AS S
GROUP BY S.ProductCategoryIds
ORDER BY Frequencia DESC

/**********************************************************************************************************************/
/**********************************************************************************************************************/

-- EXIBE OS PRODUTOS MAIS VENDIDO(S) E SUA(S) CATEGORIA(S)
-- Categorias mais vendidas (exibe as primeira e também todas as categorias as quais os produtos mais vendidos pertencem) [vale a pena conferir]

SELECT
	SK.Id AS SKU_ID, COUNT(SK.Id) AS Frequencia_Quantidade, SK.ProductName, SK.ImageUrlBig, 
	TRIM('/' FROM SK.ProductCategoryIds) AS Categoria, 
	IIF(
		CHARINDEX('/', TRIM('/' FROM SK.ProductCategoryIds)) = 0, 
		TRIM('/' FROM SK.ProductCategoryIds), 
		SUBSTRING(TRIM('/' FROM SK.ProductCategoryIds), 1, CHARINDEX('/', TRIM('/' FROM SK.ProductCategoryIds))-1)
		) 
	AS Primeira_Categoria
FROM dt_Order AS O 
INNER JOIN dt_OrderItem OI 
ON CONCAT('00-',O.OrderId) = OI.OrderId
INNER JOIN dt_Sku SK 
ON OI.SkuId = SK.Id
GROUP BY SK.Id, SK.ProductName, SK.ProductCategoryIds, SK.ImageUrlBig
ORDER BY Frequencia_Quantidade DESC

/**********************************************************************************************************************/
/**********************************************************************************************************************/

-- getMostSoldCategory (Obtém a categoria do produto mais vendido de todos)
---- a TOP, seleciona apenas a primeira categoria quando mais de uma

SELECT 
	TOP 1 SK.Id AS SKU_ID, COUNT(SK.Id) AS Frequencia_Quantidade, 
	IIF(
		CHARINDEX('/', TRIM('/' FROM SK.ProductCategoryIds)) = 0, 
		TRIM('/' FROM SK.ProductCategoryIds), 
		SUBSTRING(TRIM('/' FROM SK.ProductCategoryIds), 1, CHARINDEX('/', TRIM('/' FROM SK.ProductCategoryIds))-1)
		) 
	AS Categoria
FROM dt_Order AS O 
INNER JOIN dt_OrderItem OI 
ON CONCAT('00-',O.OrderId) = OI.OrderId
INNER JOIN dt_Sku SK 
ON OI.SkuId = SK.Id
GROUP BY SK.Id, SK.ProductCategoryIds
ORDER BY Frequencia_Quantidade DESC

-- getThreeRecommendationsBasedOnCategory (Obtém 3 recomendações baseando-se na categoria do produto mais vendido)
---- apenas a primeira categoria quando mais de uma

SELECT TOP 3 ProductName, ImageUrlBig, ProductCategoryIds, 
	FORMAT(S.Price, 'C2', 'pt-BR') AS Preço, 
	CONCAT('https://www.livrariaunesp.com.br', DetailUrl) AS URL
FROM dt_Sku AS S
WHERE IsActive = 'true'
AND ProductCategoryIds LIKE CONCAT('/', @categoriaTOP, '/')
ORDER BY NEWID()

/**********************************************************************************************************************/
/**********************************************************************************************************************/

-- getMostSoldCategory (Obtém a categoria do produto mais vendido de todos)
---- a TOP, selecionando todas as categorias quando mais de uma

SELECT
	TOP 1 SK.Id AS SKU_ID, COUNT(SK.Id) AS Frequencia_Quantidade, SK.ProductCategoryIds AS Categoria
FROM dt_Order AS O
INNER JOIN dt_OrderItem OI 
ON CONCAT('00-',O.OrderId) = OI.OrderId
INNER JOIN dt_Sku SK 
ON OI.SkuId = SK.Id
GROUP BY SK.Id, SK.ProductCategoryIds
ORDER BY Frequencia_Quantidade DESC

-- getThreeRecommendationsBasedOnCategory (Obtém 3 recomendações baseando-se na categoria do produto mais vendido)
---- 3 recomendações da categoria mais vendida (quando o mais vendido pertence a mais de uma categoria, considera todas na busca, não apenas a primeira)

SELECT
	TOP 3 ProductName, ImageUrlBig, ProductCategoryIds, FORMAT(S.Price, 'C2', 'pt-BR') AS Preço, CONCAT('https://www.livrariaunesp.com.br', DetailUrl) AS URL
FROM dt_Sku AS S
WHERE IsActive = 'true'
AND ProductCategoryIds LIKE @categoriaTOP
ORDER BY NEWID()

/**********************************************************************************************************************/
/**********************************************************************************************************************/

/*
<var rows="GetRowsByTemplate('getMostSoldCategory')"/>

<if condition="rows.Count > 0">
  <h3>Sku: ${rows[0]['SKU_ID']} | Categoria: ${rows[0]['Categoria']}</h3> 
   <br>
   <var recom="GetRowsByTemplate('getThreeRecommendationsBasedOnCategory', new [] { new Param('categoriaTOP', rows[0]['Categoria'] ) })"/>
	   <if condition="recom.Count > 0">
     <table border="1">
     <tr>
       <td><a href="${recom[0]['URL']}" target="_blank"><img src="${recom[0]['ImageUrlBig']}" width="200px" height="200px"></a></td>
       <td>${recom[0]['ProductName']}</td>
       <td>${recom[0]['Preço']}</td>
     </tr>
     <tr>
       <td><a href="${recom[1]['URL']}" target="_blank"><img src="${recom[1]['ImageUrlBig']}" width="200px" height="200px"></a></td>
       <td>${recom[1]['ProductName']}</td>
       <td>${recom[1]['Preço']}</td>
     </tr>
     <tr>
       <td><a href="${recom[2]['URL']}" target="_blank"><img src="${recom[2]['ImageUrlBig']}" width="200px" height="200px"></a></td>
       <td>${recom[2]['ProductName']}</td>
       <td>${recom[2]['Preço']}</td>
     </tr>
   </table>
   </if>
   <else>
     Sem recomendações
   </else>
</if>
*/