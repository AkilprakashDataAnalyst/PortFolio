SELECT *
FROM Portfolio..DataSheet

--Standardize the  date format

ALTER TABLE Portfolio..sheet
ADD SaleDateConverted date;

UPDATE Portfolio..sheet
SET SaleDateConverted = CAST(SaleDate as DATE);

SELECT SaleDateConverted, CAST(SaleDate as Date) as ConvertedDate
FROM Portfolio..Sheet;

--Address update

Select a.ParcelId, a.PropertyAddress, b.ParcelId, b.PropertyAddress
FROM Portfolio..sheet a
JOIN Portfolio..sheet b
ON a.ParcelId = b.ParcelId
AND a.UniqueId <> b.UniqueId
Where a.PropertyAddress is null;

UPDATE a
SET PropertyAddress = IsNull(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..Sheet a
JOIN Portfolio..Sheet b
ON a.parcelId = b.parcelId
AND a.uniqueId <> b.uniqueId

--SEPERATE the ADDRESS
 
SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as City
--CHARINDEX(',', PropertyAddress)
From Portfolio..sheet;

ALTER TABLE Portfolio..sheet
ADD PropertySplitAddress varchar(255);

UPDATE Portfolio..sheet
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE Portfolio..sheet
ADD PropertySplitCity nvarchar(255);

UPDATE Portfolio..sheet
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

SELECT PropertyAddress, OwnerAddress
FROM Portfolio..Sheet
Where OwnerAddress is null;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
FROM Portfolio..Sheet
WHERE OwnerAddress is not null;

ALTER TABLE Portfolio..Sheet
ADD OwnerSplitAddress nvarchar(255);

UPDATE Portfolio..Sheet
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE Portfolio..Sheet
ADD OwnerSplitCity nvarchar(255);

UPDATE Portfolio..Sheet
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE Portfolio..Sheet
ADD OwnerSplitState nvarchar(255);

UPDATE Portfolio..Sheet
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM Portfolio..Sheet
WHERE OwnerSplitAddress is not null

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM Portfolio..Sheet
GROUP BY SoldAsVacant;

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
	END
FROM Portfolio..Sheet;

UPDATE Portfolio..Sheet
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
FROM Portfolio..Sheet)

DELETE
FROM RowNumCTE
WHERE Row_num >1

ALTER TABLE Portfolio..Sheet
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate, LegalReference

