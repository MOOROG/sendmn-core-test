USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[SystemEmailSetup]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SystemEmailSetup](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[name] [varchar](500) NULL,
	[email] [varchar](max) NULL,
	[mobile] [varchar](200) NULL,
	[agent] [varchar](200) NULL,
	[isCancel] [char](3) NULL,
	[isTrouble] [char](3) NULL,
	[isAccount] [char](3) NULL,
	[isXRate] [char](3) NULL,
	[isSummary] [char](3) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[isDeleted] [varchar](1) NULL,
	[isBonus] [char](3) NULL,
	[isEodRpt] [varchar](10) NULL,
	[country] [varchar](200) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[isbankGuaranteeExpiry] [varchar](10) NULL,
	[onlineTxnAlerts] [varchar](20) NULL,
 CONSTRAINT [PK_SystemEmailSetup] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[SystemEmailSetup] ADD  CONSTRAINT [MSrepl_tran_version_default_9CE1E0FC_9E6A_4A44_8A76_472E9B782F2B_1351988193]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
