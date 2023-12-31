USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tempApplicationMenu]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tempApplicationMenu](
	[sno] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Module] [int] NULL,
	[functionId] [varchar](10) NOT NULL,
	[menuName] [varchar](100) NULL,
	[menuDescription] [varchar](100) NULL,
	[linkPage] [varchar](100) NULL,
	[menuGroup] [varchar](40) NULL,
	[position] [int] NULL,
	[isActive] [char](1) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[groupPosition] [int] NULL,
 CONSTRAINT [pk_idx_tempApplicationMenu_sno] PRIMARY KEY CLUSTERED 
(
	[sno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
