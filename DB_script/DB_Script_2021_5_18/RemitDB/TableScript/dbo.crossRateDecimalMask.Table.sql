USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[crossRateDecimalMask]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[crossRateDecimalMask](
	[crdmId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[cCurrency] [varchar](3) NULL,
	[pCurrency] [varchar](3) NULL,
	[rateMaskAd] [int] NULL,
	[displayUnit] [int] NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_crossRateDecimalMask_crdmId] PRIMARY KEY CLUSTERED 
(
	[crdmId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[crossRateDecimalMask] ADD  CONSTRAINT [MSrepl_tran_version_default_371F3E72_1305_4CF8_8A60_ADF2FB3E5918_849086461]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
