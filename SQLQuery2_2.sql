SELECT *
FROM Portfolio..DataSheet



--Standardize the  date format

ALTER TABLE Portfolio..DataSheet
ADD SaleDateConverte date;

UPDATE Portfolio..DataSheet
SET SaleDateConverte = CAST(SaleDate as DATE);

SELECT SaleDateConverte, CAST(SaleDate as Date) as ConvertedDate
FROM Portfolio..DataSheet;

--Address update

Select a.ParcelId, a.PropertyAddress, b.ParcelId, b.PropertyAddress
FROM Portfolio..DataSheet a
JOIN Portfolio..DataSheet b
ON a.ParcelId = b.ParcelId
AND a.UniqueId <> b.UniqueId
Where a.PropertyAddress is null;

UPDATE a
SET PropertyAddress = IsNull(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..DataSheet a
JOIN Portfolio..DataSheet b
ON a.parcelId = b.parcelId
AND a.uniqueId <> b.uniqueId

--SEPERATE the ADDRESS
 
SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as City
--CHARINDEX(',', PropertyAddress)
From Portfolio..DataSheet;

ALTER TABLE Portfolio..DataSheet
ADD PropertySplitAddress varchar(255);

UPDATE Portfolio..DataSheet
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE Portfolio..DataSheet
ADD PropertySplitCity nvarchar(255);

UPDATE Portfolio..DataSheet
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

SELECT PropertyAddress, OwnerAddress
FROM Portfolio..DataSheet
Where OwnerAddress is null;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
FROM Portfolio..DataSheet
WHERE OwnerAddress is not null;

ALTER TABLE Portfolio..DataSheet
ADD OwnerSplitAddress nvarchar(255);

UPDATE Portfolio..DataSheet
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE Portfolio..DataSheet
ADD OwnerSplitCity nvarchar(255);

UPDATE Portfolio..DataSheet
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE Portfolio..DataSheet
ADD OwnerSplitState nvarchar(255);

UPDATE Portfolio..DataSheet
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM Portfolio..DataSheet
WHERE OwnerSplitAddress is not null

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM Portfolio..DataSheet
GROUP BY SoldAsVacant;

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
	END
FROM Portfolio..DataSheet;

UPDATE Portfolio..DataSheet
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
						WHEN SoldAsVacant = 'N' THEN 'NO'
						ELSE SoldAsVacant
					END

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelId,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueId
					)Row_num
FROM Portfolio..DataSheet)

SELECT *
FROM RowNumCTE
WHERE Row_num >1


ALTER TABLE Portfolio..DataSheet
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate, LegalReference