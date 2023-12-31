USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[maintenancePlanMod]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[maintenancePlanMod](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[mpId] [int] NULL,
	[fromDate] [datetime] NULL,
	[toDate] [datetime] NULL,
	[msg] [varchar](500) NULL,
	[reason] [varchar](500) NULL,
	[isEnable] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modType] [char](1) NULL,
 CONSTRAINT [pk_idx_maintenancePlanMod_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
