USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[controlNoListDomestic]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[controlNoListDomestic](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[controlNo] [varchar](50) NULL,
 CONSTRAINT [PK_controlNoListDomestic] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
