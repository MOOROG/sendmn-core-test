USE [FastMoneyPro_Remit]
GO

/****** Object:  Table [dbo].[customerMaster]    Script Date: 5/29/2019 9:24:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[customerMasterEditedDataMod](
	[RowId] [BIGINT] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[customerId] [BIGINT] NOT NULL,
	[membershipId] [VARCHAR](50) NULL,
	[firstName] [VARCHAR](100) NULL,
	[middleName] [VARCHAR](100) NULL,
	[lastName1] [VARCHAR](100) NULL,
	[lastName2] [VARCHAR](100) NULL,
	[country] [INT] NULL,
	[address] [VARCHAR](500) NULL,
	[state] [INT] NULL,
	[zipCode] [VARCHAR](50) NULL,
	[district] [INT] NULL,
	[city] [VARCHAR](100) NULL,
	[email] [VARCHAR](150) NULL,
	[homePhone] [VARCHAR](100) NULL,
	[workPhone] [VARCHAR](100) NULL,
	[mobile] [VARCHAR](100) NULL,
	[nativeCountry] [INT] NULL,
	[dob] [DATETIME] NULL,
	[placeOfIssue] [VARCHAR](100) NULL,
	[customerType] [INT] NULL,
	[occupation] [INT] NULL,
	[isBlackListed] [CHAR](1) NULL,
	[createdBy] [VARCHAR](30) NULL,
	[createdDate] [DATETIME] NULL,
	[modifiedBy] [VARCHAR](30) NULL,
	[modifiedDate] [DATETIME] NULL,
	[approvedBy] [VARCHAR](30) NULL,
	[approvedDate] [DATETIME] NULL,
	[isDeleted] [CHAR](1) NULL,
	[lastTranId] [BIGINT] NULL,
	[relationId] [INT] NULL,
	[relativeName] [VARCHAR](500) NULL,
	[address2] [VARCHAR](200) NULL,
	[fullName] [VARCHAR](200) NULL,
	[postalCode] [VARCHAR](500) NULL,
	[idExpiryDate] [DATETIME] NULL,
	[idType] [VARCHAR](100) NULL,
	[idNumber] [VARCHAR](50) NULL,
	[telNo] [VARCHAR](20) NULL,
	[companyName] [VARCHAR](100) NULL,
	[gender] [VARCHAR](10) NULL,
	[salaryRange] [VARCHAR](150) NULL,
	[bonusPointPending] [MONEY] NULL,
	[Redeemed] [MONEY] NULL,
	[bonusPoint] [MONEY] NULL,
	[todaysSent] [MONEY] NULL,
	[todaysNoOfTxn] [INT] NULL,
	[agentId] [INT] NULL,
	[branchId] [INT] NULL,
	[memberIDissuedDate] [DATETIME] NULL,
	[memberIDissuedByUser] [VARCHAR](50) NULL,
	[memberIDissuedAgentId] [VARCHAR](50) NULL,
	[memberIDissuedBranchId] [VARCHAR](50) NULL,
	[totalSent] [MONEY] NULL,
	[idIssueDate] [DATETIME] NULL,
	[onlineUser] [CHAR](1) NULL,
	[customerPassword] [VARCHAR](100) NULL,
	[customerStatus] [CHAR](1) NULL,
	[isActive] [CHAR](1) NULL,
	[islocked] [VARCHAR](1) NULL,
	[sessionId] [VARCHAR](60) NULL,
	[lastLoginTs] [DATETIME] NULL,
	[howDidYouHear] [VARCHAR](200) NULL,
	[ansText] [VARCHAR](200) NULL,
	[ansEmail] [VARCHAR](200) NULL,
	[state2] [VARCHAR](500) NULL,
	[ipAddress] [VARCHAR](30) NULL,
	[marketingSubscription] [CHAR](1) NULL,
	[paidTxn] [BIGINT] NULL,
	[firstTxnDate] [DATETIME] NULL,
	[verifyDoc1] [VARCHAR](150) NULL,
	[verifyDoc2] [VARCHAR](150) NULL,
	[verifiedBy] [VARCHAR](100) NULL,
	[verifiedDate] [DATETIME] NULL,
	[verifyDoc3] [VARCHAR](255) NULL,
	[isForcedPwdChange] [BIT] NULL,
	[bankName] [VARCHAR](100) NULL,
	[bankAccountNo] [VARCHAR](20) NULL,
	[walletAccountNo] [VARCHAR](100) NULL,
	[availableBalance] [MONEY] NULL,
	[obpId] [VARCHAR](50) NULL,
	[CustomerBankName] [NVARCHAR](100) NULL,
	[referelCode] [VARCHAR](30) NULL,
	[isEmailVerified] [BIT] NULL,
	[verificationCode] [VARCHAR](40) NULL,
	[SelfieDoc] [VARCHAR](200) NULL,
	[HasDeclare] [BIT] NULL,
	[AuditDate] [DATETIME] NULL,
	[AuditBy] [VARCHAR](50) NULL,
	[SchemeStartDate] [DATE] NULL,
	[invalidAttemptCount] [INT] NULL,
	[sourceOfFund] [VARCHAR](100) NULL,
	[street] [VARCHAR](80) NULL,
	[streetUnicode] [NVARCHAR](100) NULL,
	[cityUnicode] [NVARCHAR](100) NULL,
	[visaStatus] [INT] NULL,
	[employeeBusinessType] [INT] NULL,
	[nameOfEmployeer] [VARCHAR](80) NULL,
	[SSNNO] [VARCHAR](20) NULL,
	[remittanceAllowed] [BIT] NULL,
	[remarks] [VARCHAR](800) NULL,
	[registerationNo] [VARCHAR](30) NULL,
	[organizationType] [INT] NULL,
	[dateofIncorporation] [DATETIME] NULL,
	[natureOfCompany] [INT] NULL,
	[position] [INT] NULL,
	[nameOfAuthorizedPerson] [VARCHAR](80) NULL,
	[monthlyIncome] [VARCHAR](50) NULL,
	[modType ] CHAR(1) NULL
	)


