USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[cisMaster]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisMaster](
	[cisMasterId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[sCountry] [int] NULL,
	[sAgent] [int] NULL,
	[sState] [int] NULL,
	[sZip] [int] NULL,
	[sGroup] [int] NULL,
	[sCustType] [int] NULL,
	[rCountry] [int] NULL,
	[rAgent] [int] NULL,
	[rState] [int] NULL,
	[rZip] [int] NULL,
	[rGroup] [int] NULL,
	[rCustType] [int] NULL,
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
PRIMARY KEY CLUSTERED 
(
	[cisMasterId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cisMaster] ADD  CONSTRAINT [MSrepl_tran_version_default_93EA05A9_1D64_429D_91BC_8E9E7646C6BB_1380968046]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
