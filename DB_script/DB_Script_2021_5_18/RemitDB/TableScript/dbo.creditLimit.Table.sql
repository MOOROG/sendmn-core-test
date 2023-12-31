USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[creditLimit]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[creditLimit](
	[crLimitId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[currency] [int] NULL,
	[limitAmt] [money] NULL,
	[perTopUpAmt] [money] NULL,
	[maxLimitAmt] [money] NULL,
	[expiryDate] [datetime] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[topUpTillYesterday] [money] NULL,
	[topUpToday] [money] NULL,
	[todaysSent] [money] NULL,
	[todaysPaid] [money] NULL,
	[todaysCancelled] [money] NULL,
	[lienAmt] [money] NULL,
	[yesterdaysBalance] [money] NULL,
	[todaysAddedMaxLimit] [money] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[perToupRequest] [money] NULL,
	[maxTopupRequest] [money] NULL,
	[todaysEPI] [money] NULL,
	[todaysPOI] [money] NULL,
 CONSTRAINT [PK__creditLi__095E985304B14909] PRIMARY KEY CLUSTERED 
(
	[crLimitId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[creditLimit] ADD  CONSTRAINT [MSrepl_tran_version_default_ABA7F6CE_A2C6_4E61_B828_2AB90AD84854_593697463]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
