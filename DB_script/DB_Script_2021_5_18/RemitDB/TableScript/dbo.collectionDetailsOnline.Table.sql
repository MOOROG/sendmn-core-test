USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[collectionDetailsOnline]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[collectionDetailsOnline](
	[detailId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[collMode] [varchar](50) NULL,
	[countryBankId] [bigint] NULL,
	[amt] [money] NULL,
	[collDate] [datetime] NULL,
	[narration] [varchar](500) NULL,
	[branchId] [int] NULL,
	[tranId] [bigint] NULL,
	[pendingBankDepId] [int] NULL,
	[createdBy] [varchar](200) NULL,
	[createdDate] [datetime] NULL,
	[tellerNo] [varchar](20) NULL,
 CONSTRAINT [pk_idx_collectionDetailsOnline_detailId] PRIMARY KEY CLUSTERED 
(
	[detailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
