USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[dcPayMasterHub]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dcPayMasterHub](
	[dcPayMasterHubId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
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
 CONSTRAINT [PK__dcPayMas__138187DE1D87E3CB] PRIMARY KEY CLUSTERED 
(
	[dcPayMasterHubId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dcPayMasterHub] ADD  CONSTRAINT [MSrepl_tran_version_default_5865BB67_ED89_4962_AFDB_90A85E33D294_1017314934]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
