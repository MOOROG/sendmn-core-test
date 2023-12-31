USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentOwnershipInf]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentOwnershipInf](
	[aoiId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[ownerName] [varchar](50) NULL,
	[ssn] [varchar](20) NULL,
	[idType] [int] NULL,
	[idNumber] [varchar](50) NULL,
	[issuingCountry] [int] NULL,
	[expiryDate] [datetime] NULL,
	[permanentAddress] [varchar](100) NULL,
	[country] [int] NULL,
	[city] [varchar](50) NULL,
	[state] [int] NULL,
	[zip] [varchar](20) NULL,
	[phone] [varchar](20) NULL,
	[fax] [varchar](20) NULL,
	[mobile1] [varchar](20) NULL,
	[mobile2] [varchar](20) NULL,
	[email] [varchar](50) NULL,
	[position] [varchar](50) NULL,
	[shareHolding] [int] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK__agentOwn__E9C6F14B6ECC298B] PRIMARY KEY CLUSTERED 
(
	[aoiId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[agentOwnershipInf] ADD  CONSTRAINT [MSrepl_tran_version_default_490714D2_C676_41F1_8500_CF5C8D62AA65_15391174]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
