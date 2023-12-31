USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[countryBanks]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[countryBanks](
	[countryBankId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[countryId] [int] NULL,
	[bankName] [varchar](100) NULL,
	[accountNumber] [varchar](50) NULL,
	[remarks] [varchar](150) NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[countryBankId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[countryBanks] ADD  CONSTRAINT [MSrepl_tran_version_default_C678EC94_CC84_4EDC_AE31_87C758A4CE95_1965614441]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
