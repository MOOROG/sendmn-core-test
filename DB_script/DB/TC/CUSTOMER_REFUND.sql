

CREATE TABLE CUSTOMER_REFUND
(
	rowId INT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,customerId BIGINT NOT NULL
	,refundAmount MONEY NOT NULL
	,refundCharge MONEY DEFAULT(0) NOT NULL
	,refundRemarks VARCHAR(200) NULL
	,refundChargeRemarks VARCHAR(200) NULL
	,createdBy VARCHAR(40) NOT NULL
	,createdDate DATETIME NOT NULL
	,approvedBy VARCHAR(40) NULL
	,approvedDate DATETIME NULL
	,isDeleted BIT DEFAULT(0) NOT NULL
	,deletedBy VARCHAR(40) NULL
	,deletedDate DATETIME
	,collMode VARCHAR(15)
	,bankId VARCHAR(20)
);



