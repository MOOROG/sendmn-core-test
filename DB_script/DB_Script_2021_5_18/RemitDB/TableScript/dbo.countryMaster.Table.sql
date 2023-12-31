USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[countryMaster]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[countryMaster](
	[countryId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[countryCode] [char](2) NULL,
	[isoAlpha3] [char](3) NULL,
	[iocOlympic] [char](3) NULL,
	[isoNumeric] [varchar](5) NULL,
	[countryName] [varchar](150) NOT NULL,
	[isOperativeCountry] [char](1) NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[approvedBy] [varchar](150) NULL,
	[operationType] [varchar](2) NULL,
	[fatfRating] [varchar](20) NULL,
	[timeZoneId] [int] NULL,
	[agentOperationControlType] [varchar](5) NULL,
	[defaultRoutingAgent] [int] NULL,
	[countryMobCode] [varchar](10) NULL,
	[countryMobLength] [int] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[allowOnlineCustomer] [varchar](2) NULL,
 CONSTRAINT [PK_countryMaster] PRIMARY KEY CLUSTERED 
(
	[countryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[countryMaster] ADD  CONSTRAINT [MSrepl_tran_version_default_17ED789D_407A_4138_8EED_7AE0BA0C2252_1614837015]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
