USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tbl_Message]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Message](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](100) NOT NULL,
	[Language] [varchar](100) NOT NULL,
	[Msg] [nvarchar](1000) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbl_Message] ADD  DEFAULT ('en') FOR [Language]
GO
