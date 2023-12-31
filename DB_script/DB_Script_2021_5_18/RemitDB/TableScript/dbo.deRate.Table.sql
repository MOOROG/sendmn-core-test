USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[deRate]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[deRate](
	[deRateId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[hub] [int] NULL,
	[country] [int] NULL,
	[baseCurrency] [int] NULL,
	[localCurrency] [int] NULL,
	[cost] [money] NULL,
	[margin] [money] NULL,
	[ve] [money] NULL,
	[ne] [money] NULL,
	[spFlag] [char](1) NULL,
	[isEnable] [char](1) NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK__deRate__343D55BF3F522093] PRIMARY KEY CLUSTERED 
(
	[deRateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[deRate] ADD  CONSTRAINT [MSrepl_tran_version_default_0F99371F_A03D_4668_B4D6_741343721292_673489528]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
