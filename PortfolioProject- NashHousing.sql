SELECT *
FROM [Portfolio Project].dbo.NashHousing



--STANDARDIZING SALE DATE FORMAT	

SELECT SaleDateConverted, CONVERT(Date,SaleDate) 
FROM [Portfolio Project].dbo.NashHousing


ALTER TABLE NashHousing
ADD SaleDateConverted Date

UPDATE NashHousing
SET SaleDateConverted = CONVERT(Date,SaleDate) 


--POPULATE PROPERTY ADDRESS DATA

SELECT *
FROM [Portfolio Project].dbo.NashHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Project].dbo.NashHousing a
JOIN [Portfolio Project].dbo.NashHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project].dbo.NashHousing a
JOIN [Portfolio Project].dbo.NashHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress IS NULL


--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMN(ADDRESS, CITY, STATE)



SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM [Portfolio Project].dbo.NashHousing

ALTER TABLE NashHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 

ALTER TABLE NashHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


SELECT *
FROM [Portfolio Project].dbo.NashHousing


--
--BREAKING OUT OWNER ADDRESS INTO INDIVIDUAL COLUMN(ADDRESS, CITY, STATE)

SELECT OwnerAddress
FROM [Portfolio Project].dbo.NashHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [Portfolio Project].dbo.NashHousing

ALTER TABLE [Portfolio Project].dbo.NashHousing--using NashHousing is giving an error
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE [Portfolio Project].dbo.NashHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [Portfolio Project].dbo.NashHousing--using NashHousing is giving an error
ADD OwnerSplitCity NVARCHAR(255)

UPDATE [Portfolio Project].dbo.NashHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [Portfolio Project].dbo.NashHousing--using NashHousing is giving an error
ADD OwnerSplitState NVARCHAR(255)

UPDATE [Portfolio Project].dbo.NashHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

------



--CHANGE Y AND N TO YES AND NO IN 'Sold as Vacant' FIELD

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project].dbo.NashHousing
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM [Portfolio Project].dbo.NashHousing

UPDATE [Portfolio Project].dbo.NashHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM [Portfolio Project].dbo.NashHousing



--REMOVING DUPLICATES

WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num	 

FROM [Portfolio Project].dbo.NashHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--DELETING THE DUPLICATES
WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num	 

FROM [Portfolio Project].dbo.NashHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


--DELETE UNUSED COLUMNS

SELECT *
FROM [Portfolio Project].dbo.NashHousing

ALTER TABLE [Portfolio Project].dbo.NashHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio Project].dbo.NashHousing
DROP COLUMN SaleDate