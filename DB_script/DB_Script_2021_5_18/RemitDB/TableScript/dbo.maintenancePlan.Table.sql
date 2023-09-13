USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[maintenancePlan]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[maintenancePlan](
	[mpId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[fromDate] [datetime] NULL,
	[toDate] [datetime] NULL,
	[msg] [varchar](500) NULL,
	[reason] [varchar](500) NULL,
	[isEnable] [char](1) NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
 CONSTRAINT [PK__maintena__76E212F55E176A2C] PRIMARY KEY CLUSTERED 
(
	[mpId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
