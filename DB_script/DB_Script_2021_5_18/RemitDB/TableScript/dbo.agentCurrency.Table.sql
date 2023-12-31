USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[agentCurrency]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[agentCurrency](
	[agentCurrencyId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[currencyId] [int] NULL,
	[spFlag] [char](1) NULL,
	[isDefault] [char](1) NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_agentCurrency_agentCurrencyId] PRIMARY KEY CLUSTERED 
(
	[agentCurrencyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[agentCurrency] ADD  CONSTRAINT [MSrepl_tran_version_default_55DF5106_4F98_4E84_8DD3_0E3EA09340C2_1846557912]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
