USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[dscMaster]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dscMaster](
	[dscMasterId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[code] [varchar](10) NULL,
	[description] [varchar](200) NULL,
	[sCountry] [int] NULL,
	[rCountry] [int] NULL,
	[baseCurrency] [varchar](3) NULL,
	[tranType] [int] NULL,
	[isEnable] [char](1) NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK__dscMaste__33C0ED7C2E1CA799] PRIMARY KEY CLUSTERED 
(
	[dscMasterId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dscMaster] ADD  CONSTRAINT [MSrepl_tran_version_default_D99D62BF_9184_4A6B_B1DD_32C6750F01F3_1708793395]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
