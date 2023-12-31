USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[CurrencyRule]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CurrencyRule](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ruleId] [varchar](20) NULL,
	[ruleName] [varchar](30) NULL,
	[currCode] [varchar](30) NULL,
	[countryId] [int] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](100) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](100) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_CurrencyRule_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CurrencyRule] ADD  CONSTRAINT [MSrepl_tran_version_default_5C5240C5_18E9_4B25_BA2A_3A0DD78F7BBB_343672272]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
