
CREATE TABLE remitTranCashLimitHold
(
	rowId INT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,tranId BIGINT NOT NULL
	,approvedRemarks VARCHAR(150) NOT NULL
	,approvedBy VARCHAR(80) NOT NULL
	,approvedDate DATETIME NOT NULL
	,reason VARCHAR(500) NOT NULL
);


