USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[receiverInformation]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[receiverInformation](
	[receiverId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[customerId] [bigint] NOT NULL,
	[membershipId] [varchar](50) NULL,
	[firstName] [varchar](100) NULL,
	[middleName] [varchar](100) NULL,
	[lastName1] [varchar](100) NULL,
	[lastName2] [varchar](100) NULL,
	[country] [varchar](200) NULL,
	[address] [nvarchar](500) NULL,
	[state] [varchar](200) NULL,
	[zipCode] [varchar](50) NULL,
	[city] [varchar](100) NULL,
	[email] [varchar](150) NULL,
	[homePhone] [varchar](100) NULL,
	[workPhone] [varchar](100) NULL,
	[mobile] [varchar](100) NULL,
	[relationship] [varchar](60) NULL,
	[district] [varchar](100) NULL,
	[purposeOfRemit] [varchar](100) NULL,
	[receiverType] [int] NULL,
	[idType] [int] NULL,
	[idNumber] [nvarchar](50) NULL,
	[placeOfIssue] [varchar](80) NULL,
	[paymentMode] [int] NULL,
	[bankLocation] [varchar](100) NULL,
	[payOutPartner] [int] NULL,
	[bankName] [varchar](150) NULL,
	[receiverAccountNo] [varchar](40) NULL,
	[remarks] [nvarchar](800) NULL,
	[createdBy] [varchar](40) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](40) NULL,
	[modifiedDate] [datetime] NULL,
	[otherRelationDesc] [varchar](60) NULL,
	[tempRId] [bigint] NULL,
	[NativeCountry] [int] NULL,
	[DeletedBy] [varchar](30) NULL,
	[DeletedDate] [datetime] NULL,
	[IsDeleted] [varchar](1) NULL,
	[approvedBy] [varchar](50) NULL,
	[approveddate] [datetime] NULL,
	[OLD_CUSTOMERID] [bigint] NULL,
	[bankBranchName] [varchar](150) NULL,
	[FULLNAME] [varchar](100) NULL,
	[agentId] [bigint] NULL,
	[isActive] [bit] NULL,
	[bank] [int] NULL,
	[branch] [int] NULL,
	[localFirstName] [nvarchar](100) NULL,
	[localMiddleName] [nvarchar](100) NULL,
	[localLastName1] [nvarchar](100) NULL,
	[localLastName2] [nvarchar](100) NULL,
 CONSTRAINT [pk_idx_receiverInformation_receiverId] PRIMARY KEY CLUSTERED 
(
	[receiverId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
