USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[countryWiseExchangeRate]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[countryWiseExchangeRate](
	[countryWiseExchangeRateId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[baseCurrency] [int] NULL,
	[countryId] [int] NULL,
	[purchaseRate] [float] NULL,
	[margin] [float] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[updateCount] [int] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[countryWiseExchangeRateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[countryWiseExchangeRate] ADD  CONSTRAINT [MSrepl_tran_version_default_495B8C13_B89E_455D_9AAF_1DCFB4130C82_617769258]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
