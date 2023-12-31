USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[currencyPayoutRound]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[currencyPayoutRound](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[currency] [varchar](3) NULL,
	[tranType] [int] NULL,
	[place] [int] NULL,
	[currDecimal] [int] NULL,
	[isDeleted] [char](1) NULL,
	[isActive] [char](1) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_currencyPayoutRound_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[currencyPayoutRound] ADD  CONSTRAINT [MSrepl_tran_version_default_EDDC4362_AAEC_403A_BFDF_058F9610005C_1323412034]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
