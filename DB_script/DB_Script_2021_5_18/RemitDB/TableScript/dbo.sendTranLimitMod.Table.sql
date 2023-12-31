USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[sendTranLimitMod]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sendTranLimitMod](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[stlId] [int] NULL,
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
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](100) NULL,
	[modType] [char](1) NOT NULL,
	[collMode] [int] NULL,
	[receivingAgent] [int] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_sendTranLimitMod_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[sendTranLimitMod] ADD  CONSTRAINT [MSrepl_tran_version_default_165CD29D_FD58_4430_9D07_F76B159E58C5_1911938133]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
