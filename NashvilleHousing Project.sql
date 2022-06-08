--Cleaning Data SQL Queries

Select *
From PortafolioProject.dbo.NashvilleHousing

-- Standardize Date Format

Select SaleDate, Convert(date,Saledate)
From PortafolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Alter Column SaleDate Date;

--Populate Property Address Data

Select *
From PortafolioProject.dbo.NashvilleHousing
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortafolioProject.dbo.NashvilleHousing a
Join PortafolioProject.dbo.NashvilleHousing b
	on a.ParcelID= b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
Where b.PropertyAddress is null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortafolioProject.dbo.NashvilleHousing a
JOIN PortafolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null


--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortafolioProject.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress)) as City
From PortafolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress))


Select PropertysplitAddress, PropertySplitCity
From PortafolioProject..NashvilleHousing


--Breaking out Owner Address into Individual Columns (Address, City, State)

Select OwnerAddress
From PortafolioProject..NashvilleHousing


Select 
Parsename(Replace(OwnerAddress,',','.'),3),
Parsename(Replace(OwnerAddress,',','.'),2),
Parsename(Replace(OwnerAddress,',','.'),1)
from PortafolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = Parsename(Replace(OwnerAddress,',','.'),1)


--Change Y and N to Yes and No in "Sold as Vacant" field

Select SoldAsVacant, count(SoldAsVacant)
From PortafolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END
From PortafolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant=
Case When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END


--Remove Duplicates (considering we don't have a uniqueID) 

With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 ParcelID)row_num
From PortafolioProject.dbo.NashvilleHousing
)
Delete
From RowNumCTE
Where row_num>1



--Delete Unsued Columns

Select *
From PortafolioProject..NashvilleHousing

ALTER TABLE PortafolioProject..Nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress