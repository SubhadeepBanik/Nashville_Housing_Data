--Practice SQL Quearys


create database practice;

--import data from provided excel file (Right click on practice database go to Task/Import data)

use practice;

select * from nashville;

--# (1) Change Date type

--(1.1) View

select saledate from nashville;

--(1.2) Update

alter table nashville alter column saledate date;


--# (2) Fill blank Property address where Parcel id same but Property address null filter by Unique ID


--(2.1) View

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from nashville as a
join nashville as b
on a.parcelid = b.parcelid
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

--(2.2) Update

update a
set a.PropertyAddress = b.PropertyAddress
from nashville as a
join nashville as b
on a.parcelid = b.parcelid
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;


--# (3) Extract from address

--extract code from address

--(3.1) View

select substring(propertyaddress,1,CHARINDEX(',',propertyaddress)-1) as address,
right (PropertyAddress,LEN(propertyaddress)-CHARINDEX(',',propertyaddress)-1) as city
from nashville;


--(3.2) Update

alter table nashville
add city varchar(255);

update nashville
set city = right (PropertyAddress,LEN(propertyaddress)-CHARINDEX(',',propertyaddress)-1);


alter table nashville
add address varchar(255);

update nashville
set address = substring(propertyaddress,1,CHARINDEX(',',propertyaddress)-1);

Alter table nashville
drop column propertyaddress;

--# (4) Owner address Converting using parse name

select PARSENAME(REPLACE(owneraddress,',','.'),3),
PARSENAME(REPLACE(owneraddress,',','.'),2),
PARSENAME(REPLACE(owneraddress,',','.'),1)
from nashville;

select owneraddress
from nashville;

alter table nashville add Owneraddress_street varchar (50);

update nashville
set Owneraddress_street = PARSENAME(REPLACE(owneraddress,',','.'),3);

alter table nashville add Owneraddress_city varchar (50);

update nashville
set Owneraddress_city = PARSENAME(REPLACE(owneraddress,',','.'),2);

alter table nashville add Owneraddress_state varchar (50);

update nashville
set Owneraddress_state = PARSENAME(REPLACE(owneraddress,',','.'),1);

alter table nashville drop column owneraddress;

--# (5) Make Soldasvacant as boolean like ('Y','N')

select soldasvacant,count(soldasvacant)
from nashville
group by soldasvacant;

select soldasvacant,
Case when soldasvacant = 'Yes' THEN 'Y'
     when soldasvacant = 'No' THEN 'N'
	 Else soldasvacant
	 END
FROM nashville;

update nashville
set soldasvacant = Case when soldasvacant = 'Yes' THEN 'Y'
     when soldasvacant = 'No' THEN 'N'
	 Else soldasvacant
	 END

begin tran
update nashville
set Owneraddress_city = LTRIM(Owneraddress_city);

update nashville
set Owneraddress_city = RTRIM(Owneraddress_city);


update nashville
set Owneraddress_street = LTRIM(Owneraddress_street);

update nashville
set Owneraddress_street = RTRIM(Owneraddress_street);

update nashville
set Owneraddress_state = LTRIM(Owneraddress_state);

update nashville
set Owneraddress_state = RTRIM(Owneraddress_state);

commit

select * from nashville;

--# (6) Fill the null Owneraddress_street,Owneraddress_city with address and city

select address,Owneraddress_street,city,Owneraddress_city,Owneraddress_state
	 from nashville
	 where Owneraddress_street is null and Owneraddress_city is null;

begin tran

update nashville
set Owneraddress_street = address
where Owneraddress_street is null;

update nashville
set Owneraddress_city = city
where Owneraddress_city is null;

update nashville
set Owneraddress_state = 'TN'
where Owneraddress_state is null;

alter table nashville add state varchar(2);

update nashville
set state = Owneraddress_state;

commit

--# (7) Deleting duplicate record

WITH RowNumCTE as (
select *,
ROW_NUMBER () OVER (
PARTITION BY ParcelID,
			 address,
			 saledate,
			 legalreference
			 ORDER BY 
			 uniqueid) as row_num
FROM nashville
)
SELECT *
from RowNumCTE
where row_num > 1;