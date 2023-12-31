USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[dcPayMaster]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dcPayMaster](
	[dcPayMasterId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[code] [varchar](100) NULL,
	[description] [varchar](200) NULL,
	[sCountry] [int] NULL,
	[rCountry] [int] NULL,
	[baseCurrency] [varchar](3) NULL,
	[commissionCurrency] [varchar](3) NULL,
	[tranType] [int] NULL,
	[commissionBase] [int] NULL,
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
 CONSTRAINT [PK__dcPayMas__ED1B23B54AD8E1D8] PRIMARY KEY CLUSTERED 
(
	[dcPayMasterId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dcPayMaster] ADD  CONSTRAINT [MSrepl_tran_version_default_69B4C96A_C990_4D50_9714_063327155525_1065315105]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
