USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[imeRemitCardMaster]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[imeRemitCardMaster](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[remitCardNo] [bigint] NULL,
	[accountNo] [varchar](50) NULL,
	[clientCode] [varchar](50) NULL,
	[cardStatus] [varchar](50) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[cardType] [char](1) NULL,
	[agentId] [bigint] NULL,
	[isDeleted] [varchar](10) NULL,
	[transferedBy] [varchar](50) NULL,
	[transferedDate] [datetime] NULL,
	[enrolledBy] [varchar](50) NULL,
	[enrolledDate] [datetime] NULL,
 CONSTRAINT [PK__imeRemit__3213E83F03F95509] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
