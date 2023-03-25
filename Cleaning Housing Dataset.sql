

USE [Project Portfolio];


-- DATA CLEANING PROJECT
SELECT * FROM NashHousing;

--------------------------------------------------------------------------------------------------------------------------

-- Change the date format from datetime to date only

ALTER TABLE NashHousing
ADD Converted_saledate DATE;

UPDATE NashHousing
SET Converted_saledate = CAST(SaleDate AS DATE) ;

SELECT Converted_saledate
FROM NashHousing;

--------------------------------------------------------------------------------------------------------------------------

-- Fill Property Address NULL values based on Parcel ID

SELECT *
FROM NashHousing
WHERE PropertyAddress is null


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashHousing a
JOIN NashHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Filling the null values with the Property Address that matches the Parcel ID
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashHousing a
JOIN NashHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null





--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Property Address and Owner Address into Individual Columns (Address, City, State)

-- Property Address
SELECT PropertyAddress
FROM NashHousing;



SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1),                  -- Address
       SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))  -- City
FROM NashHousing ;



-- Set the new columns
ALTER TABLE NashHousing
Add NewPropertyAddress Nvarchar(255);

Update NashHousing
SET NewPropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );


ALTER TABLE NashHousing
ADD NewPropertyCity NVARCHAR(255);

Update NashHousing
SET NewPropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));



-- Owner Address
SELECT OwnerAddress 
FROM NashHousing;



SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3), -- Address
       PARSENAME(REPLACE(OwnerAddress,',','.'),2), -- City
        PARSENAME(REPLACE(OwnerAddress,',','.'),1)  -- State
FROM NashHousing;


ALTER TABLE NashHousing
ADD NewOwnerAddress NVARCHAR(255);

Update NashHousing
SET NewOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);


ALTER TABLE NashHousing
ADD NewOwnerCity Nvarchar(255);

Update NashHousing
SET NewOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);


ALTER TABLE NashHousing
ADD NewOwnerState NVARCHAR(255);

Update NashHousing
SET NewOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" column

 Select Distinct(SoldAsVacant)
From NashHousing;



Select SoldAsVacant, 
CASE   When SoldAsVacant = 'Y' THEN 'Yes'
	    When SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM NashHousing


UPDATE NashHousing
SET SoldAsVacant = CASE 
                      When SoldAsVacant = 'Y' THEN 'Yes'
	                   When SoldAsVacant = 'N' THEN 'No'
	                ELSE SoldAsVacant
	                END



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Identify Duplicates


-- Identify
SELECT *
FROM   (
        SELECT a.*,
          Row_Number() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice,Converted_saledate, LegalReference
				          ORDER BY UniqueID ) AS Number
 FROM   NashHousing AS a
)       AS b
WHERE   Number > 1


---------------------------------------------------------------------------------------------------------

-- Delete Unwanted Columns



Select *
From NashHousing;


ALTER TABLE NashHousing
DROP COLUMN TaxDistrict, PropertyAddress;
