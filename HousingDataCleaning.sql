----------------------------------------------------------------------------------------------------------------
 /*

 Cleaning Data in SQL Queries

 */

 select *
 from Covid19Project.dbo.NashvilleHousing;



----------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

 select SaleDateConverted, CONVERT(Date, SaleDate)
 from Covid19Project.dbo.NashvilleHousing;

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


----------------------------------------------------------------------------------------------------------------
-- Populate Property Address data

 select *
 from Covid19Project.dbo.NashvilleHousing
 --where PropertyAddress is null;
 order by ParcelID

 -- We are going to populate the address if one ParcelID has the property address but other same parcelID address does not have the property address.
-- we are going to perform self join
select a.parcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Covid19Project.dbo.NashvilleHousing a
join Covid19Project.dbo.NashvilleHousing b
    ON a.ParcelID = b.parcelID 
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set propertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Covid19Project.dbo.NashvilleHousing a
join Covid19Project.dbo.NashvilleHousing b
    ON a.ParcelID = b.parcelID 
    and a.UniqueID <> b.UniqueID


----------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual columns (Address, City, State)
-- There are no other commas accept the Delimiter

select propertyAddress
from Covid19Project.dbo.NashvilleHousing
--where PropertyAddress is null;
-- order by ParcelID

-- -1 is used to not include ','
select 
substring(propertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
,substring(propertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
from Covid19Project.dbo.NashvilleHousing

-- We cant seperate one columns without putting them into two other columns
ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = substring(propertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = substring(propertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

select propertyAddress, PropertySplitAddress, PropertySplitCity
from Covid19Project.dbo.NashvilleHousing



select OwnerAddress
from Covid19Project.dbo.NashvilleHousing

-- Doing the same thing as above but using PARSENAME()
select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
from Covid19Project.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

select OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from Covid19Project.dbo.NashvilleHousing


----------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

select * 
from Covid19Project.dbo.NashvilleHousing

select distinct(SoldAsVacant), Count(SoldAsVacant)
from Covid19Project.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
from Covid19Project.dbo.NashvilleHousing


update NashvilleHousing
set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
from Covid19Project.dbo.NashvilleHousing



----------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
select *,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
                 PropertyAddress, 
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY   
                    UniqueID
                    ) row_number
from Covid19Project.dbo.NashvilleHousing
-- order by ParcelID
)
DELETE 
from RowNumCTE
where row_number > 1


WITH RowNumCTE AS(
select *,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
                 PropertyAddress, 
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY   
                    UniqueID
                    ) row_number
from Covid19Project.dbo.NashvilleHousing
-- order by ParcelID
)
Select *
from RowNumCTE
where row_number > 1


select *
from Covid19Project.dbo.NashvilleHousing


----------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

Select *
From Covid19Project..NashvilleHousing

Alter TABLE Covid19Project..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Alter TABLE Covid19Project..NashvilleHousing
DROP COLUMN SaleDate
