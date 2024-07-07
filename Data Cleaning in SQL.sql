--Data Cleaning in SQL

Select *
From NashvilleHousing

--Standardize Date Format

Select SaleDate
From NashvilleHousing

Select SaleDate, CONVERT(Date,SaleDate)
From NashvilleHousing


UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)



--Populate Property Address Data
Select *
From NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

--Populate Property Address Data... ( there are some
--Null address, we are going to do Self join 
--so we can populate addresses for NUll addresses)

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL
(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
On a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
On a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--Breaking out Address into Individual columns (Address, City, State)

Select PropertyAddress
From NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
From NashvilleHousing

--To find out the position of the comma 

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address,
CHARINDEX(',', PropertyAddress)
From NashvilleHousing

--Now we know the position of the comma lets remove it now 

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
From NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From NashvilleHousing


--Lets add extra columns for Address and City
--with the help of Alter table & Update

--Lets split the Address into two indivdual columns by SubString, Alter and Update 
--Set and CharIndex formula

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 )

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From NashvilleHousing


--Lets Now split the OwnerAddress into three individual columns as Address, City and State 
--through ParseName

Select OwnerAddress
From NashvilleHousing

Select
PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1)
From NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1)


Select *
From NashvilleHousing

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct (SoldAsVacant)
From NashvilleHousing

Select Distinct (SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

--In order to change Y & N to YES & NO we will use Case Statement
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



--Remove Duplicates

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
Order by ParcelID


-- Lets use CTE now
WITH RowNumCTE as (
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
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

--To remove duplicate values we will use DELETE instead of SELECT in the above query
-- after we did delete then we will again apply SELECT * to see the change

--DELETE UNUSED COLUMNS

Select *
From NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate