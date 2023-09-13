USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[dcSendMasterSAHistory]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dcSendMasterSAHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[dcSendMasterSAId] [int] NULL,
	[code] [varchar](100) NULL,
	[description] [varchar](200) NULL,
	[sCountry] [int] NULL,
	[rCountry] [int] NULL,
	[baseCurrency] [varchar](3) NULL,
	[tranType] [int] NULL,
	[commissionBase] [int] NULL,
	[isEnable] [char](1) NULL,
	[modType] [varchar](6) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_dcSendMasterSAHistory_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dcSendMasterSAHistory] ADD  CONSTRAINT [MSrepl_tran_version_default_7D7E017D_ACE8_4723_A065_F847B4691CE7_105311685]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
