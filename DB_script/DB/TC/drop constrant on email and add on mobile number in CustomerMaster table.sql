
--create unique index on mobile number in customerMaster
ALTER TABLE customerMaster
ADD CONSTRAINT UQ__customerMaster__mobileNumber_constraint
UNIQUE (mobile)


--Drop unique index in exisiting email field in customerMaster
ALTER TABLE customerMaster DROP CONSTRAINT UQ__customer__AB6E6164671DCF9A

