--Cleaning Data-- 

--1st Cleaning Operation : Standardising Date Time -- 
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)

Select SaleDateConverted, CONVERT(Date, SaleDate)
From [Portfolio Project ]..NashvilleHousing

-- 2st Cleaning Operation : Populate Property Address Data i.e filling NULL values in Property Address Column-- 
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISnull(a.PropertyAddress, b.PropertyAddress)
from [Portfolio Project ].dbo.NashvilleHousing  a 
JOIN [Portfolio Project ].dbo.NashvilleHousing  b 
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

Update a 
SET PropertyAddress = ISnull(a.PropertyAddress, b.PropertyAddress) 
from [Portfolio Project ].dbo.NashvilleHousing  a 
JOIN [Portfolio Project ].dbo.NashvilleHousing  b 
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]

	-- 3rd Cleaning Operation : Breaking the property address into individual columns By use of substring -- 

SELECT
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From [Portfolio Project ]..NashvilleHousing

Alter table[Portfolio Project ]..NashvilleHousing
Add PropertyAddressSplit Nvarchar(225);

UPDATE[Portfolio Project ]..NashvilleHousing
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress)-1)

Alter table[Portfolio Project ]..NashvilleHousing
Add PropertyCitySplit Nvarchar(225);

UPDATE[Portfolio Project ]..NashvilleHousing
SET PropertyCitySplit =SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


-- 4th Cleaning Operation : Breaking the Owner Address into individual columns by use of Parsename--\

Select OwnerAddress
from [Portfolio Project ]..NashvilleHousing

Select 
PARSENAME(Replace(OwnerAddress, ',','.'), 3) as OwnerAddSpilt
, PARSENAME(Replace(OwnerAddress, ',','.'), 2) as OwnerCitySpilt
, PARSENAME(Replace(OwnerAddress, ',','.'), 1) as OwnerStateSpilt
FROM [Portfolio Project ]..NashvilleHousing

Alter table[Portfolio Project ]..NashvilleHousing
Add OwnerAddSpilt Nvarchar(225);

UPDATE[Portfolio Project ]..NashvilleHousing
SET OwnerAddSpilt = PARSENAME(Replace(OwnerAddress, ',','.'), 3)

Alter table[Portfolio Project ]..NashvilleHousing
Add OwnerCitySpilt Nvarchar(225);

UPDATE[Portfolio Project ]..NashvilleHousing
SET OwnerCitySpilt = PARSENAME(Replace(OwnerAddress, ',','.'), 2)

Alter table[Portfolio Project ]..NashvilleHousing
Add OwnerStateSpilt Nvarchar(225);

UPDATE[Portfolio Project ]..NashvilleHousing
SET OwnerStateSpilt = PARSENAME(Replace(OwnerAddress, ',','.'), 1)

-- 5th Cleaning Operation : Changing Y & N ---> YES and NO in 'Sold And Vacant Field'

UPDATE[Portfolio Project ]..NashvilleHousing
SET SoldAsVacant = 
Case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end

--Checking--
Select Distinct(SoldAsVacant),count(SoldAsVacant) as distinct_count
from [Portfolio Project ]..NashvilleHousing
Group by SoldAsVacant
Order by distinct_count desc

-- 6th Cleaning Operation : Removing Duplicates by using CTE -- 
WITH RowNumCTE as(
select *,
     ROW_NUMBER() Over(
	 Partition by ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY 
				  uniqueID
				  ) row_num
from [Portfolio Project ]..NashvilleHousing
--order by ParcelID
)
Select * 
from RowNumCTE
where row_num>1

-- 7th Cleaning Operation : Removing Unused Columns -- 
Select * 
from [Portfolio Project ]..NashvilleHousing

Alter table[Portfolio Project ]..NashvilleHousing
Drop Column OwnerAddress,TaxDistrict, PropertyAddress

Alter table[Portfolio Project ]..NashvilleHousing
Drop Column SaleDate 