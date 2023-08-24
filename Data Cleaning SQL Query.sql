-- Creating table 
Drop Table if exists nashvillehousing; 
CREATE TABLE nashvillehousing(UniqueID VARCHAR(250) DEFAULT NUll ,ParcelID VARCHAR(250) DEFAULT NUll,LandUse VARCHAR(250) DEFAULT NUll,	
PropertyAddress Varchar(250) DEFAULT NUll,SaleDate VARCHAR(250) DEFAULT NUll,SalePrice VARCHAR(250) DEFAULT NUll,LegalReference VARCHAR(250) DEFAULT NUll,	
SoldAsVacant VARCHAR(250) DEFAULT NUll,OwnerName Varchar(250) DEFAULT NUll,OwnerAddress VARCHAR(250) DEFAULT NUll,	
Acreage VARCHAR(250) DEFAULT NUll,TaxDistrict VARCHAR(250) DEFAULT NUll,LandValue BIGINT DEFAULT NUll,BuildingValue VARCHAR(250) DEFAULT NUll,TotalValue BIGINT DEFAULT NUll,
YearBuilt VARCHAR(250) DEFAULT NUll,Bedrooms INT DEFAULT NUll,FullBath INT DEFAULT NUll,HalfBath INT DEFAULT NUll
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\nashvillehousing.csv'
INTO TABLE nashvillehousing
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


/*

Cleaning Data in SQL Queries

*/


Select * From NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

UPDATE NashvilleHousing SET Saledate = STR_TO_DATE(Saledate, '%M-%d-%Y');

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select * From NashvilleHousing
Where PropertyAddress is null
order by ParcelID;

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address,City)

Select PropertyAddress
From NashvilleHousing
order by ParcelID;
-- Spliting Address column
SELECT
SUBSTRING(PropertyAddress, 1, instr(PropertyAddress,'_') -1 ) as Address
, SUBSTRING(PropertyAddress, instr(PropertyAddress,'_') + 1 , length(PropertyAddress)) as Address
From NashvilleHousing;

-- Adding column Address1

ALTER TABLE NashvilleHousing
Add Address1 varchar(255);

-- Updating column with split address

Update NashvilleHousing
SET Address1 = SUBSTRING(PropertyAddress, 1, instr(',', PropertyAddress) -1 );

-- Adding column Address2
ALTER TABLE NashvilleHousing
Add Address2 Nvarchar(255);

-- Updating column with split address

Update NashvilleHousing
SET Address2 = SUBSTRING(PropertyAddress,instr(PropertyAddress,",") + 1 , LEN(PropertyAddress));


Select * From NashvilleHousing;

Select OwnerAddress From NashvilleHousing;

SELECT
	SUBSTRING_INDEX(OwnerAddress, '_', 1) as Locality,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, '_', 2), '_', -1)as City,
    SUBSTRING_INDEX(OwnerAddress, '_', -1) as Country
    FROM NashvilleHousing;
    SELECT
    SUBSTRING_INDEX("1808 FOX CHASE DR_ GOODLETTSVILLE_ TN", '_', 1) as Locality,
    SUBSTRING_INDEX(SUBSTRING_INDEX("1808 FOX CHASE DR_ GOODLETTSVILLE_ TN", '_', 2), '_', -1) as City,
    SUBSTRING_INDEX("1808 FOX CHASE DR_ GOODLETTSVILLE_ TN", '_', -1) as state;


ALTER TABLE NashvilleHousing
Add Owner_state varchar(255);

UPDATE NashvilleHousing
SET Owner_state = SUBSTRING_INDEX(OwnerAddress, '_', -1);


ALTER TABLE NashvilleHousing
Add Owner_City varchar(255);

Update NashvilleHousing
SET Owner_City = SUBSTRING_INDEX(SUBSTRING_INDEX("1808 FOX CHASE DR_ GOODLETTSVILLE_ TN", '_', 2), '_', -1);

ALTER TABLE NashvilleHousing
Add OwnerSplitState varchar(255);

Update NashvilleHousing
SET Owner_locality = SUBSTRING_INDEX("1808 FOX CHASE DR_ GOODLETTSVILLE_ TN", '_', 1);

Select * From NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2;

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END SoldAsVacant
From NashvilleHousing;


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;

Select * From NashvilleHousing;
