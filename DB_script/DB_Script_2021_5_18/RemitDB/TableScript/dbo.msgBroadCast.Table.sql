USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[msgBroadCast]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[msgBroadCast](
	[msgBroadCastId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[countryId] [int] NULL,
	[agentId] [int] NULL,
	[branchId] [int] NULL,
	[msgTitle] [varchar](500) NULL,
	[msgDetail] [nvarchar](max) NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[userType] [varchar](10) NULL,
 CONSTRAINT [PK__msgBroad__313A37941BEDACCF] PRIMARY KEY CLUSTERED 
(
	[msgBroadCastId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
