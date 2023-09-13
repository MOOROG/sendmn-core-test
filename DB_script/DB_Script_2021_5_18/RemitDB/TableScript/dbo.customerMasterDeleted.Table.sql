USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[customerMasterDeleted]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[customerMasterDeleted](
	[customerId] [bigint] IDENTITY(1,1) NOT NULL,
	[membershipId] [varchar](50) NULL,
	[firstName] [varchar](100) NULL,
	[middleName] [varchar](100) NULL,
	[lastName1] [varchar](100) NULL,
	[lastName2] [varchar](100) NULL,
	[country] [int] NULL,
	[address] [varchar](500) NULL,
	[state] [int] NULL,
	[zipCode] [varchar](50) NULL,
	[district] [int] NULL,
	[city] [varchar](100) NULL,
	[email] [varchar](150) NULL,
	[homePhone] [varchar](100) NULL,
	[workPhone] [varchar](100) NULL,
	[mobile] [varchar](100) NULL,
	[nativeCountry] [int] NULL,
	[dob] [datetime] NULL,
	[placeOfIssue] [varchar](100) NULL,
	[customerType] [int] NULL,
	[occupation] [int] NULL,
	[isBlackListed] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[isDeleted] [char](1) NULL,
	[lastTranId] [bigint] NULL,
	[relationId] [int] NULL,
	[relativeName] [varchar](500) NULL,
	[address2] [varchar](200) NULL,
	[fullName] [varchar](200) NULL,
	[postalCode] [varchar](500) NULL,
	[idExpiryDate] [datetime] NULL,
	[idType] [varchar](100) NULL,
	[idNumber] [varchar](50) NULL,
	[telNo] [varchar](20) NULL,
	[companyName] [varchar](100) NULL,
	[gender] [varchar](10) NULL,
	[salaryRange] [varchar](150) NULL,
	[bonusPointPending] [money] NULL,
	[Redeemed] [money] NULL,
	[bonusPoint] [money] NULL,
	[todaysSent] [money] NULL,
	[todaysNoOfTxn] [int] NULL,
	[agentId] [int] NULL,
	[branchId] [int] NULL,
	[memberIDissuedDate] [datetime] NULL,
	[memberIDissuedByUser] [varchar](50) NULL,
	[memberIDissuedAgentId] [varchar](50) NULL,
	[memberIDissuedBranchId] [varchar](50) NULL,
	[totalSent] [money] NULL,
	[idIssueDate] [datetime] NULL,
	[onlineUser] [char](1) NULL,
	[customerPassword] [varchar](100) NULL,
	[customerStatus] [char](1) NULL,
	[isActive] [char](1) NULL,
	[islocked] [varchar](1) NULL,
	[sessionId] [varchar](60) NULL,
	[lastLoginTs] [datetime] NULL,
	[howDidYouHear] [varchar](200) NULL,
	[ansText] [varchar](200) NULL,
	[ansEmail] [varchar](200) NULL,
	[state2] [varchar](500) NULL,
	[ipAddress] [varchar](30) NULL,
	[marketingSubscription] [char](1) NULL,
	[paidTxn] [bigint] NULL,
	[firstTxnDate] [datetime] NULL,
	[verifyDoc1] [varchar](150) NULL,
	[verifyDoc2] [varchar](150) NULL,
	[verifiedBy] [varchar](100) NULL,
	[verifiedDate] [datetime] NULL,
	[verifyDoc3] [varchar](255) NULL,
	[isForcedPwdChange] [bit] NULL,
	[bankName] [varchar](100) NULL,
	[bankAccountNo] [varchar](20) NULL,
	[walletAccountNo] [varchar](100) NULL,
	[availableBalance] [money] NULL,
	[obpId] [varchar](50) NULL,
	[CustomerBankName] [nvarchar](100) NULL,
	[referelCode] [varchar](30) NULL,
	[isEmailVerified] [bit] NULL,
	[verificationCode] [varchar](40) NULL,
	[SelfieDoc] [varchar](200) NULL,
	[HasDeclare] [bit] NULL,
	[AuditDate] [datetime] NULL,
	[AuditBy] [varchar](50) NULL,
	[SchemeStartDate] [date] NULL,
	[invalidAttemptCount] [int] NULL,
	[sourceOfFund] [varchar](100) NULL,
	[street] [varchar](80) NULL,
	[streetUnicode] [nvarchar](100) NULL,
	[cityUnicode] [nvarchar](100) NULL,
	[visaStatus] [int] NULL,
	[employeeBusinessType] [int] NULL,
	[nameOfEmployeer] [varchar](80) NULL,
	[SSNNO] [varchar](20) NULL,
	[remittanceAllowed] [bit] NULL,
	[remarks] [varchar](800) NULL,
	[registerationNo] [varchar](30) NULL,
	[organizationType] [int] NULL,
	[dateofIncorporation] [datetime] NULL,
	[natureOfCompany] [int] NULL,
	[position] [int] NULL,
	[nameOfAuthorizedPerson] [varchar](80) NULL,
	[monthlyIncome] [varchar](50) NULL,
	[ADDITIONALADDRESS] [nvarchar](250) NULL,
	[deletedBy] [varchar](20) NULL,
	[deletedDate] [datetime] NULL,
	[customerIdDeleted] [bigint] NULL
) ON [PRIMARY]
GO
