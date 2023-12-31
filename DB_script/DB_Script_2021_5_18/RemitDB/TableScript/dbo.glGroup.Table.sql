USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[glGroup]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[glGroup](
	[glCode] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[glName] [varchar](200) NULL,
	[pId] [varchar](20) NULL,
	[balGrp] [varchar](20) NULL,
	[treeShape] [varchar](500) NULL,
 CONSTRAINT [pk_idx_glGroup_glCode] PRIMARY KEY CLUSTERED 
(
	[glCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
