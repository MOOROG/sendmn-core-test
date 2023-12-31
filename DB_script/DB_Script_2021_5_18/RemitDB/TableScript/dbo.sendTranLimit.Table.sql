USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[sendTranLimit]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sendTranLimit](
	[stlId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[countryId] [varchar](100) NULL,
	[userId] [int] NULL,
	[receivingCountry] [varchar](100) NULL,
	[minLimitAmt] [money] NULL,
	[maxLimitAmt] [money] NULL,
	[currency] [varchar](3) NULL,
	[tranType] [varchar](50) NULL,
	[paymentType] [varchar](50) NULL,
	[customerType] [int] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[collMode] [int] NULL,
	[receivingAgent] [int] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_sendTranLimit_stlId] PRIMARY KEY CLUSTERED 
(
	[stlId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[sendTranLimit] ADD  CONSTRAINT [MSrepl_tran_version_default_4CC09F90_A4ED_4911_9E1B_4C633503967F_1895938076]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
