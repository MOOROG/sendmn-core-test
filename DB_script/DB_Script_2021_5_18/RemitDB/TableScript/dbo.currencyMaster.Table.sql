USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[currencyMaster]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[currencyMaster](
	[currencyId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[currencyCode] [varchar](10) NULL,
	[isoNumeric] [varchar](5) NULL,
	[currencyName] [varchar](50) NULL,
	[currencyDesc] [varchar](50) NULL,
	[currencyDecimalName] [varchar](50) NULL,
	[countAfterDecimal] [int] NULL,
	[roundNoDecimal] [int] NULL,
	[factor] [char](1) NULL,
	[rateMin] [float] NULL,
	[rateMax] [float] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_currencyMaster_currencyId] PRIMARY KEY CLUSTERED 
(
	[currencyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[currencyMaster] ADD  CONSTRAINT [MSrepl_tran_version_default_C6232FE8_BD1C_4B09_AD71_8257D2A588E7_1606505002]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
