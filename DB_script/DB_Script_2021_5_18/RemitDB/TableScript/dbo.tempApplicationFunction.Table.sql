USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tempApplicationFunction]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tempApplicationFunction](
	[functionId] [varchar](10) NOT NULL,
	[parentFunctionId] [varchar](10) NULL,
	[functionName] [varchar](50) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
 CONSTRAINT [pk_idx_tempApplicationFunction_functionId] PRIMARY KEY CLUSTERED 
(
	[functionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
