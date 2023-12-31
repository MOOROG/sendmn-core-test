USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[countryWiseExchangeRateHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[countryWiseExchangeRateHistory](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[countryWiseExchangeRateId] [int] NULL,
	[baseCurrency] [int] NULL,
	[countryId] [int] NULL,
	[purchaseRate] [float] NULL,
	[margin] [float] NULL,
	[isDeleted] [char](1) NULL,
	[modType] [varchar](10) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[countryWiseExchangeRateHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_CE5F1DCD_37F5_4EC4_B31F_13A37F93F0BA_745769714]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
