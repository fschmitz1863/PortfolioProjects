/*

CLEANING DATA

*/

SELECT *
FROM PortfolioProject..NashvilleHousing


-----------------------------------------------------------------------------------------------------------------
-- Standardise Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing

--ALTER TABLE PortfolioProject..NashvilleHousing
--ADD SaleDateConverted Date;

UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject..NashvilleHousing


-----------------------------------------------------------------------------------------------------------------
-- Populate Property Address Data

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS a
JOIN PortfolioProject..NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS a
JOIN PortfolioProject..NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-----------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Columns (Address, City, State)

/* PropertyAddress */

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing

--ALTER TABLE PortfolioProject..NashvilleHousing
--ADD PropertySplitAddress nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

--ALTER TABLE PortfolioProject..NashvilleHousing
--ADD PropertySplitCity nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT *
FROM PortfolioProject..NashvilleHousing


/* OwnerAddress */

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT
--OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD	OwnerSplitAddress nvarchar(255)
	,OwnerSplitCity nvarchar(255)
	,OwnerSplitState nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET	OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
	,OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
	,OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT *
FROM PortfolioProject..NashvilleHousing


-----------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" Column

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
END
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END


-----------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

SELECT *
FROM PortfolioProject..NashvilleHousing

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY	ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY
							UniqueID
							) row_num

FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
SELECT * -- Change to DELETE to remove duplicates
FROM RowNumCTE
WHERE row_num > 1


-----------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

SELECT *
FROM PortfolioProject..NashvilleHousing

--ALTER TABLE PortfolioProject..NashvilleHousing
--DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


